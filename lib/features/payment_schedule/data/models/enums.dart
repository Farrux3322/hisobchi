import 'package:flutter/material.dart';

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
  custom('custom');

  final String value;
  const PaymentScheduleType(this.value);

  String get label {
    switch (this) {
      case PaymentScheduleType.equal:
        return 'Teng ulushli';
      case PaymentScheduleType.custom:
        return 'Erkin';
    }
  }

  static PaymentScheduleType fromString(String value) {
    return PaymentScheduleType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentScheduleType.equal,
    );
  }
}

/// API dan keladigan status qiymatlari
enum InstallmentStatus {
  pending('pending'),
  near('near'),
  overdue('overdue'),
  partial('partial'),
  paid('paid');

  final String value;
  const InstallmentStatus(this.value);

  static InstallmentStatus fromString(String value) {
    return InstallmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InstallmentStatus.pending,
    );
  }

  Color get color {
    switch (this) {
      case InstallmentStatus.pending:
        return const Color(0xFF94A3B8); // kulrang
      case InstallmentStatus.near:
        return const Color(0xFFF59E0B); // sariq
      case InstallmentStatus.overdue:
        return const Color(0xFFEF4444); // qizil
      case InstallmentStatus.partial:
        return const Color(0xFF3B82F6); // ko'k
      case InstallmentStatus.paid:
        return const Color(0xFF22C55E); // yashil
    }
  }

  Color get backgroundColor {
    return color.withValues(alpha: 0.1);
  }

  String get label {
    switch (this) {
      case InstallmentStatus.pending:
        return 'Kutilmoqda';
      case InstallmentStatus.near:
        return 'Yaqinlashdi';
      case InstallmentStatus.overdue:
        return "Muddati o'tdi";
      case InstallmentStatus.partial:
        return 'Qisman to\'langan';
      case InstallmentStatus.paid:
        return "To'langan";
    }
  }
}

/// InstallmentPlan umumiy holati
enum InstallmentPlanStatus {
  active('active'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const InstallmentPlanStatus(this.value);

  static InstallmentPlanStatus fromString(String value) {
    return InstallmentPlanStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InstallmentPlanStatus.active,
    );
  }

  Color get color {
    switch (this) {
      case InstallmentPlanStatus.active:
        return const Color(0xFF3B82F6);
      case InstallmentPlanStatus.completed:
        return const Color(0xFF22C55E);
      case InstallmentPlanStatus.cancelled:
        return const Color(0xFF94A3B8);
    }
  }

  Color get backgroundColor {
    return color.withValues(alpha: 0.1);
  }

  String get label {
    switch (this) {
      case InstallmentPlanStatus.active:
        return 'Faol';
      case InstallmentPlanStatus.completed:
        return "To'liq to'langan";
      case InstallmentPlanStatus.cancelled:
        return 'Bekor qilingan';
    }
  }
}
