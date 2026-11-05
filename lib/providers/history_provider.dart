import 'package:myshimizu/models/pump_history.dart';
import 'package:myshimizu/providers/storage_provider.dart';
import 'package:riverpod/riverpod.dart';

List<PumpHistory> _seedHistory() {
  final now = DateTime.now();
  return [
    PumpHistory(
      id: 'activity-1', 
      user: 'Rizky Pratama', 
      startedAt: now.subtract(const Duration(minutes: 42)), 
      durationMinutes: 15,
    ),
    PumpHistory(
      id: 'activity-2', 
      user: 'Dinda Putri', 
      startedAt: now.subtract(const Duration(minutes: 192)), 
      durationMinutes: 10,
    ),
    PumpHistory(
      id: 'activity-3', 
      user: 'Budi Santoso', 
      startedAt: now.subtract(const Duration(minutes: 25)), 
      durationMinutes: 20,
    ),
  ];
}

class HistoryNotifier extends Notifier<List<PumpHistory>> {
  @override
  List<PumpHistory> build() => 
    ref.watch(appStorageProvider).readHistory() ?? _seedHistory();

  void add(PumpHistory entry) {
    state = [entry, ...state];
    ref.read(appStorageProvider).saveHistory(state);
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, List<PumpHistory>>(HistoryNotifier.new);