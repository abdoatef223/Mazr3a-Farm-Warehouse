# Movies App - Engineering & Architecture Rules

> **Standard Operating Guidelines for AI Agents & Developers**  
> *Target Architecture*: Clean Architecture (Feature-First) with Dart 3 & Flutter  
> *Primary Stack*: Flutter Bloc (Cubit), Injectable + GetIt, Retrofit + Dio, AutoRoute, Firebase, FlutterScreenUtil, FlutterGen.

---

## 1. Project Overview & Technology Stack

This application is built according to **Clean Architecture** principles with a **feature-first modular structure**. All code contributed to this codebase must adhere strictly to the established patterns, boundaries, and lint constraints.

| Category | Technology / Package | Configuration / Notes |
| :--- | :--- | :--- |
| **SDK & Language** | Flutter SDK `^3.12.2` / Dart 3.x | Strict null-safety, sealed classes, pattern matching, record types |
| **Architecture** | Clean Architecture (Feature-First) | `domain/`, `data/`, `presentation/` separation per feature |
| **State Management** | `flutter_bloc` (`^9.1.1`) | `Cubit` with `sealed class` state hierarchies |
| **Dependency Injection** | `get_it` (`^9.2.1`) & `injectable` (`^3.0.0`) | Code-generated service locator via `build_runner` |
| **Networking & HTTP** | `dio` (`^5.11.1`) & `retrofit` (`^4.10.0`) | Typed API contracts, interceptors with `pretty_dio_logger` |
| **Result & Error Flow** | Custom `ApiResult<T>` (`sealed class`) | `ApiSuccess<T>` and `ApiError<T>` |
| **Navigation & Routing** | `auto_route` (`^11.1.0`) | Guarded declarative routing with `AppRouter` |
| **Backend & Cloud** | Firebase (Core, Auth, Firestore, Google Sign-In) | Encapsulated in `lib/core/firebase_service/` |
| **Responsive Sizing** | `flutter_screenutil_plus` (`^1.6.0`) | Base design canvas: `430 x 932` |
| **Localization (i18n)** | `flutter_localizations`, `intl` (`^0.20.2`) | `AppLocalizations` (`en`, `ar`) |
| **Code Generation** | `build_runner`, `injectable_generator`, `retrofit_generator`, `auto_route_generator`, `flutter_gen` | Generated files: `*.g.dart`, `*.gr.dart`, `*.config.dart` |

---

## 2. Directory Structure & Architecture Boundaries

Every feature resides in `lib/features/<feature_name>/` and must respect boundary separation.

```
lib/
├── core/                               # Cross-cutting foundational modules
│   ├── di/                             # GetIt setup & Injectable init (injection.dart)
│   ├── enum/                           # Shared domain/UI enums
│   ├── extensions/                     # Extension methods (num, context, etc.)
│   ├── firebase_service/               # Firebase Auth & Firestore wrappers
│   ├── general_cubit/                  # Global app state (Theme, Locale)
│   ├── helpers/                        # Validation, string formatters, helpers
│   ├── internet_checker/               # Internet connectivity status checker
│   ├── models/                         # Shared core models (e.g. UserModel)
│   ├── network/                        # DioFactory, ApiResult, base network layer
│   ├── resources/                      # StringsManager, AssetsManager, AppButtons
│   ├── routing/                        # AppRouter, route guards, route configurations
│   ├── theme/                          # Colors, Typography, AppTheme (light/dark)
│   ├── utils/                          # Low-level utilities
│   └── widgets/                        # Shared reusable atomic UI widgets
├── features/                           # Feature modules (Feature-First)
│   └── <feature_name>/
│       ├── domain/                     # 🛡️ PURE BUSINESS LOGIC (No Flutter/UI dependencies)
│       │   ├── entity/                 # Domain business objects
│       │   ├── repo/                   # Abstract repository interfaces
│       │   └── use_cases/              # Single-action use case classes
│       ├── data/                       # 🔌 IMPLEMENTATION & DATA SOURCES
│       │   ├── api_service/            # Retrofit REST interfaces
│       │   ├── datasource/             # Abstract data source contracts
│       │   ├── datasource_impl/        # Remote/Local data source implementations
│       │   ├── model/                  # DTOs / Models with JSON serialization
│       │   └── repo_impl/              # Repository implementations
│       └── presentation/               # 🎨 UI & STATE MANAGEMENT
│           ├── view_model/             # Cubit and Sealed State files
│           ├── screens/                # Screen widgets annotated with @RoutePage()
│           └── widgets/                # Feature-specific reusable UI sub-widgets
├── generated/                          # Code-generated assets and localizations
├── my_app.dart                         # MaterialApp, ScreenUtilInit, Theme/Locale wiring
└── main.dart                           # App entry point, DI & Firebase initializations
```

