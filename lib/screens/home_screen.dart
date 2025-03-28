import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_theme_test/theme/theme_bloc.dart';
import 'package:flutter_theme_test/widgets/theme_mode_selector.dart';
import 'package:flutter_theme_test/widgets/themed_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Manager'),
        actions: const [ThemeModeSelector(), SizedBox(width: 16)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme Demonstration',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              const Text(
                'This app demonstrates dynamic theme switching using flutter_bloc '
                'with hydrated_bloc for persistence. Your theme preference is '
                'automatically saved between app sessions.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const ThemedCard(
                title: 'Primary Card',
                description: 'This card adapts to the current theme',
                icon: Icons.palette,
              ),
              const SizedBox(height: 16),
              const ThemedCard(
                title: 'Secondary Card',
                description:
                    'UI elements respond to theme changes automatically',
                icon: Icons.color_lens,
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This button also adapts to the theme!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Themed Button'),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Toggle Switch Example:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    context.read<ThemeBloc>().add(
                      ThemeChanged(value ? ThemeMode.dark : ThemeMode.light),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
