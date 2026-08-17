import 'package:equatable/equatable.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/models/tutorial_model.dart';

class TutorialState extends Equatable {
  final Status status;
  final List<TutorialModel> tutorials;
  final String? errorMessage;
  final bool? isNotFound;

  const TutorialState({this.status = Status.initial, this.tutorials = const [], this.errorMessage, this.isNotFound});

  TutorialState copyWith({Status? status, List<TutorialModel>? tutorials, String? errorMessage, bool? isNotFound}) {
    return TutorialState(status: status ?? this.status, tutorials: tutorials ?? this.tutorials, errorMessage: errorMessage ?? this.errorMessage, isNotFound: isNotFound ?? this.isNotFound);
  }

  @override
  List<Object?> get props => [status, tutorials, errorMessage, isNotFound];
}