### Cross-Layer Dependency Rules:
1. **Domain Layer**: Must NEVER import `presentation/`, `data/`, or Flutter UI packages (e.g. `flutter/material.dart`). It is pure business logic.
2. **Data Layer**: Depends ONLY on `domain/` and `core/network/`. Implements interfaces defined in the domain layer.
3. **Presentation Layer**: Depends on `domain/use_cases/`, `core/`, and feature-specific widgets. It MUST NOT directly access data sources, repositories, or Retrofit services.

---

## 3. Domain Layer Standards

### 3.1 Entities (`domain/entity/`)
- Entities represent the core business models.
- Must be immutable (`const` constructors, `final` fields).
- Keep free of serialization logic (`fromJson` / `toJson` belong to Data models, NOT entities).

```dart
// lib/features/home/domain/entity/movie_entity.dart
class MovieEntity {
  const MovieEntity({
    required this.id,
    required this.rating,
    required this.genres,
    required this.backgroundImage,
    required this.smallCoverImage,
  });

  final String id;
  final num rating;
  final List<String> genres;
  final String backgroundImage;
  final String smallCoverImage;
}
```

### 3.2 Repository Contracts (`domain/repo/`)
- Always declare repository contracts as modern Dart 3 `abstract interface class`.
- Return `FutureApiResult<T>` (alias for `Future<ApiResult<T>>`).

```dart
// lib/features/home/domain/repo/movies_repo.dart
import 'package:movies/core/network/api_result.dart';
import 'package:movies/features/home/data/model/movies_param.dart';
import 'package:movies/features/home/domain/entity/movie_entity.dart';

abstract interface class MoviesRepo {
  FutureApiResult<List<MovieEntity>> getMovies(GetMoviesParams params);
}
```

### 3.3 Use Cases (`domain/use_cases/`)
- Every use case must have a single responsibility.
- Annotate with `@singleton` or `@lazySingleton`.
- Provide a `call(...)` method to enable callable class syntax (`useCase(params)`).
- Inject repository interfaces, never concrete implementations.

```dart
// lib/features/home/domain/use_cases/get_movies_use_case.dart
import 'package:injectable/injectable.dart';
import 'package:movies/core/network/api_result.dart';
import 'package:movies/features/home/data/model/movies_param.dart';
import 'package:movies/features/home/domain/entity/movie_entity.dart';
import 'package:movies/features/home/domain/repo/movies_repo.dart';

@singleton
class GetMoviesUseCase {
  GetMoviesUseCase(this._moviesRepo);

  final MoviesRepo _moviesRepo;

  FutureApiResult<List<MovieEntity>> call(GetMoviesParams params) =>
      _moviesRepo.getMovies(params);
}
```

---

## 4. Data Layer Standards

### 4.1 Data Models (`data/model/`)
- Models represent external representations (JSON, Firestore DTOs).
- Models extend their corresponding domain entity: `class MovieModel extends MovieEntity`.
- Contain `factory Model.fromJson(Map<String, dynamic> json)` and `Map<String, dynamic> toJson()`.
- Use null-safe parsing with safe fallbacks.

