# Toast Dev 🍞

A premium Flutter package for showing beautiful, stackable, and fully customizable animated toasts.

[![pub package](https://img.shields.io/pub/v/toast_dev.svg)](https://pub.dev/packages/toast_dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

- 📚 **Stackable Toasts**: Show multiple toasts without overlapping.
- ⚡ **Context-Free Usage**: Show toasts from anywhere in your app using `ToastDev` wrapper.
- 🎨 **Fully Customizable**: Control everything from colors and shadows to animations and curves.
- 🛠️ **Custom Widgets**: Display any widget as a toast.
- 🤏 **Interactive**: Support for "pull-to-dismiss" and tap-to-expand behaviors.
- 🎭 **Smooth Animations**: Built-in fade, slide, and scale animations.

---

## 🚀 Getting Started

### Installation

Add `toast_dev` to your `pubspec.yaml`:

```yaml
dependencies:
  toast_dev: ^1.0.3
```

Then run:

```bash
flutter pub get
```

---

## 📖 Usage

### 1. Initialization (Optional but Recommended)

Wrap your `MaterialApp` with `ToastDev` to enable context-free usage and set global defaults.

```dart
import 'package:toast_dev/toast.dev.dart';

void main() {
  runApp(
    ToastDev(
      position: ToastPosition.top,
      length: ToastLength.medium,
      child: MaterialApp(
        home: MyApp(),
      ),
    ),
  );
}
```

### 2. Basic Usage

Show a simple message toast from anywhere:

```dart
import 'package:toast_dev/toast.dev.dart';

// Context-free usage (requires ToastDev wrapper)
showToast(message: "Hello from Toast Dev! 👋");

// Or using context
showToast(context: context, message: "Hello!");
```

### 3. Custom Widget Toasts

Display your own beautiful UI as a toast:

```dart
showWidgetToast(
  child: ListTile(
    leading: Icon(Icons.celebration, color: Colors.deepOrange),
    title: Text('Congratulations!'),
    subtitle: Text('Highly customizable toasts are here.'),
  ),
);
```

### 4. Advanced Customization

```dart
showToast(
  message: "Premium Toast",
  backgroundColor: Colors.black87,
  shadowColor: Colors.black26,
  isClosable: true,
  length: ToastLength.long,
  position: ToastPosition.bottom,
  positionCurve: Curves.elasticOut,
  animationBuilder: (context, child, controller) {
    return FadeTransition(opacity: controller, child: child);
  },
);
```

---

## 🛠️ Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `message` | Text to display | `null` |
| `child` | Custom widget to display | `null` |
| `position` | `top` or `bottom` | `ToastPosition.top` |
| `length` | duration: `short`, `medium`, `long`, `ages`, `never` | `ToastLength.short` |
| `isClosable` | Show a close button | `false` |
| `backgroundColor` | Background color of the toast | `Theme` dependent |
| `animationDuration`| Duration of enter/exit animations | `1000ms` |
| `dismissDirection` | Direction to swipe for dismissal | `up` or `down` |

---

## 📋 Example

Check out the `example` folder for a complete demonstration of features.

```bash
cd example
flutter run
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

🏗️ *More updates and sleek animations coming soon!*