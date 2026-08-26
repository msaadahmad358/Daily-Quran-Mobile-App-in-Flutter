# Daily Quran

Daily Quran is a Flutter app designed to support everyday Quran reading and reflection.

## Features

- Browse and search the Quran by surah name, language, or number
- Read Arabic verses with translations and tafsir
- Mark individual ayahs as favorites and manage them from the favorites screen
- Track reading progress and review reading history and statistics
- Use the Qibla compass
- Browse duas and manage app settings
- Support for light and dark themes and multiple languages

## Requirements

- Flutter SDK compatible with Dart `3.11.5` or later
- Android Studio or Xcode for mobile builds
- A connected emulator or physical device

## Setup

```bash
flutter pub get
flutter run
```

The Quran data is bundled in `assets/quran_data.json` and is registered through
the asset configuration in `pubspec.yaml`.

## Checks

```bash
flutter analyze
flutter test
```

## Project Structure

- `lib/` contains the Flutter screens and application logic
- `assets/` contains Quran data and app images
- `test/` contains Flutter widget tests
- `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/` contain platform runners
