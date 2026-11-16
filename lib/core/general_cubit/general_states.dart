part of 'general_cubit.dart';

sealed class GeneralStates {
  const GeneralStates({this.themeMode = ThemeMode.light});

  final ThemeMode themeMode;
}

class GeneralInitial extends GeneralStates {
  const GeneralInitial({super.themeMode});
}

class GeneralThemeChanged extends GeneralStates {
  const GeneralThemeChanged({required super.themeMode});
}
