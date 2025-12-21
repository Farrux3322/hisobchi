import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../infrastructure/repository/update/update_repo.dart';

part 'update_checker_event.dart';

part 'update_checker_state.dart';

class UpdateCheckerBloc extends Bloc<UpdateCheckerEvent, UpdateCheckerState> {
  UpdateCheckerBloc() : super(const UpdateCheckerState(hasUpdate: false, updateStatus: 'hard')) {
    on<UpdateCheckerEvent>(checkUpdate);
  }

  final repo = UpdateRepository();

  Future<void> checkUpdate(UpdateCheckerEvent event, Emitter<UpdateCheckerState> emit) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    try {
      Map<String, dynamic> data = {};
      data = await repo.updateApp(appVersion: packageInfo.version);
      if (data["status"] == true) {
        emit(state.copyWith(hasUpdate: data["result"]["update"], updateStatus: data["result"]["update_status"]));
      } else {
        return emit(state.copyWith());
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
