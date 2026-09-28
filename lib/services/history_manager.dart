import 'package:flutter/foundation.dart';
import '../models/country.dart';

class HistoryEntry {
  final Country country;
  final DateTime viewedAt;

  HistoryEntry({required this.country, required this.viewedAt});
}

class HistoryManager {
  static final HistoryManager _instance = HistoryManager._internal();
  factory HistoryManager() => _instance;
  HistoryManager._internal();

  final ValueNotifier<List<HistoryEntry>> historyNotifier =
      ValueNotifier<List<HistoryEntry>>([]);

  List<HistoryEntry> get history => historyNotifier.value;

  void addToHistory(Country country) {
    final currentList = List<HistoryEntry>.from(historyNotifier.value);
    currentList.insert(0, HistoryEntry(country: country, viewedAt: DateTime.now()));
    historyNotifier.value = currentList;
  }

  void removeEntry(HistoryEntry entry) {
    final currentList = List<HistoryEntry>.from(historyNotifier.value);
    currentList.remove(entry);
    historyNotifier.value = currentList;
  }

  void clearAll() {
    historyNotifier.value = [];
  }
}
