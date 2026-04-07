import 'package:equatable/equatable.dart';

class PaymentHistoryModel extends Equatable {
  final int id;
  final int receivedBy;
  final String receivedByName;
  final double amount;
  final double planPaidBefore;
  final double planPaidAfter;
  final String note;
  final bool isCancelled;
  final String? cancelledBy;
  final String? cancelledByName;
  final String? cancelledAt;
  final String createdAt;

  const PaymentHistoryModel({
    required this.id,
    required this.receivedBy,
    required this.receivedByName,
    required this.amount,
    required this.planPaidBefore,
    required this.planPaidAfter,
    required this.note,
    required this.isCancelled,
    this.cancelledBy,
    this.cancelledByName,
    this.cancelledAt,
    required this.createdAt,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      id: json['id'] as int? ?? 0,
      receivedBy: json['received_by'] as int? ?? 0,
      receivedByName: json['received_by_name']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      planPaidBefore: double.tryParse(json['plan_paid_before']?.toString() ?? '0') ?? 0.0,
      planPaidAfter: double.tryParse(json['plan_paid_after']?.toString() ?? '0') ?? 0.0,
      note: json['note']?.toString() ?? '',
      isCancelled: json['is_cancelled'] as bool? ?? false,
      cancelledBy: json['cancelled_by']?.toString(),
      cancelledByName: json['cancelled_by_name']?.toString(),
      cancelledAt: json['cancelled_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        receivedBy,
        receivedByName,
        amount,
        planPaidBefore,
        planPaidAfter,
        note,
        isCancelled,
        cancelledBy,
        cancelledByName,
        cancelledAt,
        createdAt,
      ];
}
