import 'package:equatable/equatable.dart';
import '../../domain/common/constants.dart';
import '../../infrastructure/models/permission_model.dart';
import '../../infrastructure/models/staff_model.dart';

enum StaffActionType { none, sendOtp, verifyOtp, createStaff, updateStaff, deleteStaff }

class StaffState extends Equatable {
  final Status status;
  final Status statusAction;
  final StaffActionType lastAction;
  final List<PermissionGroupModel> permissions;
  final List<StaffModel> staffList;
  final String? verifyToken;
  final String? errorMessage;

  const StaffState({
    this.status = Status.initial,
    this.statusAction = Status.initial,
    this.lastAction = StaffActionType.none,
    this.permissions = const [],
    this.staffList = const [],
    this.verifyToken,
    this.errorMessage,
  });

  StaffState copyWith({
    Status? status,
    Status? statusAction,
    StaffActionType? lastAction,
    List<PermissionGroupModel>? permissions,
    List<StaffModel>? staffList,
    String? verifyToken,
    String? errorMessage,
    bool clearVerifyToken = false,
  }) {
    return StaffState(
      status: status ?? this.status,
      statusAction: statusAction ?? this.statusAction,
      lastAction: lastAction ?? this.lastAction,
      permissions: permissions ?? this.permissions,
      staffList: staffList ?? this.staffList,
      verifyToken: clearVerifyToken ? null : (verifyToken ?? this.verifyToken),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statusAction,
        lastAction,
        permissions,
        staffList,
        verifyToken,
        errorMessage,
      ];
}
