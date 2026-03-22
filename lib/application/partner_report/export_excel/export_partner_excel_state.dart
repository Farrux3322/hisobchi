import 'package:equatable/equatable.dart';

abstract class ExportPartnerExcelState extends Equatable {
  const ExportPartnerExcelState();

  @override
  List<Object?> get props => [];
}

class ExportPartnerExcelInitial extends ExportPartnerExcelState {}

class ExportPartnerExcelLoading extends ExportPartnerExcelState {}

class ExportPartnerExcelSuccess extends ExportPartnerExcelState {
  final String filePath;

  const ExportPartnerExcelSuccess(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ExportPartnerExcelFailure extends ExportPartnerExcelState {
  final String error;

  const ExportPartnerExcelFailure(this.error);

  @override
  List<Object?> get props => [error];
}
