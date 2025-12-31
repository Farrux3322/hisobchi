import 'package:equatable/equatable.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/client_report_model.dart';

class ClientReportState extends Equatable {
  final Status status;
  final List<ClientReportPartner> partners;
  final String? errorMessage;
  final PartnerDetailReport? sectionTwoReport;
  final List<PartnerTransaction> transactions;
  final DateTime? startDate;
  final DateTime? endDate;

  const ClientReportState({
    this.status = Status.initial,
    this.partners = const [],
    this.errorMessage,
    this.sectionTwoReport,
    this.transactions = const [],
    this.startDate,
    this.endDate,
  });

  ClientReportState copyWith({
    Status? status,
    List<ClientReportPartner>? partners,
    String? errorMessage,
    PartnerDetailReport? sectionTwoReport,
    List<PartnerTransaction>? transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ClientReportState(
      status: status ?? this.status,
      partners: partners ?? this.partners,
      errorMessage: errorMessage,
      sectionTwoReport: sectionTwoReport ?? this.sectionTwoReport,
      transactions: transactions ?? this.transactions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [status, partners, errorMessage, sectionTwoReport, transactions, startDate, endDate];
}