```dart
// lib/features/home/data/model/movie_model.dart
import 'package:movies/features/home/domain/entity/movie_entity.dart';

class MovieModel extends MovieEntity {
  const MovieModel({
    required super.id,
    required super.rating,
    required super.genres,
    required super.backgroundImage,
    required super.smallCoverImage,
    required this.title,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
    id: json['id'].toString(),
    rating: json['rating'] ?? 0,
    genres: List<String>.from(json['genres'] ?? const []),
    backgroundImage: json['background_image'] ?? '',
    smallCoverImage: json['small_cover_image'] ?? '',
    title: json['title'] ?? '',
  );

  final String title;
}
```

### 4.2 Retrofit API Service (`data/api_service/`)
- Retrofit interfaces must be annotated with `@RestApi()` and `@lazySingleton`.
- Endpoints must be strongly typed with appropriate query/path parameters.

```dart
// lib/features/home/data/api_service/api_service.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@lazySingleton
@RestApi()
abstract class ApiService {
  @factoryMethod
  factory ApiService(Dio dio) = _ApiService;

  @GET('list_movies.json')
  Future<Map<String, dynamic>> getMovies({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('genre') String? genre,
  });
}
```

### 4.3 Data Sources (`data/datasource/` & `data/datasource_impl/`)
- Define abstract contract: `abstract interface class MovieDataSource`.
- Implementation annotated with `@Injectable(as: MovieDataSource)`.
- Catch exceptions in data source and wrap results in `ApiSuccess` or `ApiError`.

```dart
// lib/features/home/data/datasource_impl/movie_datasource_impl.dart
import 'package:injectable/injectable.dart';
import 'package:movies/core/network/api_result.dart';
import 'package:movies/features/home/data/api_service/api_service.dart';
import 'package:movies/features/home/data/datasource/movie_datasource.dart';
import 'package:movies/features/home/data/model/movie_model.dart';
import 'package:movies/features/home/data/model/movies_param.dart';

@Injectable(as: MovieDataSource)
class MovieDataSourceImpl implements MovieDataSource {
  MovieDataSourceImpl(this._apiService);

  final ApiService _apiService;

  @override
  FutureApiResult<List<MovieModel>> getMovies(GetMoviesParams params) async {
    try {
      final response = await _apiService.getMovies(page: params.page, limit: params.limit);
      final data = response['data'] as Map<String, dynamic>?;
      final moviesJson = data?['movies'] as List<dynamic>? ?? const [];
      final movies = moviesJson
          .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
          .toList();
      return ApiSuccess(data: movies);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }
}
```

### 4.4 Repository Implementation (`data/repo_impl/`)
- Annotated with `@Injectable(as: MoviesRepo)`.
- **Precondition Check**: Always verify internet connection with `InternetChecker.checkConnection()` before remote requests.
- Handle data source results via Dart 3 pattern-matching `switch (result)` expressions.
- Catch typed `on Exception catch (e)` and return `ApiError`.

```dart
// lib/features/home/data/repo_impl/movie_repo_impl.dart
import 'package:injectable/injectable.dart';
import 'package:movies/core/internet_checker/internet_checker.dart';
import 'package:movies/core/network/api_result.dart';
import 'package:movies/features/home/data/datasource/movie_datasource.dart';
import 'package:movies/features/home/data/model/movies_param.dart';
import 'package:movies/features/home/domain/entity/movie_entity.dart';
import 'package:movies/features/home/domain/repo/movies_repo.dart';

@Injectable(as: MoviesRepo)
class MoviesRepoImpl implements MoviesRepo {
  MoviesRepoImpl(this._movieDataSource);

  final MovieDataSource _movieDataSource;

  @override
  FutureApiResult<List<MovieEntity>> getMovies(GetMoviesParams params) async {
    if (!await InternetChecker.checkConnection()) {
      return const ApiError(message: 'No internet connection');
    }

    try {
      final result = await _movieDataSource.getMovies(params);
      return switch (result) {
        ApiSuccess(:final data) => ApiSuccess(data: data),
        ApiError(:final message) => ApiError(message: message),
      };
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }
}
```

---

