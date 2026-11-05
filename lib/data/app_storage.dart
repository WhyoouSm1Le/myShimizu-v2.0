import 'dart:convert';

import 'package:myshimizu/models/app_user.dart';
import 'package:myshimizu/models/pump_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  final SharedPreferences _prefs;

  AppStorage(this._prefs);

  static const _kUser = 'shimizu-user';
  static const _kAccounts = 'shimizu-accounts';
  static const _kHistory = 'shimizu-pump-history';
  static const _kPumpEnd= 'shimizu-pump-end';

  AppUser? readUser() {
    try {
      final raw = _prefs.getString(_kUser);
      if (raw == null) return null;
      return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(AppUser? user) async {
    if (user == null) {
      await _prefs.remove(_kUser);
    } else {
      await _prefs.setString(_kUser, jsonEncode(user.toJson()));
    }
  }

  List<AppUser> readAccounts() {
    try {
      final raw = _prefs.getString(_kAccounts);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAccounts(List<AppUser> accounts) => _prefs.setString(
    _kAccounts, 
    jsonEncode(accounts.map((a) => a.toJson()).toList()),
  );

  List<PumpHistory>? readHistory() {
    try {
      final raw = _prefs.getString(_kHistory);
      if (raw == null) return null;
      return (jsonDecode(raw) as List)
          .map((e) => PumpHistory.fromJSon(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveHistory(List<PumpHistory> history) => _prefs.setString(
    _kHistory, 
    jsonEncode(history.map((h) => h.toJson()).toList()),
  );

  DateTime? readPumpEnd() {
    final ms = _prefs.getInt(_kPumpEnd);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> savePumpEnd(DateTime? end) async {
    if (end == null) {
      await _prefs.remove(_kPumpEnd);
    } else {
      await _prefs.setInt(_kPumpEnd, end.millisecondsSinceEpoch);
    }
  }
}