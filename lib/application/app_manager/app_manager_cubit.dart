import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';
import 'package:hisobchi/infrastructure/common/platform_info.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';

import '../../presentation/assets/asset_index.dart';

part 'app_manager_state.dart';

class AppManagerCubit extends Cubit<AppManagerState> {
  AppManagerCubit() : super(AppManagerLoading());

  static BuildContext? context;

  Future<void> init() async {
    emit(AppManagerLoading());
    try {
       AppTheme.init();
      await ScreenSize.setSizes();

      PlatformInfo.init();

      final pref = await SharedPrefService.initialize();

      // UserData.token = '14|qYxDTbEZLAFg29f1UhzZg32soXDEYl1XqS8MWF4Y5c0b1232';
      UserData.token = pref.getToken;
      UserData.phone = pref.getPhone;
      UserData.name = pref.getName;
      UserData.branchName = pref.getBranchName;
      UserData.image = pref.getImage;
      UserData.isAdmin = pref.getIsAdmin;
      UserData.authorGuid = pref.getAuthorGuid;
      // UserData.role = pref.getRole;

      // if (UserData.role == 'seller') {
      //   router.value = routerSeller;
      // } else if (UserData.role == "inspection") {
      //   router.value = routerInspection;
      // } else {
      //   router.value = routerPhoto;
      // }


      emit(AppManagerInitial());
    } catch (e) {
      emit(AppManagerError(e.toString()));
    }
  }
}
