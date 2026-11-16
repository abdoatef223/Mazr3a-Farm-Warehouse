import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:mazr3a/core/di/injection.dart';
import 'package:mazr3a/core/general_cubit/general_cubit.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/core/routing/app_router.dart';
import 'package:mazr3a/core/theme/theme_modes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ScreenUtilPlusInit(
        designSize: const Size(1920, 900),
        minTextAdapt: true,
        builder: (context, child) => BlocProvider(
          create: (_) => getIt<GeneralCubit>(),
          child: BlocBuilder<GeneralCubit, GeneralStates>(
            builder: (context, state) => MaterialApp.router(
              title: StringsManager.logo,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: state.themeMode,
              routerConfig: getIt<AppRouter>().config(),
            ),
          ),
        ),
      );
}