## 5. Presentation Layer Standards

### 5.1 States Architecture (`view_model/*_states.dart`)
- States MUST be declared using a `sealed class` root.
- The root class contains shared properties and an abstract `copyWith(...)` method.
- State classes must be `const` and extend the base sealed class.
- Always use `part of '<cubit_name>_cubit.dart';`.

```dart
// lib/features/home/presentation/view_model/home_states.dart
part of 'home_cubit.dart';

sealed class HomeStates {
  const HomeStates({this.selectedTapIndex = 0, this.selectedGenre});

  final int selectedTapIndex;
  final String? selectedGenre;

  HomeStates copyWith({int? selectedTapIndex, String? selectedGenre});
}

class HomeInit extends HomeStates {
  const HomeInit({super.selectedTapIndex, super.selectedGenre});

  @override
  HomeInit copyWith({int? selectedTapIndex, String? selectedGenre}) =>
      HomeInit(
        selectedTapIndex: selectedTapIndex ?? this.selectedTapIndex,
        selectedGenre: selectedGenre ?? this.selectedGenre,
      );
}

class HomeLoading extends HomeStates {
  const HomeLoading({super.selectedTapIndex, super.selectedGenre});

  @override
  HomeLoading copyWith({int? selectedTapIndex, String? selectedGenre}) =>
      HomeLoading(
        selectedTapIndex: selectedTapIndex ?? this.selectedTapIndex,
        selectedGenre: selectedGenre ?? this.selectedGenre,
      );
}

class HomeLoaded extends HomeStates {
  const HomeLoaded({
    required this.movies,
    super.selectedTapIndex,
    super.selectedGenre,
  });

  final List<MovieEntity> movies;

  @override
  HomeLoaded copyWith({
    List<MovieEntity>? movies,
    int? selectedTapIndex,
    String? selectedGenre,
  }) =>
      HomeLoaded(
        movies: movies ?? this.movies,
        selectedTapIndex: selectedTapIndex ?? this.selectedTapIndex,
        selectedGenre: selectedGenre ?? this.selectedGenre,
      );
}

class HomeError extends HomeStates {
  const HomeError({required this.message, super.selectedTapIndex, super.selectedGenre});

  final String message;

  @override
  HomeError copyWith({String? message, int? selectedTapIndex, String? selectedGenre}) =>
      HomeError(
        message: message ?? this.message,
        selectedTapIndex: selectedTapIndex ?? this.selectedTapIndex,
        selectedGenre: selectedGenre ?? this.selectedGenre,
      );
}
```

### 5.2 Cubit Architecture (`view_model/*_cubit.dart`)
- Annotate with `@Injectable()`.
- Inject use cases via constructor injection.
- Provide a static helper method: `static FeatureCubit of(BuildContext context) => context.read<FeatureCubit>();`.
- Async initialization in constructor must be explicitly wrapped in `unawaited(...)`.
- Always dispose controllers, timers, and stream subscriptions inside `close()`.

```dart
// lib/features/home/presentation/view_model/home_cubit.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:movies/core/network/api_result.dart';
import 'package:movies/features/home/data/model/movies_param.dart';
import 'package:movies/features/home/domain/entity/movie_entity.dart';
import 'package:movies/features/home/domain/use_cases/get_movies_use_case.dart';

part 'home_states.dart';

@Injectable()
class HomeCubit extends Cubit<HomeStates> {
  HomeCubit(this._getMoviesUseCase) : super(const HomeInit()) {
    unawaited(fetchMovies());
  }

  final GetMoviesUseCase _getMoviesUseCase;

  static HomeCubit of(BuildContext context) => context.read<HomeCubit>();

  Future<void> fetchMovies() async {
    emit(HomeLoading(selectedTapIndex: state.selectedTapIndex));
    final result = await _getMoviesUseCase(const GetMoviesParams());

    switch (result) {
      case ApiSuccess(:final data):
        emit(HomeLoaded(movies: data, selectedTapIndex: state.selectedTapIndex));
      case ApiError(:final message):
        emit(HomeError(message: message, selectedTapIndex: state.selectedTapIndex));
    }
  }
}
```

