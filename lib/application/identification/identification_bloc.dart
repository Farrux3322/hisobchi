import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hisobchi/infrastructure/repository/identification/identification_repository.dart';

part 'identification_event.dart';
part 'identification_state.dart';

class IdentificationBloc extends Bloc<IdentificationEvent, IdentificationState> {
  final IdentificationRepository _repository;

  IdentificationBloc(this._repository) : super(const IdentificationState()) {
    on<StartMyIdEvent>((event, emit) {
      emit(state.copyWith(status: IdentificationStatus.myIdStarted));
    });

    on<IdentityVerifiedEvent>(_onIdentityVerified);
    
    on<IdentityErrorEvent>((event, emit) {
      emit(state.copyWith(status: IdentificationStatus.error, errorMessage: event.message));
    });

    on<ResetIdentificationEvent>((event, emit) {
      emit(const IdentificationState());
    });
  }

  Future<void> _onIdentityVerified(IdentityVerifiedEvent event, Emitter<IdentificationState> emit) async {
    emit(state.copyWith(status: IdentificationStatus.verifying));
    try {
      final result = await _repository.verifyIdentity(event.code);
      if (result['status'] == true) {
        emit(state.copyWith(status: IdentificationStatus.success));
      } else {
        emit(state.copyWith(
          status: IdentificationStatus.error, 
          errorMessage: result['message'] ?? 'Verifikatsiya jarayonida xatolik yuz berdi',
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: IdentificationStatus.error, errorMessage: e.toString()));
    }
  }
}
