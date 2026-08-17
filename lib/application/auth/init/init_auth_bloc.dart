import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:ehisob/domain/common/data/user_data.dart';
import 'package:ehisob/infrastructure/models/user_me_model.dart';
import 'package:ehisob/infrastructure/repository/auth/auth_repository.dart';
import 'package:ehisob/infrastructure/services/shared_service.dart';

part 'init_auth_event.dart';

part 'init_auth_state.dart';

class InitAuthBloc extends Bloc<InitAuthEvent, InitAuthState> {
  InitAuthBloc() : super(InitAuthInitial()) {
    on<VerifyNumber>(_verifyNumber);
    on<SignInEvent>(_signIn);
    on<SendOtpEvent>(_sendOtp);
    on<VerifyOtpEvent>(_verifyOtp);
    on<ResetSendOtpEvent>(_optResetPassword);
    on<RegisterEvent>(_signConfrimation);
    on<SelectWorkspaceEvent>(_selectWorkspace);
    on<ActivateOwnerAccountEvent>(_activateOwnerAccount);
    on<ResetAuthEvent>((event, emit) {
      phone = '';
      password = '';
      emit(InitAuthInitial());
    });
  }

  final _repo = AuthRepository();
  String phone = '', password = '', name = '', verifyToken = '';

  Future<void> _verifyNumber(VerifyNumber event, Emitter<InitAuthState> emit) async {
    try {
      emit(LoadingState());
      phone = event.phone;
      final data = await _repo.init(phone: event.phone);
      String? pageStatus = data['result']['page'];

      if (data['status']) {
        emit(InitSuccess(pageStatus: pageStatus ?? '', phone: phone));
      } else {
        emit(ErrorState(data['error']['message']));
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  Future<void> _signIn(SignInEvent event, Emitter<InitAuthState> emit) async {
    try {
      emit(SignInLoading());

      final prefs = await SharedPrefService.initialize();
      final data = await _repo.login(phone: event.phone, password: event.password);

      final String message = data['error']?['message'] ?? '';
      final String token = data['result']?['token'] ?? '';

      if (token.isNotEmpty) {
        UserData.token = token;
        final secondData = await _repo.getMe();
        final String name = secondData['result']?['name'] ?? '';
        final String phone = secondData['result']?['phone'] ?? '';
        final int userId = secondData['result']?['user_id'] ?? 0;
        final bool xZiffler = secondData['result']?['x_ziffler'] ?? false;
        final String image = secondData['result']?['image'] ?? '';
        final String message0 = secondData['error']?['message'] ?? '';
        List<String> role = ((secondData['result']?['role']).cast<String>()) ?? [];
        if (message0.isEmpty) {
          final meModel = UserMeModel.fromJson(secondData);
          UserData.reset();
          UserData.token = token;
          UserData.name = name;
          UserData.userId = userId;
          UserData.phone = phone;
          UserData.image = image;
          UserData.role = role;
          UserData.xZiffler = xZiffler;

          // Auto-initialize for owner-only users
          if (role.length == 1 && role.contains('user') && meModel.result.worksFor.isEmpty) {
            UserData.isWorkerMode = false;
            UserData.activePermissions = meModel.result.permissions;
            UserData.activeOwnerId = userId;
            prefs.setPermissions(meModel.result.permissions);
            prefs.setOwnerId(userId);
            prefs.setToken(token);
          }

          prefs.setUserId(userId);
          prefs.setName(name);
          prefs.setPhone(phone);
          prefs.setImage(image);
          prefs.setRole(role);
          prefs.setXZiffler(xZiffler);
          emit(SignInSuccess(meModel));
        } else {
          emit(SignInError(message0));
        }
      } else {
        emit(SignInError(message));
      }
    } catch (e) {
      debugPrint(e.toString());
      emit(SignInError(e.toString()));
    }
  }

  Future<void> _sendOtp(SendOtpEvent event, Emitter<InitAuthState> emit) async {
    try {
      emit(OtpLoading());
      password = event.password;
      name = event.name;
      final data = await _repo.otp(phone: phone);
      if (data['status']) {
        emit(OtpSuccess());
      } else {
        emit(OtpFailed(error: data['error']?['message']));
      }
    } catch (e) {
      emit(OtpFailed(error: e.toString()));
    }
  }

  Future<void> _verifyOtp(VerifyOtpEvent event, Emitter<InitAuthState> emit) async {
    try {
      emit(OtpLoading());
      final data = await _repo.verifyOtp(phone: phone, otpCode: event.otp);
      if (data['status'] == true) {
        verifyToken = data['result']['verify_token'] ?? '';
        // After successful verification, we automatically trigger registration
        add(RegisterEvent(otp: event.otp));
      } else {
        emit(OtpFailed(error: data['error']?['message']));
      }
    } catch (e) {
      emit(OtpFailed(error: e.toString()));
    }
  }

  Future<void> _optResetPassword(ResetSendOtpEvent event, Emitter<InitAuthState> emit) async {
    try {
      emit(RegisterLoading());

      final prefs = await SharedPrefService.initialize();
      final data = await _repo.otpResetPassword(phone: phone, password: password, otp: event.otp);

      final String token = data['result']?['token'] ?? '';

      if (token.isNotEmpty) {
        UserData.token = token;
        final secondData = await _repo.getMe();
        final String name = secondData['result']?['name'] ?? '';
        final String phone = secondData['result']?['phone'] ?? '';
        final int userId = secondData['result']?['user_id'] ?? 0;
        final bool xZiffler = secondData['result']?['x_ziffler'] ?? false;
        final String image = secondData['result']?['image'] ?? '';
        final String message0 = secondData['error']?['message'] ?? '';
        List<String> role = ((secondData['result']?['role']).cast<String>()) ?? [];
        if (message0.isEmpty) {
          final meModel = UserMeModel.fromJson(secondData);
          UserData.reset();
          UserData.token = token;
          UserData.name = name;
          UserData.userId = userId;
          UserData.phone = phone;
          UserData.image = image;
          UserData.role = role;
          UserData.xZiffler = xZiffler;

          // Auto-initialize for owner-only users
          if (role.length == 1 && role.contains('user') && meModel.result.worksFor.isEmpty) {
            UserData.isWorkerMode = false;
            UserData.activePermissions = meModel.result.permissions;
            UserData.activeOwnerId = userId;
            prefs.setPermissions(meModel.result.permissions);
            prefs.setOwnerId(userId);
            prefs.setToken(token);
          }

          prefs.setUserId(userId);
          prefs.setName(name);
          prefs.setPhone(phone);
          prefs.setImage(image);
          prefs.setRole(role);
          prefs.setXZiffler(xZiffler);
          emit(RegisterSuccess(meModel));
        } else {
          emit(RegisterFailed(error: message0));
        }
      } else {
        emit(RegisterFailed(error: data['error']?['message']));
      }
    } catch (e) {
      emit(RegisterFailed(error: e.toString()));
    }
  }

  Future<void> _signConfrimation(RegisterEvent event, Emitter<InitAuthState> emit) async {
    try {
      emit(RegisterLoading());

      final prefs = await SharedPrefService.initialize();
      final data = await _repo.register(phone: phone, name: name, password: password, verifyToken: verifyToken);
      if (data['status'] == true) {
        final String token = data['result']?['token'] ?? '';

        if (token.isNotEmpty) {
          UserData.token = token;
          final secondData = await _repo.getMe();
          final String name = secondData['result']?['name'] ?? '';
          final String phone = secondData['result']?['phone'] ?? '';
          final int userId = secondData['result']?['user_id'] ?? 0;
          final bool xZiffler = secondData['result']?['x_ziffler'] ?? false;
          final String image = secondData['result']?['image'] ?? '';
          final String message0 = secondData['error']?['message'] ?? '';
          List<String> role = ((secondData['result']?['role']).cast<String>()) ?? [];
          if (message0.isEmpty) {
            final meModel = UserMeModel.fromJson(secondData);
            UserData.reset();
            UserData.token = token;
            UserData.name = name;
            UserData.userId = userId;
            UserData.phone = phone;
            UserData.image = image;
            UserData.role = role;
            UserData.xZiffler = xZiffler;

            // Auto-initialize for owner-only users
            if (role.length == 1 && role.contains('user') && meModel.result.worksFor.isEmpty) {
              UserData.isWorkerMode = false;
              UserData.activePermissions = meModel.result.permissions;
              UserData.activeOwnerId = userId;
              prefs.setPermissions(meModel.result.permissions);
              prefs.setOwnerId(userId);
              prefs.setToken(token);
            }

            prefs.setUserId(userId);
            prefs.setName(name);
            prefs.setPhone(phone);
            prefs.setImage(image);
            prefs.setRole(role);
            prefs.setXZiffler(xZiffler);
            emit(RegisterSuccess(meModel));
          } else {
            emit(RegisterFailed(error: message0));
          }
        } else {
          emit(RegisterFailed(error: "Token topilmadi"));
        }
      } else {
        emit(RegisterFailed(error: data['error']?['message']));
      }
    } catch (e) {
      emit(RegisterFailed(error: e.toString()));
    }
  }

  Future<void> _selectWorkspace(SelectWorkspaceEvent event, Emitter<InitAuthState> emit) async {
    try {
      emit(SignInLoading());
      final prefs = await SharedPrefService.initialize();

      if (event.workspace != null) {
        // Xodim sifatida kirish
        final w = event.workspace!;
        UserData.isWorkerMode = true;
        UserData.activePermissions = w.permissions;
        UserData.name = event.meData.result.name;
        UserData.phone = event.meData.result.phone;
        UserData.activeOwnerId = w.ownerId;

        prefs.setName(UserData.name);
        prefs.setPhone(UserData.phone);
        prefs.setPermissions(w.permissions);
        prefs.setOwnerId(w.ownerId);
      } else {
        // Owner sifatida kirish
        UserData.isWorkerMode = false;
        UserData.activePermissions = event.meData.result.permissions;
        UserData.name = event.meData.result.name;
        UserData.phone = event.meData.result.phone;
        UserData.activeOwnerId = event.meData.result.userId;

        prefs.setName(event.meData.result.name);
        prefs.setPhone(event.meData.result.phone);
        prefs.setPermissions(event.meData.result.permissions);
        prefs.setOwnerId(event.meData.result.userId);
      }

      // Finalize session persistence
      prefs.setToken(UserData.token);

      emit(SignInSuccess(event.meData));
    } catch (e) {
      emit(SignInError(e.toString()));
    }
  }

  Future<void> _activateOwnerAccount(ActivateOwnerAccountEvent event, Emitter<InitAuthState> emit) async {
    try {
      emit(ActivateOwnerAccountLoading());
      final data = await _repo.activateOwnAccount(token: UserData.token);
      if (data['status'] == true) {
        // Refresh user data after activation
        final secondData = await _repo.getMe();
        if (secondData['status'] == true) {
          final meModel = UserMeModel.fromJson(secondData);
          final prefs = await SharedPrefService.initialize();

          UserData.isWorkerMode = false;
          UserData.activePermissions = meModel.result.permissions;
          UserData.name = meModel.result.name;
          UserData.phone = meModel.result.phone;
          UserData.activeOwnerId = meModel.result.userId;

          prefs.setName(meModel.result.name);
          prefs.setPhone(meModel.result.phone);
          prefs.setPermissions(meModel.result.permissions);
          prefs.setOwnerId(meModel.result.userId);
          prefs.setToken(UserData.token);

          emit(ActivateOwnerAccountSuccess());
          emit(SignInSuccess(meModel));
        } else {
          emit(ActivateOwnerAccountFailed(error: secondData['error']?['message'] ?? 'Ma\'lumotlarni yangilashda xatolik'));
        }
      } else {
        emit(ActivateOwnerAccountFailed(error: data['error']?['message'] ?? 'Xatolik yuz berdi'));
      }
    } catch (e) {
      emit(ActivateOwnerAccountFailed(error: e.toString()));
    }
  }
}
