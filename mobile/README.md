# ✨ Quickstart ✨

## ⬇️ Get dependencies ⬇️

```bash
flutter pub get
```

## 🧊 Generate Freezed & JSON Files 🧊

After installing dependencies, generate the required Freezed and JSON serialization files:

- `One-time generation`

```bash
dart run build_runner build --delete-conflicting-outputs
```

- `Watch mode (auto-regenerate on file changes)`

```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## 🚀 Run the app 🚀

- `macOS, iOS`

```bash
open ios/Runner.xcworkspace
```

```bash
xcrun simctl list devices
xcrun simctl boot "iPhone 17"
```

```bash
open -a Simulator
```

```bash
flutter run
```

---

## 🧹 Format & Lint 🧹

```bash
dart analyze
```

```bash
dart format .
```
