import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'package:path_provider/path_provider.dart';

import 'export_partner_excel_event.dart';
import 'export_partner_excel_state.dart';

class ExportPartnerExcelBloc
    extends Bloc<ExportPartnerExcelEvent, ExportPartnerExcelState> {
  final PartnerReportRepository repository;

  ExportPartnerExcelBloc({required this.repository})
      : super(ExportPartnerExcelInitial()) {
    on<DownloadPartnerExcelRequested>(_onDownloadRequested);
  }

  Future<void> _onDownloadRequested(
    DownloadPartnerExcelRequested event,
    Emitter<ExportPartnerExcelState> emit,
  ) async {
    emit(ExportPartnerExcelLoading());
    try {
      final bytes = await repository.downloadPartnerExcel();

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      
      // Create a file in temporary directory
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/Mijozlar$timestamp.xlsx');
      
      // Write the bytes to the file
      await file.writeAsBytes(bytes);

      emit(ExportPartnerExcelSuccess(file.path));
    } catch (e) {
      emit(ExportPartnerExcelFailure(e.toString()));
    }
  }
}
