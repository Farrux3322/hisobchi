import 'package:equatable/equatable.dart';

abstract class ExportPartnerExcelEvent extends Equatable {
  const ExportPartnerExcelEvent();

  @override
  List<Object?> get props => [];
}

class DownloadPartnerExcelRequested extends ExportPartnerExcelEvent {}
