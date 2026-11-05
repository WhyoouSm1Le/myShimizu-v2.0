import 'package:myshimizu/data/app_storage.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override di main.dart'),
);

final appStorageProvider = Provider<AppStorage>(
  (ref) => AppStorage(ref.watch(sharedPreferencesProvider)),
);