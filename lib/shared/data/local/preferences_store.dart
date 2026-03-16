import 'package:hive/hive.dart';

class PreferencesStore {
  PreferencesStore(this._box);

  final Box<dynamic> _box;

  static const String themeModeKey = 'theme_mode';

  String? getThemeMode() => _box.get(themeModeKey) as String?;

  Future<void> setThemeMode(String value) => _box.put(themeModeKey, value);
}
