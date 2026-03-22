import 'package:equatable/equatable.dart';

abstract class ExportSinglePartnerExcelState extends Equatable {
  const ExportSinglePartnerExcelState();

  @override
  List<Object?> get props => [];
}

class ExportSinglePartnerExcelInitial extends ExportSinglePartnerExcelState {}

class ExportSinglePartnerExcelLoading extends ExportSinglePartnerExcelState {}

class ExportSinglePartnerExcelSuccess extends ExportSinglePartnerExcelState {
  final String filePath;

  const ExportSinglePartnerExcelSuccess(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ExportSinglePartnerExcelFailure extends ExportSinglePartnerExcelState {
  final String error;

  const ExportSinglePartnerExcelFailure(this.error);

  @override
  List<Object?> get props => [error];
}