### 5.3 Screens & UI Components
- Annotate Screen classes with `@RoutePage()`.
- Inject Cubits at the route or screen boundary using `BlocProvider(create: (_) => getIt<FeatureCubit>())`.
- Prefer `BlocBuilder` for rebuilding parts of the UI, `BlocListener` for one-time side-effects (dialogs, toasts, navigation), and `BlocConsumer` when both are needed.
- Build clean, small sub-widgets in `presentation/widgets/`.

---

## 6. Dependency Injection & Service Locator (`GetIt` + `Injectable`)

- Registration entry point: `lib/core/di/injection.dart` (`configureDependencies()`).
- Always register dependencies via `@Injectable` annotations instead of manually editing `injection.dart`.
- Annotation guide:
  - `@singleton`: Single eager instance across application lifecycle.
  - `@lazySingleton`: Single instance created upon first request (recommended for API services & repositories).
  - `@Injectable()`: Factory instance created on each request (standard for Cubits).
  - `@Injectable(as: InterfaceName)`: Registers the class as an implementation of an abstract contract.
  - `@module`: For external third-party classes (e.g. `Dio`, `SharedPreferences`).
- **Code Generation Trigger**: Whenever annotations are modified, added, or deleted, run:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

---

## 7. Routing & Navigation Guidelines (`AutoRoute`)

- Central router: `lib/core/routing/app_router.dart`.
- Setup uses `@AutoRouterConfig(replaceInRouteName: 'Screen,Route')`.
- Screens must end with `Screen` (e.g., `HomeScreen`) to generate `HomeRoute`.
- Guarding routes: Use `AutoRouteGuard` implementations (such as `AuthGuard`) in `AppRouter.routes`.
- Navigation actions:
  - Push: `context.router.push(const TargetRoute());`
  - Replace: `context.router.replace(const TargetRoute());`
  - Pop: `context.router.maybePop();`

---

## 8. Network & Error Handling Architecture

- Handled centrally through `ApiResult<T>`:
  - `ApiSuccess<T>`: Contains `final T data;`
  - `ApiError<T>`: Contains `final String message;`
- Typed alias: `typedef FutureApiResult<T> = Future<ApiResult<T>>;`
- Pre-request connectivity: Check `InternetChecker.checkConnection()` in every repository implementation.
- Handlers should utilize modern pattern matching (`switch (result) { ApiSuccess(...) => ..., ApiError(...) => ... }`).

---

## 9. UI, Sizing, Theming & Asset Rules

### 9.1 Responsive UI with ScreenUtil
- Canvas Size: `430 x 932` (defined in `my_app.dart`).
- Dimensions & Paddings: Use `.w` for width, `.h` for height, `.r` for radius, `.sp` for fonts.
- Gaps: Use SizedBox with `.h` / `.w` or screenutil extension shortcuts.

### 9.2 Theming & Styling
- App theme configuration: `lib/core/theme/theme_modes.dart` (`AppTheme.light`, `AppTheme.dark`).
- Colors & Typography: Extract styles from `Theme.of(context)` or predefined theme extensions. Avoid hardcoded hex colors in feature widgets.
- Global theme switching is orchestrated by `GeneralCubit`.

### 9.3 Reusable Common Widgets (`lib/widgets/`)
Always reuse established core widgets before creating custom ones:
- `AppText`: Standard typography wrapper.
- `AppTextField`: Standard stylized input field with validation support.
- `AppButton`: Standardized action button.
- `AppNetworkImage`: Cached network image with shimmer placeholder and error state.
- `AppSnackBar`: Toast & snackbar notification system.
- `AppProgressIndicator`: Loading indicators.

### 9.4 Asset Management (`flutter_gen`)
- Raw assets reside in `assets/images/png/`, `assets/images/svg/`, `assets/fonts/`.
- Access assets through generated classes in `lib/generated/assets/` or `AssetsManager`.
- Never use raw asset string literals (e.g. `'assets/images/logo.png'` is strictly forbidden).

