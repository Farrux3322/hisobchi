import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'installment_item_model.dart';

class InstallmentFileModel extends Equatable {
  final int id;
  final String url;

  const InstallmentFileModel({required this.id, required this.url});

  factory InstallmentFileModel.fromJson(Map<String, dynamic> json) {
    return InstallmentFileModel(
      id: json['id'] as int? ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }

  bool get isImage {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.jpg') || lowerUrl.endsWith('.jpeg') || lowerUrl.endsWith('.png') || lowerUrl.endsWith('.webp') || lowerUrl.contains('image_picker');
  }

  @override
  List<Object?> get props => [id, url];
}

class InstallmentPlanModel extends Equatable {
  final int id;
  final int partnerId;
  final String partnerName;
  final int currencyTypeId;
  final String currencyTypeName;
  final double totalAmount;
  final double paidAmount;
  final double remaining;
  final PaymentScheduleType scheduleType;
  final bool hasAdvance;
  final double? advanceAmount;
  final String? startDate;
  final String? note;
  final List<InstallmentFileModel> files;
  final InstallmentPlanStatus status;
  final String statusLabel;
  final List<InstallmentItemModel> items;
  final int? itemsCount;
  final String createdAt;
  final String? activity;

  const InstallmentPlanModel({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.currencyTypeId,
    required this.currencyTypeName,
    required this.totalAmount,
    required this.paidAmount,
    required this.remaining,
    required this.scheduleType,
    required this.hasAdvance,
    this.advanceAmount,
    this.startDate,
    this.note,
    required this.files,
    required this.status,
    required this.statusLabel,
    required this.items,
    this.itemsCount,
    required this.createdAt,
    this.activity,
  });

  factory InstallmentPlanModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final List<InstallmentItemModel> items = (rawItems is List && rawItems.isNotEmpty) ? rawItems.map((e) => InstallmentItemModel.fromJson(e as Map<String, dynamic>)).toList() : [];

    final rawFiles = json['files'];
    final List<InstallmentFileModel> files = (rawFiles is List && rawFiles.isNotEmpty) ? rawFiles.map((e) => InstallmentFileModel.fromJson(e as Map<String, dynamic>)).toList() : [];

    return InstallmentPlanModel(
      id: json['id'] as int? ?? 0,
      partnerId: json['partner_id'] as int? ?? 0,
      partnerName: json['partner_name']?.toString() ?? '',
      currencyTypeId: json['currency_type_id'] as int? ?? 1,
      currencyTypeName: json['currency_type_name']?.toString() ?? 'UZS',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0.0,
      remaining: double.tryParse(json['remaining']?.toString() ?? '0') ?? 0.0,
      scheduleType: PaymentScheduleType.fromString(json['schedule_type']?.toString() ?? 'equal'),
      hasAdvance: json['has_advance'] as bool? ?? false,
      advanceAmount: json['advance_amount'] != null ? double.tryParse(json['advance_amount'].toString()) : null,
      startDate: json['start_date']?.toString(),
      note: json['note']?.toString(),
      files: files,
      status: InstallmentPlanStatus.fromString(json['status']?.toString() ?? 'active'),
      statusLabel: json['status_label']?.toString() ?? '',
      items: items,
      itemsCount: json['items_count'] as int?,
      createdAt: json['created_at']?.toString() ?? '',
      activity: json['activity']?.toString(),
    );
  }

  PaymentCurrency get currency => PaymentCurrency.fromString(currencyTypeName);

  bool get isActive => status == InstallmentPlanStatus.active;
  bool get isCompleted => status == InstallmentPlanStatus.completed;
  bool get isCancelled => status == InstallmentPlanStatus.cancelled;

  int get totalCount => itemsCount ?? items.length;

  int get paidCount => items.where((i) => i.isPaid).length;

  /// Pending yoki muddati o'tgan qismlar soni (ro'yxatda ko'rsatish uchun)
  int get pendingCount => items.where((i) => !i.isPaid).length;

  @override
  List<Object?> get props => [id, partnerId, partnerName, currencyTypeId, totalAmount, paidAmount, remaining, scheduleType, hasAdvance, advanceAmount, startDate, note, files, status, statusLabel, items, itemsCount, createdAt, activity];
}
