enum PaymentCurrency {
  uzs('UZS'),
  usd('USD');

  final String value;
  const PaymentCurrency(this.value);

  static PaymentCurrency fromString(String value) {
    return PaymentCurrency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentCurrency.uzs,
    );
  }
}

enum PaymentScheduleType {
  equal('equal'),
  free('free');

  final String value;
  const PaymentScheduleType(this.value);

  static PaymentScheduleType fromString(String value) {
    return PaymentScheduleType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentScheduleType.equal,
    );
  }
}

enum InstallmentStatus {
  pending('pending'),
  paid('paid'),
  overdue('overdue');

  final String value;
  const InstallmentStatus(this.value);

  static InstallmentStatus fromString(String value) {
    return InstallmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InstallmentStatus.pending,
    );
  }
}
