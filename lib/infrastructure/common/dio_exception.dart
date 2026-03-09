import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';
import 'package:hisobchi/presentation/routes/coordinator.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';

Bloc? lastBloc;
Object? lastEvent;

class DioExceptionX extends DioException {
  DioExceptionX({
    required super.requestOptions,
    super.response,
    super.message,
    super.error,
    this.statusCode,
    this.serverError,
    this.checkUnauthorized = true,
    this.errorType = DioExceptionType.unknown,
  }) : super(type: errorType);

  final int? statusCode;
  final dynamic serverError;
  final bool checkUnauthorized;
  final DioExceptionType errorType;

  @override
  String toString() {
    if (error != null) {
      return error.toString();
    } else {
      return _getServerError();
    }
  }

  String _getServerError() {
    try {
      if (checkUnauthorized && statusCode == 401) {
        UserData.token = "";
        parentKey.currentContext?.go(Routes.signIn.path);
        return '';
      } else if (statusCode == 309 || errorType == DioExceptionType.cancel) {
        return '';
      } else {
        if (errorType == DioExceptionType.connectionTimeout || errorType == DioExceptionType.sendTimeout || errorType == DioExceptionType.receiveTimeout) {
          return 'Tarmoq ulanishida vaqt kutilganidan oshib ketdi. Internet aloqasini tekshiring.';
        }
        
        if (errorType == DioExceptionType.connectionError) {
          return 'Internet aloqasi mavjud emas yoki server bilan bog\'lanishda xatolik yuz berdi.';
        }

        if (statusCode != null && statusCode! >= 500) {
          return tr('errors.no_connection_to_server');
        } else {
          // Senior approach: if it's a validation error (e.g. 422), 
          // return the whole data as JSON so BLoC/UI can parse detailed 'errors'
          if (statusCode != null && statusCode! >= 400 && statusCode! < 500) {
            if (serverError is Map && (serverError.containsKey('errors') || serverError.containsKey('error'))) {
              return jsonEncode(serverError);
            }
          }

          if (serverError is Map) {
            if (serverError['error'] != null) {
              final dynamic errorData = serverError['error'];
              if (errorData is Map && errorData.isNotEmpty) {
                return errorData[errorData.keys.first][0].toString();
              }
              return errorData.toString();
            } else if (serverError['message'] != null) {
              return serverError['message'].toString();
            }
          }
          
          return serverError.toString();
        }
      }
    } catch (e) {
      // If we can't extract cleanly, return the raw data as string
      return serverError?.toString() ?? e.toString();
    }
  }
}
