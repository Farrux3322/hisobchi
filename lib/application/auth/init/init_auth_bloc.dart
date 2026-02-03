import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';
import 'package:hisobchi/infrastructure/repository/auth/auth_repository.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';

part 'init_auth_event.dart';

part 'init_auth_state.dart';

class InitAuthBloc extends Bloc<InitAuthEvent, InitAuthState> {
  InitAuthBloc() : super(InitAuthInitial()) {
    on<VerifyNumber>(_verifyNumber);
    on<SignInEvent>(_signIn);
    on<SendOtpEvent>(_sendOtp);
    on<ResetSendOtpEvent>(_optResetPassword);
    on<RegisterEvent>(_signConfrimation);
    on<ResetAuthEvent>((event, emit) {
      phone = '';
      password = '';
      emit(InitAuthInitial());
    });

  }

  final _repo = AuthRepository();
  String phone = '', password = '',name = '';
  Future<void> _verifyNumber(
    VerifyNumber event,
    Emitter<InitAuthState> emit,
  ) async {
    try {
      emit(LoadingState());
      phone = event.phone;
      final data = await _repo.init(phone: event.phone);
      String? pageStatus = data['result']['page'];

      if (data['status']) {
        emit(
          InitSuccess(
            pageStatus: pageStatus ?? '',
            phone: phone,
          ),
        );
      } else {
        emit(ErrorState(data['error']['message']));
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  Future<void> _signIn(
    SignInEvent event,
    Emitter<InitAuthState> emit,
  ) async {
    try {
      emit(SignInLoading());

      final prefs = await SharedPrefService.initialize();
      final data = await _repo.login(
        phone: event.phone,
        password: event.password,
      );

      final String message = data['error']?['message'] ?? '';
      final String token = data['result']?['token'] ?? '';

      if (token.isNotEmpty) {
        UserData.token = token;
        final secondData = await _repo.getMe();
        final String name = secondData['result']?['name'] ?? '';
        final String phone = secondData['result']?['phone'] ?? '';
        final int userId = secondData['result']?['user_id'] ?? 0;
        final String image = secondData['result']?['image'] ?? '';
        final String message0 = secondData['error']?['message'] ?? '';
        List<String> role = ((secondData['result']?['role']).cast<String>()) ?? [];
        if (message0.isEmpty) {
          UserData.name = name;
          UserData.userId = userId;
          UserData.phone = phone;
          UserData.image = image;
          UserData.role = role;
          prefs.setUserId(userId);
          prefs.setToken(token);
          prefs.setName(name);
          prefs.setPhone(phone);
          prefs.setImage(image);
          prefs.setRole(role);
          emit(SignInSuccess());
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

  Future<void> _sendOtp(
    SendOtpEvent event,
    Emitter<InitAuthState> emit,
  ) async {
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

  Future<void> _optResetPassword(
    ResetSendOtpEvent event,
    Emitter<InitAuthState> emit,
  ) async {
    try {
      emit(RegisterLoading());

      final prefs = await SharedPrefService.initialize();
      final data = await _repo.otpResetPassword(
        phone: phone,
        password: password,
        otp: event.otp,
      );

      final String token = data['result']?['token'] ?? '';

      if (token.isNotEmpty) {
        UserData.token = token;
        final secondData = await _repo.getMe();
        final String name = secondData['result']?['name'] ?? '';
        final String phone = secondData['result']?['phone'] ?? '';
        final int userId = secondData['result']?['user_id'] ?? 0;
        final String image = secondData['result']?['image'] ?? '';
        final String message0 = secondData['error']?['message'] ?? '';
        List<String> role = ((secondData['result']?['role']).cast<String>()) ?? [];
        if (message0.isEmpty) {
          UserData.name = name;
          UserData.userId = userId;
          UserData.phone = phone;
          UserData.image = image;
          UserData.role = role;
          prefs.setUserId(userId);
          prefs.setToken(token);
          prefs.setName(name);
          prefs.setPhone(phone);
          prefs.setImage(image);
          prefs.setRole(role);
          emit(RegisterSuccess());
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

  Future<void> _signConfrimation(
    RegisterEvent event,
    Emitter<InitAuthState> emit,
  ) async {
    try {
      emit(RegisterLoading());

      final prefs = await SharedPrefService.initialize();
      final data = await _repo.register(
        phone: phone,
        name: name,
        password: password,
        otp: event.otp,
      );
      if(data['status']==true){
        final String token = data['result']?['token'] ?? '';

        if (token.isNotEmpty) {
          UserData.token = token;
          final secondData = await _repo.getMe();
          final String name = secondData['result']?['name'] ?? '';
          final String phone = secondData['result']?['phone'] ?? '';
          final int userId = secondData['result']?['user_id'] ?? 0;
          final String image = secondData['result']?['image'] ?? '';
          final String message0 = secondData['error']?['message'] ?? '';
          List<String> role = ((secondData['result']?['role']).cast<String>()) ?? [];
          if (message0.isEmpty) {
            UserData.name = name;
            UserData.userId = userId;
            UserData.phone = phone;
            UserData.image = image;
            UserData.role = role;
            prefs.setUserId(userId);
            prefs.setToken(token);
            prefs.setName(name);
            prefs.setPhone(phone);
            prefs.setImage(image);
            prefs.setRole(role);
            emit(RegisterSuccess());
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
}
