import 'package:bloc/bloc.dart';
import 'package:ehisob/domain/common/enums/subscription_status.dart';

class SubscriptionStatusCubit extends Cubit<SubscriptionStatus> {
  SubscriptionStatusCubit() : super(SubscriptionStatus.active);

  void updateStatus(SubscriptionStatus newStatus) {
    if (state != newStatus) {
      emit(newStatus);
    }
  }

  void updateStatusFromServer(String? statusHeader) {
    final newStatus = SubscriptionStatus.fromServer(statusHeader);
    updateStatus(newStatus);
  }
}
