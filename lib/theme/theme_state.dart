part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeState({
    required this.themeMode,
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  List<Object> get props => [themeMode];

  ThemeState copyWith({
    ThemeMode? themeMode,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
    };
  }


  factory ThemeState.fromMap(Map<String, dynamic> map) {
    return ThemeState(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      lightTheme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
    );
  }
}
