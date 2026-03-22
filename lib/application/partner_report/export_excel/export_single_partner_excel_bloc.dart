import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';
import 'package:path_provider/path_provider.dart';

import 'export_single_partner_excel_event.dart';
import 'export_single_partner_excel_state.dart';

class ExportSinglePartnerExcelBloc
    extends Bloc<ExportSinglePartnerExcelEvent, ExportSinglePartnerExcelState> {
  final PartnerReportRepository repository;

  ExportSinglePartnerExcelBloc({required this.repository})
      : super(ExportSinglePartnerExcelInitial()) {
    on<DownloadSinglePartnerExcelRequested>(_onDownloadRequested);
  }

  Future<void> _onDownloadRequested(
    DownloadSinglePartnerExcelRequested event,
    Emitter<ExportSinglePartnerExcelState> emit,
  ) async {
    emit(ExportSinglePartnerExcelLoading());
    try {
      final bytes = await repository.downloadSinglePartnerExcel(event.partnerId);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      
      // Create a file in temporary directory
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/Hamkor_Hisoboti_${event.partnerId}_$timestamp.xlsx');
      
      // Write the bytes to the file
      await file.writeAsBytes(bytes);

      emit(ExportSinglePartnerExcelSuccess(file.path));
    } catch (e) {
      emit(ExportSinglePartnerExcelFailure(e.toString()));
    }
  }
}
