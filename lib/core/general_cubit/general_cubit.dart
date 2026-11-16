import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'general_states.dart';

@lazySingleton
class GeneralCubit extends Cubit<GeneralStates> {
  GeneralCubit() : super(const GeneralInitial());

  static GeneralCubit of(BuildContext context) =>
      context.read<GeneralCubit>();

  void toggleTheme() {
    final nextMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(GeneralThemeChanged(themeMode: nextMode));
  }

  void setTheme(ThemeMode mode) => emit(GeneralThemeChanged(themeMode: mode));
}
