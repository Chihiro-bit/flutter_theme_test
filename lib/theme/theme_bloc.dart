import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'app_themes.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(ThemeState(
    themeMode: ThemeMode.system,
    lightTheme: AppThemes.lightTheme,
    darkTheme: AppThemes.darkTheme,
  )) {
    on<ThemeStarted>(_onThemeStarted);
    on<ThemeChanged>(_onThemeChanged);
  }

  void _onThemeStarted(ThemeStarted event, Emitter<ThemeState> emit) {
    // No need to load the theme here as HydratedBloc handles it automatically
    // This event is kept for consistency and in case additional initialization is needed
  }

  void _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) {
    emit(state.copyWith(themeMode: event.themeMode));
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    return ThemeState.fromMap(json);
  }

  @override
  Map<String, dynamic> toJson(ThemeState state) {
    return state.toMap();
  }
}