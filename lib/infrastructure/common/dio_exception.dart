
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';

Bloc? lastBloc;
Object? lastEvent;

class DioExceptionX extends DioException {
  DioExceptionX({
    required super.requestOptions,
    dynamic super.error,
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
        AppManagerCubit.context!.go(Routes.signIn.path);
        return '';
      } else if (statusCode == 309) {
        // AppManagerCubit.context!.go(Routes.checkPasscode.path);
        // showDialog(
        //     context: AppManagerCubit.context!,
        //     barrierDismissible: false,
        //     builder: (BuildContext context) {
        //       return AreaOutDialog(
        //         onTap: () {
        //           context.pop();
        //           if (lastBloc != null) lastBloc!.add(lastEvent);
        //         },
        //         title: serverError?['error']?['message'] ?? '',
        //       );
        //     });
        return '';
      } else {
        if (statusCode! >= 500) {
          return tr('errors.no_connection_to_server');
        } else {
          if (serverError['error'] != null) {
            final Map<String, dynamic> message = serverError['error'];
            return message[message.keys.first][0];
          } else if (serverError['message'] != null) {
            return serverError['message'];
          } else {
            return serverError.toString();
          }
        }
      }
    } catch (e) {
      return tr(e.toString());
    }
  }
}
