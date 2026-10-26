/// How urgent a stock alert is. The order of the values is the display order:
/// critical first, low last.
enum Severity { critical, high, medium, low }

/// One stock alert for one branch, as sent by Nour head office.
///
/// Immutable: a change creates a new object through [copyWith].
final class StockAlert {
  const StockAlert({
    required this.id,
    required this.medicineNameEn,
    required this.medicineNameAr,
    required this.severity,
    required this.daysOfCover,
    required this.branchCode,
    this.acknowledged = false,
  });

  final String id;
  final String medicineNameEn;
  final String medicineNameAr;
  final Severity severity;
  final double daysOfCover;
  final String branchCode;
  final bool acknowledged;

  factory StockAlert.fromJson(Map<String, Object?> json) {
    final rawId = json['id'];
    if (rawId is! String || rawId.isEmpty) {
      throw FormatException('id must be a non-empty String', rawId);
    }

    final rawEn = json['medicineNameEn'];
    if (rawEn is! String || rawEn.isEmpty) {
      throw FormatException('medicineNameEn must be a non-empty String', rawEn);
    }

    final rawAr = json['medicineNameAr'];
    if (rawAr is! String || rawAr.isEmpty) {
      throw FormatException('medicineNameAr must be a non-empty String', rawAr);
    }

    final rawBranch = json['branchCode'];
    if (rawBranch is! String || rawBranch.isEmpty) {
      throw FormatException('branchCode must be a non-empty String', rawBranch);
    }

    final rawSeverity = json['severity'];
    if (rawSeverity is! String) {
      throw FormatException('severity must be a String', rawSeverity);
    }
    final Severity severity;
    switch (rawSeverity.toLowerCase()) {
      case 'critical':
        severity = Severity.critical;
      case 'high':
        severity = Severity.high;
      case 'medium':
        severity = Severity.medium;
      case 'low':
        severity = Severity.low;
      default:
        throw FormatException(
            'severity must be one of critical/high/medium/low', rawSeverity);
    }

    final rawDays = json['daysOfCover'];
    if (rawDays is! num) {
      throw FormatException('daysOfCover must be a num', rawDays);
    }
    if (rawDays < 0 || rawDays.isNaN) {
      throw FormatException('daysOfCover must be >= 0', rawDays);
    }

    final rawAck = json['acknowledged'];
    final bool acknowledged;
    if (rawAck == null) {
      acknowledged = false;
    } else if (rawAck is bool) {
      acknowledged = rawAck;
    } else {
      throw FormatException('acknowledged must be a bool if present', rawAck);
    }

    return StockAlert(
      id: rawId,
      medicineNameEn: rawEn,
      medicineNameAr: rawAr,
      severity: severity,
      daysOfCover: rawDays.toDouble(),
      branchCode: rawBranch,
      acknowledged: acknowledged,
    );
  }

  StockAlert copyWith({
    String? id,
    String? medicineNameEn,
    String? medicineNameAr,
    Severity? severity,
    double? daysOfCover,
    String? branchCode,
    bool? acknowledged,
  }) {
    return StockAlert(
      id: id ?? this.id,
      medicineNameEn: medicineNameEn ?? this.medicineNameEn,
      medicineNameAr: medicineNameAr ?? this.medicineNameAr,
      severity: severity ?? this.severity,
      daysOfCover: daysOfCover ?? this.daysOfCover,
      branchCode: branchCode ?? this.branchCode,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StockAlert) return false;
    return id == other.id &&
        medicineNameEn == other.medicineNameEn &&
        medicineNameAr == other.medicineNameAr &&
        severity == other.severity &&
        daysOfCover == other.daysOfCover &&
        branchCode == other.branchCode &&
        acknowledged == other.acknowledged;
  }

  @override
  int get hashCode => Object.hash(
        id,
        medicineNameEn,
        medicineNameAr,
        severity,
        daysOfCover,
        branchCode,
        acknowledged,
      );
}