import 'package:hive_flutter/hive_flutter.dart';

import '../../constants/constants.dart';

class HiveHelper {
  static final Box _appBox = Hive.box(kHabitDatabase);

  static Box get appBox => _appBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(kHabitDatabase);
  }
  //===============================================================

  static Future<void> cacheTheme({required bool? value}) async {
    await _appBox.put(kIsDark, value);
  }

  static Future<bool?> get getTheme async {
    bool? isDark;
    if (_appBox.containsKey(kIsDark)) {
      isDark = _appBox.get(kIsDark);
    }
    return isDark;
  }

  //===============================================================

  static Future<void> write({
    required String key,
    required dynamic value,
  }) async =>
      await _appBox.put(key, value);

  static dynamic read({required String key}) async => await _appBox.get(key);

  static bool hasData({required String key}) => _appBox.containsKey(key);
}
