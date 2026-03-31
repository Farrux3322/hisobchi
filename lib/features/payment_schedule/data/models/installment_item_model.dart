import 'package:equatable/equatable.dart';
import 'enums.dart';

class InstallmentItemModel extends Equatable {
  final String id;
  final int index;
  final String label;
  final double amount;
  final DateTime dueDate;
  final bool isAdvance;
  final InstallmentStatus status;

  const InstallmentItemModel({
    required this.id,
    required this.index,
    required this.label,
    required this.amount,
    required this.dueDate,
    this.isAdvance = false,
    this.status = InstallmentStatus.pending,
  });

  factory InstallmentItemModel.fromJson(Map<String, dynamic> json) {
    return InstallmentItemModel(
      id: json['id']?.toString() ?? '',
      index: json['index'] as int? ?? 0,
      label: json['label']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'].toString())
          : DateTime.now(),
      isAdvance: json['isAdvance'] as bool? ?? false,
      status: json['status'] != null
          ? InstallmentStatus.fromString(json['status'].toString())
          : InstallmentStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
      'label': label,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'isAdvance': isAdvance,
      'status': status.value,
    };
  }

  InstallmentItemModel copyWith({
    String? id,
    int? index,
    String? label,
    double? amount,
    DateTime? dueDate,
    bool? isAdvance,
    InstallmentStatus? status,
  }) {
    return InstallmentItemModel(
      id: id ?? this.id,
      index: index ?? this.index,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isAdvance: isAdvance ?? this.isAdvance,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, index, label, amount, dueDate, isAdvance, status];
}
