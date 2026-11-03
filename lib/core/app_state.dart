import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';


const _kUser = 'aqua-user';
const _kHistory = 'aqua-pump-history';
const _kEnd = 'aqua-pump-end';
const _kAccounts = 'aqua-accounts';

//MODEL DATA & SERIALISASI JSON
class AppUser {
  const AppUser({required this.name, required this.email});
  final String name;
  final String email;

  Map<String, dynamic> toJson() => {'name': name, 'email': email};
  factory AppUser.fromJson(Map<String, dynamic> j) =>
      AppUser(name: j['name'] as String, email: j['email'] as String);
}


//MODEL DATA & SERIALISASI JSON
class PumpHistory {
  const PumpHistory({
    required this.id,
    required this.user,
    required this.startedAt,
    required this.durationMinutes
  });
  final String id;
  final String user;
  final DateTime startedAt;
  final int durationMinutes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'startedAt': startedAt.toIso8601String(),
    'durationMinutes': durationMinutes,
  };
factory PumpHistory.fromJSon(Map<String, dynamic> j) => PumpHistory(
    id: j['id'] as String, 
    user: j['user'] as String,  
    startedAt: DateTime.parse(j['startedAt'] as String), 
    durationMinutes: j['durationMinutes'] as int,
  );
}

List<PumpHistory> _initialHistory() {
  final now = DateTime.now();
  return [
    PumpHistory(
      id: 'activity-1', 
      user: 'Audrey Boren', 
      startedAt: now.subtract(const Duration(minutes: 42)), 
      durationMinutes: 15,
    ),
    PumpHistory(
      id: 'activity-2', 
      user: 'Alexander Graham', 
      startedAt: now.subtract(const Duration(minutes: 192)), 
      durationMinutes: 10,
    ),
    PumpHistory(
      id: 'activity-3', 
      user: 'Akame Murasame', 
      startedAt: now.subtract(const Duration(minutes: 25)), 
      durationMinutes: 20,
    ),
    PumpHistory(
      id: 'activity-4', 
      user: 'Ammar Assad', 
      startedAt: now.subtract(const Duration(minutes: 37)), 
      durationMinutes: 5,
    ),
  ];
}

class AppState extends ChangeNotifier{
  AppState._(this._prefs, this.user, this.history, this._pumpEnd) {
    if (_pumpEnd != null) _startTicker();
  }

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();

    AppUser? user;
    try {
      final raw = prefs.getString(_kUser);
      if (raw != null) {
        user = AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}

    var history = _initialHistory();
    try {
      final raw = prefs.getString(_kHistory);
      if (raw != null) {
        history = (jsonDecode(raw) as List)
            .map((e) => PumpHistory.fromJSon(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    DateTime? end;
    final endMs = prefs.getInt(_kEnd);
    if (endMs != null) {
      final d = DateTime.fromMillisecondsSinceEpoch(endMs);
      if (d.isAfter(DateTime.now())) {
        end = d;
      } else {
        await prefs.remove(_kEnd);
      }
    }

    return AppState._(prefs, user, history, end);
  }

  final SharedPreferences _prefs;
  AppUser? user;
  List<PumpHistory> history;
  DateTime? _pumpEnd;
  DateTime now = DateTime.now();
  Timer? _ticker;

  bool get pumpOn => _pumpEnd != null && _pumpEnd!.isAfter(now);

  int get remainingSeconds {
    final end = _pumpEnd;
    if (end == null) return 0;
    final ms = end.difference(now).inMilliseconds;
    return math.max(0, (ms / 1000).ceil());
  }

  void login(AppUser next) {
    user = next;
    _prefs.setString(_kUser, jsonEncode(next.toJson()));
    notifyListeners();
  }

  void logout() {
    user = null;
    _prefs.remove(_kUser);
    notifyListeners();
  }

  List<AppUser> _readAccounts() {
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

  AppUser? findAccount(String email) {
    for (final a in _readAccounts()) {
      if (a.email.toLowerCase() == email.toLowerCase()) return a;
    }
    return null;
  }

  void register(AppUser account) {
    final next = [
      account,
      ..._readAccounts()
          .where((a) => a.email.toLowerCase() != account.email.toLowerCase()),
    ];
    _prefs.setString(
      _kAccounts, jsonEncode(next.map((a) => a.toJson()).toList()));
    login(account);
  }

  void startPump(int minutes) {
    final u = user;
    if (u == null) return;
    final started = DateTime.now();
    now = started;
    _pumpEnd = started.add(Duration(minutes: minutes));
    _prefs.setInt(_kEnd, _pumpEnd!.millisecondsSinceEpoch);

    history = [
      PumpHistory(
        id: '${started.millisecondsSinceEpoch}-${u.email}', 
        user: u.name, 
        startedAt: started, 
        durationMinutes: minutes,
      ),
      ...history,
    ];
    _saveHistory();
    _startTicker();
    notifyListeners();
  }

  void stopPump() {
    _pumpEnd = null;
    _prefs.remove(_kEnd);
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  void _saveHistory() {
    _prefs.setString(
      _kHistory, jsonEncode(history.map((h) => h.toJson()).toList())
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void _tick() {
    now = DateTime.now();
    final end = _pumpEnd;
    if (end != null && !now.isBefore(end)) {
      _pumpEnd = null;
      _prefs.remove(_kEnd);
      _ticker?.cancel();
      _ticker = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child
  }) : super(notifier: state);
  
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan di widget tree');
    return scope!.notifier!;
  }
}

