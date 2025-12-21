part of 'update_checker_bloc.dart';

abstract class UpdateCheckerEvent extends Equatable {
  const UpdateCheckerEvent();

  @override
  List<Object?> get props => [];
}

class CheckUpdate extends UpdateCheckerEvent {
  const CheckUpdate();
}
