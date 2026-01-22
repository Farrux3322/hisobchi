import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/infrastructure/models/partner_details_report_model.dart';
import 'package:hisobchi/infrastructure/repository/partner_report/partner_report_repository.dart';

part 'partner_details_report_state.dart';

class PartnerDetailsReportCubit extends Cubit<PartnerDetailsReportState> {
  final PartnerReportRepository _repository;

  PartnerDetailsReportCubit(this._repository) : super(PartnerDetailsReportInitial());

  Future<void> getPartnerDetailsReport(int partnerId) async {
    emit(PartnerDetailsReportLoading());
    try {
      final response = await _repository.getPartnerDetailsReport(partnerId);
      if (response.status) {
        emit(PartnerDetailsReportLoaded(response.result));
      } else {
        emit(PartnerDetailsReportError('Ma\'lumotlarni yuklashda xatolik yuz berdi'));
      }
    } catch (e) {
      emit(PartnerDetailsReportError(e.toString()));
    }
  }
}
