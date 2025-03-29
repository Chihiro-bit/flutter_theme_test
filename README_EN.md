Here's the English translation of your technical document. I've maintained the structure and technical accuracy while adapting the language for natural English flow:

# Implement Dark Mode Switching & Persistence in Flutter with Bloc

Modern app development often requires dark mode and light mode capabilities. **Dark Mode** has become a critical part of user experience. We want our app to switch themes based on system settings or user preferences and maintain consistency after restarts. This guide will walk you through implementing this using **Bloc** and **hydrated_bloc**.

## ✨ Why Choose Bloc?

[Bloc](https://bloclibrary.dev/#/) is a popular state management solution in Flutter. Based on event-driven and state-response patterns, it effectively separates UI from business logic, enhancing code readability, maintainability, and testability.

**hydrated_bloc**, an extension for Bloc, provides automatic state persistence capabilities by storing states locally. It's ideal for scenarios requiring retained settings (e.g., theme mode) between app sessions.

## ✨ Why `hydrated_bloc` Instead of `shared_preferences`?

While both `shared_preferences` and `hydrated_bloc` can save user preferences, they serve different purposes and have distinct advantages.

### ✅ Advantages of hydrated_bloc

| Comparison          | hydrated_bloc                     | shared_preferences |
|---------------------|----------------------------------|-------------------|
| **Integration**     | Built into Bloc architecture     | Manual management |
| **Serialization**   | Automatic with `fromJson`/`toJson` | Manual per-field handling |
| **State Sync**      | Auto-sync with UI                | Manual UI updates |
| **Maintainability** | High, centralized logic          | Repetitive code   |
| **Performance**     | Memory cache + fast disk access  | Slower disk reads |
| **Object Support**  | Complex state objects            | Basic types only  |

### 🚀 Performance: Faster Reads

`hydrated_bloc` uses memory caching: After initial disk read, states remain in memory, enabling **near-instant restoration**.

`shared_preferences` requires asynchronous disk access for every read, even for single values, causing minor delays during app startup or quick theme switches.

> ✅ In short:\
> If you're already using Bloc, **hydrated_bloc makes state persistence "invisible"**, simplifying development and improving user experience.

## 📁 Step 1: Add Dependencies

Add these to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_bloc: ^9.1.0
  hydrated_bloc: ^10.0.0
  path_provider: ^2.1.5
  equatable: ^2.0.5
```

### ✅ Dependency Notes:
- `flutter_bloc`: Core Bloc functionality
- `hydrated_bloc`: State persistence
- `path_provider`: Storage path access
- `equatable`: Simplified state comparison

## 🎨 Step 2: Define Light/Dark Themes

Create an `AppThemes` class with theme definitions:

```dart
import 'package:flutter/material.dart';

class AppThemes {
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue;
        }
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.withValues(alpha: 0.5);
        }
        return Colors.grey.shade300;
      }),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.blue;
        }
        return Colors.grey.shade600;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.blue.withValues(alpha: 0.5);
        }
        return Colors.grey.shade800;
      }),
    ),
  );
}
```

### 🧠 Key Points:
- `brightness` controls theme mode
- `colorScheme.fromSeed` auto-generates color schemes
- Unified configurations for `AppBarTheme`, `ElevatedButtonTheme`, etc.

## ⚙️ Step 3: Create ThemeBloc

The Bloc handles theme state and events.

```dart
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
    // HydratedBloc handles loading automatically
    // This event exists for consistency and future extensions
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
```

### 🧠 Key Points:
- `ThemeMode.system` follows system settings by default
- `_onThemeChanged` responds to user-initiated theme changes
- `fromJson`/`toJson` handle persistence serialization

## 🔁 Theme Events

```dart
part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeStarted extends ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;

  const ThemeChanged(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}
```

- All events inherit from `ThemeEvent`
- `ThemeChanged` carries a `ThemeMode` value

## 📦 Theme State

```dart
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
```

- Contains current `ThemeMode` and both themes
- `copyWith` enables state updates
- Only `themeMode` is persisted for efficiency

## 🏁 Step 4: Initialize and Provide Bloc

Set up in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  runApp(const MyApp());
}
```

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            theme: state.lightTheme,
            darkTheme: state.darkTheme,
            themeMode: state.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
```

### ✅ Key Points:
- Initialize `HydratedBloc.storage` for persistence
- `BlocBuilder` dynamically updates `MaterialApp` based on state

## 🧩 Step 5: Theme Switcher UI Component

Create `ThemeModeSelector` for manual selection:

```dart
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
```

## 🧱 Step 6: Themed Card Component

Create a theme-aware card widget:

```dart
import 'package:flutter/material.dart';

class ThemedCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ThemedCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🏡 Step 7: Home Screen Integration

Implement in `HomeScreen`:

```dart
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
        actions: const [
          ThemeModeSelector(),
          SizedBox(width: 16),
        ],
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
                description: 'UI elements respond to theme changes automatically',
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
                          ThemeChanged(
                            value ? ThemeMode.dark : ThemeMode.light,
                          ),
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
```

## ✅ Conclusion

We've learned to:
1. Use **Bloc** for clean theme state management
2. Implement persistence with **hydrated_bloc**
3. Create theme-aware UI components (buttons, cards, switches)

This architecture extends beyond themes to features like language switching or layout preferences requiring persistence.

Let me know if you need any adjustments to the translation!
