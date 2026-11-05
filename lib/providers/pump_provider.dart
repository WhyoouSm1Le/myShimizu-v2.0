import 'dart:async';
import 'dart:math' as math;

import 'package:myshimizu/models/pump_history.dart';
import 'package:myshimizu/providers/auth_provider.dart';
import 'package:myshimizu/providers/history_provider.dart';
import 'package:myshimizu/providers/storage_provider.dart';
import 'package:riverpod/riverpod.dart';

class PumpState {
  final DateTime? endAt;
  final DateTime now;

  const PumpState({this.endAt, required this.now});

  bool get pumpOn => endAt != null && endAt!.isAfter(now);

  int get remainingSeconds {
    final end = endAt;
    if (end == null) return 0;
    final ms = end.difference(now).inMilliseconds;
    return math.max(0, (ms / 1000).ceil());
  }
}

class PumpNotifier extends Notifier<PumpState> {
  Timer? _ticker;

  @override
  PumpState build() {
    ref.onDispose(() => _ticker?.cancel());

    final storage = ref.read(appStorageProvider);
    final end = storage.readPumpEnd();
    final now = DateTime.now();

    if (end != null) storage.savePumpEnd(null);
    return PumpState(now: now);
  }

  void start(int minutes) {
    final user = ref.read(authProvider);
    if (user == null) return;

    final startedAt = DateTime.now();
    final endAt = startedAt.add(Duration(minutes: minutes));

    state = PumpState(endAt: endAt, now: startedAt);
    ref.read(appStorageProvider).savePumpEnd(endAt);

    ref.read(historyProvider.notifier).add(
      PumpHistory(
        id: '${startedAt.millisecondsSinceEpoch}-${user.email}', 
        user: user.name, 
        startedAt: startedAt, 
        durationMinutes: minutes,
      )
    );
    _startTicker();
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    state = PumpState(now: DateTime.now());
    ref.read(appStorageProvider).savePumpEnd(null);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final end = state.endAt;
    if (end != null && !now.isBefore(end)) {
      stop();
      return;
    }
    state = PumpState(endAt: end, now: now);
  }
}

final pumpProvider = NotifierProvider<PumpNotifier, PumpState>(PumpNotifier.new);

final pumpOnProvider =
  Provider<bool>((ref) => ref.watch(pumpProvider.select((s) => s.pumpOn)));

final remainingSecondsProvider = Provider<int>(
  (ref) => ref.watch(pumpProvider.select((s) => s.remainingSeconds))
);