---

## 10. Strict Linting & Code Quality Standards

The project enforces strict analysis rules via `analysis_options.yaml`. Any violation will fail analysis.

1. **Imports**:
   - `always_use_package_imports: true`: Relative imports (`../`) are **PROHIBITED**. Always use package paths:
     ```dart
     // ✅ CORRECT
     import 'package:movies/core/network/api_result.dart';

     // ❌ FORBIDDEN
     import '../../core/network/api_result.dart';
     ```
   - `directives_ordering: true`: Alphabetical order: Dart SDK imports -> Package imports -> Project imports.

2. **Strings**:
   - `prefer_single_quotes: true`: Always use single quotes `'text'` unless escaping double quotes.

3. **Constructors & Immutability**:
   - `prefer_const_constructors: true`
   - `prefer_const_declarations: true`
   - `prefer_const_literals_to_create_immutables: true`
   - `sort_constructors_first: true`: Constructors must appear before methods/fields.
   - `use_super_parameters: true`: Use `super.key`, `super.param`.

4. **Async & Futures Safety**:
   - `discarded_futures: true`: Every `Future` must either be awaited, assigned, or returned.
   - `unawaited_futures: true`: Intentionally unawaited futures must be wrapped in `unawaited(future)`.
   - `avoid_void_async: true`: Return `Future<void>`, never `void` for async functions.

5. **Error Handling**:
   - `avoid_catches_without_on_clauses: true`: Always specify `on Exception catch (e)` or `on Object catch (e)`. Never write bare `catch (e)`.
   - `avoid_catching_errors: true`: Do not catch Dart `Error` classes.

6. **Clean Code & Performance**:
   - `avoid_print: true`: Do NOT use `print()`. Use debug logger or Dio logger.
   - `prefer_expression_function_bodies: true`: Prefer `=>` for single-expression functions.
   - `avoid_unnecessary_containers: true`: Use `SizedBox`, `Padding`, or `ColoredBox` instead of raw `Container` where appropriate.
   - `sized_box_for_whitespace: true`, `use_colored_box: true`, `use_decorated_box: true`.

---

## 11. Step-by-Step Feature Implementation Checklist

When adding a new feature or endpoint, follow this strict sequence:

1. **Domain Layer**:
   - [ ] Define Entity in `lib/features/<feature>/domain/entity/`
   - [ ] Define Repository contract (`abstract interface class`) in `lib/features/<feature>/domain/repo/`
   - [ ] Implement Use Case(s) annotated with `@singleton` in `lib/features/<feature>/domain/use_cases/`
2. **Data Layer**:
   - [ ] Define Model extending Entity in `lib/features/<feature>/data/model/`
   - [ ] Add endpoint in Retrofit service (`api_service.dart`)
   - [ ] Define DataSource contract in `lib/features/<feature>/data/datasource/`
   - [ ] Implement DataSource with `@Injectable(as: DataSource)` in `lib/features/<feature>/data/datasource_impl/`
   - [ ] Implement Repository with `@Injectable(as: Repo)` in `lib/features/<feature>/data/repo_impl/`
3. **Presentation Layer**:
   - [ ] Create sealed state hierarchy in `lib/features/<feature>/presentation/view_model/<feature>_states.dart`
   - [ ] Implement Cubit annotated with `@Injectable()` in `lib/features/<feature>/presentation/view_model/<feature>_cubit.dart`
   - [ ] Create UI screen annotated with `@RoutePage()` in `lib/features/<feature>/presentation/screens/`
   - [ ] Break UI down into modular widgets in `lib/features/<feature>/presentation/widgets/`
4. **Wiring & Code Generation**:
   - [ ] Add route to `lib/core/routing/app_router.dart`
   - [ ] Run code generation:
     ```bash
     dart run build_runner build --delete-conflicting-outputs
     ```
   - [ ] Run static analysis to verify zero errors:
     ```bash
     dart analyze
     ```
