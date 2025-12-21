import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/theme/theme_event.dart';
import 'package:hisobchi/application/theme/theme_state.dart';
import 'package:hisobchi/infrastructure/repository/theme/theme_repository.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository repository;

  ThemeBloc({required this.repository}) : super(const ThemeState()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  /// Theme ni yuklash
  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final themeMode = await repository.getSavedThemeMode();
      emit(state.copyWith(
        themeMode: themeMode,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Theme ni o'zgartirish
  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      await repository.saveThemeMode(event.themeMode);
      emit(state.copyWith(themeMode: event.themeMode));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Theme ni toggle qilish (light <-> dark)
  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final newThemeMode = await repository.toggleThemeMode();
      emit(state.copyWith(themeMode: newThemeMode));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}