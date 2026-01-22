part of 'partner_details_report_cubit.dart';

abstract class PartnerDetailsReportState {}

class PartnerDetailsReportInitial extends PartnerDetailsReportState {}

class PartnerDetailsReportLoading extends PartnerDetailsReportState {}

class PartnerDetailsReportLoaded extends PartnerDetailsReportState {
  final PartnerDetailsResult result;
  PartnerDetailsReportLoaded(this.result);
}

class PartnerDetailsReportError extends PartnerDetailsReportState {
  final String message;
  PartnerDetailsReportError(this.message);
}
