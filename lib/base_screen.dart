// lib/base_screen.dart
import 'package:flutter/material.dart';
import 'translations.dart';

/// Base class for all screens that need translation support
abstract class BaseScreenState<T extends StatefulWidget> extends State<T> {
  /// Get translated text for the current language
  String getText(String key) {
    try {
      final language = (widget as dynamic).currentLanguage as String;
      return Translations.getText(language, key);
    } catch (e) {
      return Translations.getText('English', key);
    }
  }
}
