import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Preview item-lar uchun unique id generatori (manfiy, server id-lari musbat)
int _previewIdCounter = -1;
int _nextPreviewId() => _previewIdCounter--;

/// copyWith da null ni ifodalash uchun sentinel (nullable fieldlar uchun)
const Object _sentinel = Object();

class InstallmentItemModel extends Equatable {
  final int id;
  final int itemNumber;
  final bool isAdvance;
  final double amount;
  final double paidAmount;
  final double remaining;
  final String dueDate; // "2026-05-01" formatida
  final String? paidAt; // "02.05.2026 09:15" yoki null
  final InstallmentStatus status;
  final String statusLabel;
  final String? note;

  const InstallmentItemModel({
    required this.id,
    required this.itemNumber,
    required this.isAdvance,
    required this.amount,
    required this.paidAmount,
    required this.remaining,
    required this.dueDate,
    this.paidAt,
    required this.status,
    required this.statusLabel,
    this.note,
  });

  factory InstallmentItemModel.fromJson(Map<String, dynamic> json) {
    return InstallmentItemModel(
      id: json['id'] as int? ?? 0,
      itemNumber: json['item_number'] as int? ?? 0,
      isAdvance: json['is_advance'] as bool? ?? false,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0.0,
      remaining: double.tryParse(json['remaining']?.toString() ?? '0') ?? 0.0,
      dueDate: json['due_date']?.toString() ?? '',
      paidAt: json['paid_at']?.toString(),
      status: InstallmentStatus.fromString(json['status']?.toString() ?? 'pending'),
      statusLabel: json['status_label']?.toString() ?? '',
      note: json['note']?.toString(),
    );
  }

  /// Preview uchun (BLoC ichida qo'lda yaratiladi).
  /// Har bir item unique negative id oladi (server id-lari musbat bo'ladi).
  factory InstallmentItemModel.preview({
    required int itemNumber,
    required bool isAdvance,
    required double amount,
    required String dueDate,
  }) {
    return InstallmentItemModel(
      id: _nextPreviewId(),
      itemNumber: itemNumber,
      isAdvance: isAdvance,
      amount: amount,
      paidAmount: 0,
      remaining: amount,
      dueDate: dueDate,
      status: InstallmentStatus.pending,
      statusLabel: 'Kutilmoqda',
    );
  }

  String get label {
    if (isAdvance) return 'Avans';
    return '$itemNumber-qism';
  }

  bool get isPaid => status == InstallmentStatus.paid;
  bool get isPartial => status == InstallmentStatus.partial;

  InstallmentItemModel copyWith({
    int? id,
    int? itemNumber,
    bool? isAdvance,
    double? amount,
    double? paidAmount,
    double? remaining,
    String? dueDate,
    String? paidAt,
    InstallmentStatus? status,
    String? statusLabel,
    Object? note = _sentinel,
  }) {
    return InstallmentItemModel(
      id: id ?? this.id,
      itemNumber: itemNumber ?? this.itemNumber,
      isAdvance: isAdvance ?? this.isAdvance,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      remaining: remaining ?? this.remaining,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      note: note == _sentinel ? this.note : note as String?,
    );
  }

  @override
  List<Object?> get props => [id, itemNumber, isAdvance, amount, paidAmount, remaining, dueDate, paidAt, status, statusLabel, note];
}
