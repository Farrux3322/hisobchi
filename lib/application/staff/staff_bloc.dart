import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/common/constants.dart';
import '../../infrastructure/repository/staff/staff_repository.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository repository;

  StaffBloc({required this.repository}) : super(const StaffState()) {
    on<StaffPermissionsFetch>(_onPermissionsFetch);
    on<StaffSendOtp>(_onSendOtp);
    on<StaffVerifyOtp>(_onVerifyOtp);
    on<StaffCreate>(_onCreate);
    on<StaffUpdate>(_onUpdate);
    on<StaffDelete>(_onDelete);
    on<StaffListFetch>(_onListFetch);
  }

  Future<void> _onPermissionsFetch(
    StaffPermissionsFetch event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading,errorMessage: '',statusAction: Status.initial));
    try {
      final response = await repository.getPermissions();
      emit(state.copyWith(
        status: Status.success,
        permissions: response.result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSendOtp(
    StaffSendOtp event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading, errorMessage: '', clearVerifyToken: true, lastAction: StaffActionType.sendOtp));
    try {
      final response = await repository.sendOtp(phone: event.phone);
      if (response['status'] == true) {
        emit(state.copyWith(statusAction: Status.success));
      } else {
        emit(state.copyWith(
          statusAction: Status.error,
          errorMessage: response['error']?['message'] ?? 'OTP yuborishda xatolik yuz berdi',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onVerifyOtp(
    StaffVerifyOtp event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading, errorMessage: '', clearVerifyToken: true, lastAction: StaffActionType.verifyOtp));
    try {
      final response = await repository.verifyOtp(
        phone: event.phone,
        otpCode: event.otpCode,
      );
      if (response['status'] == true) {
        emit(state.copyWith(
          statusAction: Status.success,
          verifyToken: response['result']['verify_token'],
        ));
      } else {
        emit(state.copyWith(
          statusAction: Status.error,
          errorMessage: response['result'] ?? 'Verification failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreate(
    StaffCreate event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading, errorMessage: '', clearVerifyToken: true, lastAction: StaffActionType.createStaff));
    try {
      final response = await repository.createStaff(
        phone: event.phone,
        verifyToken: event.verifyToken,
        name: event.name,
        password: event.password,
        permissions: event.permissions,
      );
      if (response['status'] == true) {
        emit(state.copyWith(statusAction: Status.success, clearVerifyToken: true));
        add(StaffListFetch());
      } else {
        emit(state.copyWith(
          statusAction: Status.error,
          errorMessage: response['result'] ?? 'Creation failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onListFetch(
    StaffListFetch event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, errorMessage: '', statusAction: Status.initial));
    try {
      final response = await repository.getStaffList();
      emit(state.copyWith(
        status: Status.success,
        staffList: response.result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdate(
    StaffUpdate event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading, errorMessage: '', lastAction: StaffActionType.updateStaff));
    try {
      final response = await repository.updateStaff(
        id: event.id,
        isActive: event.isActive,
        permissions: event.permissions,
      );
      if (response['status'] == true) {
        emit(state.copyWith(statusAction: Status.success));
        add(StaffListFetch());
      } else {
        emit(state.copyWith(
          statusAction: Status.error,
          errorMessage: response['result'] ?? 'Update failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(
    StaffDelete event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(statusAction: Status.loading, errorMessage: '', lastAction: StaffActionType.deleteStaff));
    try {
      final response = await repository.deleteStaff(event.id);
      if (response['status'] == true) {
        emit(state.copyWith(statusAction: Status.success));
        add(StaffListFetch());
      } else {
        emit(state.copyWith(
          statusAction: Status.error,
          errorMessage: response['result'] ?? 'Delete failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        statusAction: Status.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
