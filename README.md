# Daily Quran - Mobile App

A beautiful and feature-rich Flutter application for daily Quran reading, reflection, and spiritual growth. Access the Quran with translations, tafsir, reading history, and essential Islamic tools all in one place.

## ✨ Features

### Core Quran Features
- 📖 **Complete Quran Access** - Browse all 114 Surahs with full text and translations
- 🔍 **Smart Search** - Search by surah name, number, or Arabic text
- ⭐ **Favorites Management** - Bookmark individual ayahs and organize your favorites
- 📝 **Reading Progress Tracking** - Monitor your daily reading and maintain reading history
- 📊 **Statistics Dashboard** - View detailed reading statistics and insights
- 📚 **Tafsir Support** - Access verse explanations and deeper spiritual understanding

### Additional Tools
- 🧭 **Qibla Compass** - Find the direction of Qibla prayer
- 🤲 **Duas Collection** - Browse and reference authentic Islamic duas
- ⚙️ **Customizable Settings** - Personalize your reading experience
- 🌓 **Theme Support** - Light and dark mode for comfortable reading
- 🌍 **Multi-language Support** - Interface available in multiple languages

## 📋 Requirements

- **Flutter SDK**: Compatible with Dart 3.11.5 or later
- **Development Tools**: Android Studio or Xcode
- **Device**: Connected emulator or physical device (Android/iOS)
- **RAM**: Minimum 4GB recommended

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Daily-Quran-Mobile-App-in-Flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🧪 Testing & Quality Checks

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── auth_service.dart         # Authentication logic
├── base_screen.dart          # Base screen widget
├── home_screen.dart          # Main home screen
├── quran.dart                # Quran data and logic
├── dua_tab.dart              # Duas screen
├── qibla_compass_screen.dart # Qibla direction tool
├── prayer_times_screen.dart  # Prayer times display
├── stats.dart                # Statistics tracking
├── history_screen.dart       # Reading history
├── settings_tab.dart         # Settings configuration
├── translations.dart         # Multi-language support
├── login_screen.dart         # Authentication UI
├── splash_screen.dart        # App splash screen
└── [other screens]           # Additional feature screens

assets/
├── quran_data.json           # Complete Quran data
├── quran.json                # Alternative Quran format
└── [images & icons]          # App assets

test/
└── widget_test.dart          # Widget tests

android/, ios/, web/, windows/, macos/, linux/
└── Platform-specific runners and configurations
```

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.11.5+
- **State Management**: [Provider/GetX/Riverpod - update as applicable]
- **Data Storage**: Local JSON assets and SQLite
- **Geolocation**: Sensors Plus, URL Launcher
- **Authentication**: Firebase/Custom Auth

## 📦 Key Dependencies

- `sensors_plus` - Compass sensor access
- `shared_preferences_android` - Local preferences
- `url_launcher_android` - Launch external URLs
- [Add other major dependencies]

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Quran data sourced from [data source]
- Islamic content verified by [verification source]
- Contributors and the Flutter community

## 📞 Support

For issues, feature requests, or questions, please open an issue on GitHub or contact the development team.

---

**Happy Reading! May this app bring you closer to the Quran and its wisdom.** 📖✨
