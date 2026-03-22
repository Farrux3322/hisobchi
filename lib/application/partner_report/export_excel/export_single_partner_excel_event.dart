import 'package:equatable/equatable.dart';

abstract class ExportSinglePartnerExcelEvent extends Equatable {
  const ExportSinglePartnerExcelEvent();

  @override
  List<Object?> get props => [];
}

class DownloadSinglePartnerExcelRequested extends ExportSinglePartnerExcelEvent {
  final int partnerId;

  const DownloadSinglePartnerExcelRequested(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}
