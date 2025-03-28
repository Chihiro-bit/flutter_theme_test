import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_theme_test/theme/theme_bloc.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return PopupMenuButton<ThemeMode>(
          icon: Icon(_getThemeIcon(state.themeMode)),
          tooltip: 'Select theme mode',
          onSelected: (ThemeMode mode) {
            context.read<ThemeBloc>().add(ThemeChanged(mode));
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
            const PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Row(
                children: [
                  Icon(Icons.wb_sunny),
                  SizedBox(width: 8),
                  Text('Light'),
                ],
              ),
            ),
            const PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  Icon(Icons.nightlight_round),
                  SizedBox(width: 8),
                  Text('Dark'),
                ],
              ),
            ),
            const PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Row(
                children: [
                  Icon(Icons.settings_suggest),
                  SizedBox(width: 8),
                  Text('System'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.wb_sunny;
      case ThemeMode.dark:
        return Icons.nightlight_round;
      case ThemeMode.system:
        return Icons.settings_suggest;
    }
  }
}

