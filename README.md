***

# 使用 Bloc 实现 Flutter 暗黑主题切换与持久化

现在的App开发，总是免不了暗黑主题和亮色主题的需求，**暗黑模式（Dark Mode）** 已成为用户体验的重要组成部分。我们希望应用能够根据系统设置或用户偏好自动切换主题，并在重启后保持一致。本篇文章将带你一步步使用 **Bloc** 和 **hydrated\_bloc** 来实现这一目标。

**先来看看效果图：**

***
![ezgif-84a68028b8a0f6](https://github.com/user-attachments/assets/ffe30531-b898-4d73-8a20-b460fa83d1ff)

***

## ✨ 为什么选择 Bloc？

[Bloc](https://bloclibrary.dev/#/) 是 Flutter 中广泛使用的状态管理方案之一。它基于事件（Event）驱动和状态（State）响应的模式，将 UI 与业务逻辑有效分离，从而提升了代码的可读性、可维护性以及可测试性。

在此基础上，**hydrated\_bloc** 作为 Bloc 的扩展，提供了自动状态持久化的能力，可以将状态存储在本地磁盘。对于需要在应用重启后保留设置（如主题模式）的场景来说，它是一个非常理想的选择。

## ✨ 为什么选择 `hydrated_bloc` 而不是 `shared_preferences`？

在需要保存用户偏好（如暗黑模式）时，`shared_preferences` 和 `hydrated_bloc` 都是常见的选择，但它们各自的适用场景和优势不同。

### ✅ hydrated\_bloc 的优势

| 对比维度         | hydrated\_bloc                     | shared\_preferences |
| ------------ | ---------------------------------- | ------------------- |
| **集成方式**     | 内建于 Bloc 架构，状态持久化自动进行              | 独立处理，需要手动管理读写       |
| **序列化/反序列化** | 自动进行，仅需实现 `fromJson` / `toJson` 方法 | 需手动处理每个字段的读写逻辑      |
| **状态同步**     | 状态与 UI 自动保持同步，无需额外逻辑               | 状态更新后需要手动通知 UI      |
| **代码维护性**    | 高，可读性强，逻辑集中                        | 易产生重复代码，分散管理        |
| **性能表现**     | 基于内存缓存 + 本地存储，读取速度快                | 每次读取都需访问磁盘，略慢       |
| **支持对象结构**   | 支持复杂状态对象持久化                        | 仅支持基本类型，复杂结构需手动拆解   |

### 🚀 性能对比：读取速度更快

`hydrated_bloc` 内部使用的是内存缓存机制：首次从本地读取状态后，会保留在内存中，因此在后续使用过程中几乎不需要重新读取磁盘，**状态恢复几乎是即时的**。

相比之下，`shared_preferences` 每次读取都涉及异步的磁盘访问，哪怕只是一两个键值，也需要 `await` 操作，这在应用启动时或快速切换主题时可能造成微小的延迟。

> ✅ 简单来说：\
> 如果你已经在使用 Bloc，**hydrated\_bloc 会让你几乎“无感知”地实现状态持久化，开发更轻松，体验更流畅。**

***

## 📁 第一步：添加依赖

在 `pubspec.yaml` 中添加以下依赖项：

    dependencies:
      flutter:
        sdk: flutter
      cupertino_icons: ^1.0.8
      flutter_bloc: ^9.1.0
      hydrated_bloc: ^10.0.0
      path_provider: ^2.1.5
      equatable: ^2.0.5

### ✅ 依赖说明：

*   `flutter_bloc`：核心 Bloc 功能。
*   `hydrated_bloc`：实现 Bloc 状态持久化。
*   `path_provider`：获取持久化存储路径。
*   `equatable`：简化状态对比，提高 Bloc 性能。

***

## 🎨 第二步：定义浅色与暗色主题

创建一个 `AppThemes` 类，包含浅色和暗黑主题定义：

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
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.withValues(alpha: 0.5);
        }
        return Colors.grey.shade800;
      }),
    ),
  );
}
```

### 🧠 说明：

*   `brightness` 决定主题亮度。
*   `colorScheme.fromSeed` 可基于种子色自动生成配色。
*   我们统一配置了 `AppBarTheme`、`ElevatedButtonTheme`、`SwitchTheme` 等，以适配两种模式。

***

## ⚙️ 第三步：创建 ThemeBloc

Bloc 负责监听事件并更新主题状态。

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
```

### 🧠 说明：

*   `ThemeMode.system` 表示默认跟随系统。
*   `_onThemeChanged` 用于响应用户主题切换。
*   `fromJson` 和 `toJson` 方法实现状态的持久化序列化。

***

### 🔁 事件定义（Event）

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

*   所有事件继承自 `ThemeEvent`。
*   `ThemeChanged` 表示切换主题的事件，携带一个 `ThemeMode`。

***

### 📦 状态定义（State）

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

*   状态中包含当前 `ThemeMode` 和两个具体主题。
*   使用 `copyWith` 实现状态更新。
*   只持久化 `themeMode`，而不是整个 `ThemeData`，简洁高效。

***

## 🏁 第四步：初始化并提供 Bloc

在 `main.dart` 中完成初始化：

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

### ✅ 说明：

*   `HydratedBloc.storage` 初始化状态持久化。
*   使用 `BlocBuilder` 动态构建 `MaterialApp`，根据状态切换主题。

***

## 🧩 第五步：主题切换组件 UI

创建 `ThemeModeSelector`，支持手动选择主题：

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

***

## 🧱 第六步：主题响应组件 - ThemedCard

定义一个样式跟随主题变化的卡片组件：

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

***

## 🏡 第七步：主页面集成展示

在 `HomeScreen` 中使用切换器与卡片，展示主题效果：

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

***

## ✅ 总结

通过本文，我们学习了如何：

*   使用 **Bloc** 构建清晰的主题状态管理逻辑；
*   借助 **hydrated\_bloc** 持久化用户的主题设置；
*   构建自定义 UI 组件（如按钮、卡片、切换器）响应主题变化。

这种架构不仅适用于主题切换，也适合扩展到语言切换、布局模式等需要状态持久化的功能。

***

如果你喜欢这篇文章，欢迎分享、收藏，或留言交流！
![微信图片编辑_20250329024958](https://github.com/user-attachments/assets/3f30e978-fe63-4ec4-8e6d-f48929bd9a3b)
