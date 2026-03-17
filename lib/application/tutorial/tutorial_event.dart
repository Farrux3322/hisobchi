import 'package:equatable/equatable.dart';

abstract class TutorialEvent extends Equatable {
  const TutorialEvent();

  @override
  List<Object?> get props => [];
}

class GetTutorialsEvent extends TutorialEvent {}
