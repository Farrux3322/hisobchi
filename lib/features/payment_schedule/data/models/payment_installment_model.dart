import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'installment_item_model.dart';

class PaymentInstallmentModel extends Equatable {
  final String id;
  final String partnerName;
  final double totalAmount;
  final PaymentCurrency currency;
  final String? note;
  final PaymentScheduleType type;
  final List<InstallmentItemModel> installments;
  final DateTime createdAt;

  const PaymentInstallmentModel({
    required this.id,
    required this.partnerName,
    required this.totalAmount,
    required this.currency,
    this.note,
    required this.type,
    required this.installments,
    required this.createdAt,
  });

  factory PaymentInstallmentModel.fromJson(Map<String, dynamic> json) {
    return PaymentInstallmentModel(
      id: json['id']?.toString() ?? '',
      partnerName: json['partnerName']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] != null
          ? PaymentCurrency.fromString(json['currency'].toString())
          : PaymentCurrency.uzs,
      note: json['note']?.toString(),
      type: json['type'] != null
          ? PaymentScheduleType.fromString(json['type'].toString())
          : PaymentScheduleType.equal,
      installments: (json['installments'] as List<dynamic>?)
              ?.map((e) => InstallmentItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerName': partnerName,
      'totalAmount': totalAmount,
      'currency': currency.value,
      'note': note,
      'type': type.value,
      'installments': installments.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PaymentInstallmentModel copyWith({
    String? id,
    String? partnerName,
    double? totalAmount,
    PaymentCurrency? currency,
    String? note,
    PaymentScheduleType? type,
    List<InstallmentItemModel>? installments,
    DateTime? createdAt,
  }) {
    return PaymentInstallmentModel(
      id: id ?? this.id,
      partnerName: partnerName ?? this.partnerName,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      type: type ?? this.type,
      installments: installments ?? this.installments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<PaymentInstallmentModel> get mockList => [
        PaymentInstallmentModel(
          id: '1',
          partnerName: 'Aziz Toshmatov',
          totalAmount: 18500000,
          currency: PaymentCurrency.uzs,
          note: 'Qurilish materiallari',
          type: PaymentScheduleType.equal,
          installments: [
            InstallmentItemModel(
              id: '1-1',
              index: 0,
              label: 'Avans',
              amount: 4500000,
              dueDate: DateTime(2026, 3, 1),
              isAdvance: true,
              status: InstallmentStatus.paid,
            ),
            InstallmentItemModel(
              id: '1-2',
              index: 1,
              label: '1-qism',
              amount: 4625000,
              dueDate: DateTime(2026, 4, 1),
              status: InstallmentStatus.pending,
            ),
            InstallmentItemModel(
              id: '1-3',
              index: 2,
              label: '2-qism',
              amount: 4625000,
              dueDate: DateTime(2026, 5, 1),
              status: InstallmentStatus.pending,
            ),
            InstallmentItemModel(
              id: '1-4',
              index: 3,
              label: '3-qism',
              amount: 4750000,
              dueDate: DateTime(2026, 6, 1),
              status: InstallmentStatus.pending,
            ),
          ],
          createdAt: DateTime(2026, 2, 15),
        ),
      ];

  @override
  List<Object?> get props => [
        id,
        partnerName,
        totalAmount,
        currency,
        note,
        type,
        installments,
        createdAt,
      ];
}
