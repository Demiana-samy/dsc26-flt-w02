import 'package:flutter/foundation.dart';

import '../../../data/repositories/alert_repository.dart';
import '../../../domain/models/stock_alert.dart';

class AlertsViewModel extends ChangeNotifier {
  AlertsViewModel({required AlertRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository;

  final AlertRepository _repository;

  List<StockAlert> _alerts = const [];
  final Set<Severity> _activeFilters = {};
  String _query = ''; // already normalised
  bool _loading = false;
  bool _disposed = false;

  bool get loading => _loading;
  Set<Severity> get activeFilters => Set.unmodifiable(_activeFilters);

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _alerts = List.of(await _repository.fetchAlerts());
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<StockAlert> get visibleAlerts {
    final result = _alerts.where((a) {
      if (_activeFilters.isNotEmpty && !_activeFilters.contains(a.severity)) {
        return false;
      }
      if (_query.isEmpty) return true;
      return _normalise(a.medicineNameEn).contains(_query) ||
          _normalise(a.medicineNameAr).contains(_query);
    }).toList();
    result.sort(_compare);
    return List.unmodifiable(result);
  }

  int get unacknowledgedCriticalCount => _alerts
      .where((a) => a.severity == Severity.critical && !a.acknowledged)
      .length;

  void toggleFilter(Severity s) {
    if (!_activeFilters.remove(s)) _activeFilters.add(s);
    notifyListeners();
  }

  void setQuery(String q) {
    final n = _normalise(q);
    if (n == _query) return;
    _query = n;
    notifyListeners();
  }

  Future<void> acknowledge(String id) async {
    if (!_alerts.any((a) => a.id == id)) return;
    await _repository.acknowledge(id);
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index < 0) return;
    final updated = List.of(_alerts);
    updated[index] = updated[index].copyWith(acknowledged: true);
    _alerts = updated;
    notifyListeners();
  }

  static int _compare(StockAlert a, StockAlert b) {
    if (a.acknowledged != b.acknowledged) return a.acknowledged ? 1 : -1;
    final bySeverity = a.severity.index.compareTo(b.severity.index);
    if (bySeverity != 0) return bySeverity;
    final byDays = a.daysOfCover.compareTo(b.daysOfCover);
    if (byDays != 0) return byDays;
    return a.medicineNameEn
        .toLowerCase()
        .compareTo(b.medicineNameEn.toLowerCase());
  }

  // tatweel U+0640 and diacritics U+064B..U+0652 (inclusive, nothing more)
  static final RegExp _marks = RegExp('[\u0640\u064B-\u0652]');
  static final RegExp _alef = RegExp('[\u0623\u0625\u0622]');

  static String _normalise(String s) {
    return s
        .toLowerCase()
        .replaceAll(_marks, '')
        .replaceAll(_alef, '\u0627')
        .replaceAll('\u0629', '\u0647')
        .replaceAll('\u0649', '\u064A')
        .trim();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
