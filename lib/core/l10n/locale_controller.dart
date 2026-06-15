import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:hospital_app/l10n/app_localizations.dart';

/// Holds the app's current [Locale] and notifies listeners when it changes,
/// mirroring the global `themeController` pattern. The chosen language is also
/// cached locally so the selection survives an app restart (even offline),
/// while the backend settings remain the source of truth once signed in.
class LocaleController extends ChangeNotifier {
  LocaleController() {
    _restore();
  }

  static const _storageKey = 'app_locale';
  static const _storage = FlutterSecureStorage();

  /// `null` means "follow the system locale" until a choice is restored/made.
  Locale? _locale;

  Locale? get locale => _locale;

  /// The active language code (`vi` / `en`), falling back to `vi`.
  String get languageCode => _locale?.languageCode ?? 'vi';

  Future<void> _restore() async {
    try {
      final code = await _storage.read(key: _storageKey);
      if (code != null && code.isNotEmpty) {
        _applyCode(code, persist: false);
      }
    } catch (_) {
      // Ignore storage errors — fall back to the default locale.
    }
  }

  /// Sets the locale from a language code (e.g. `vi`, `en`). No-op if the code
  /// is unsupported or already active.
  void setLanguageCode(String code) => _applyCode(code, persist: true);

  void _applyCode(String code, {required bool persist}) {
    final supported = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .toSet();
    if (!supported.contains(code)) {
      return;
    }
    if (_locale?.languageCode == code) {
      return;
    }
    _locale = Locale(code);
    notifyListeners();
    if (persist) {
      _storage.write(key: _storageKey, value: code).catchError((_) {});
    }
  }
}

/// Global instance for simple access (mirrors `themeController`).
final localeController = LocaleController();

/// Context-free access to the generated strings for the current locale.
/// Use this in the data/provider layers where no [BuildContext] is available
/// (e.g. repositories, notifiers). UI code should prefer `context.l10n`.
AppLocalizations get appL10n =>
    lookupAppLocalizations(Locale(localeController.languageCode));

/// Convenient access to the generated strings: `context.l10n.someKey`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
