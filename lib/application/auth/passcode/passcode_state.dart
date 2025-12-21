part of 'passcode_cubit.dart';

abstract class PasscodeState {
  const PasscodeState({
    this.passcodeStep = PasscodeStep.none,
    this.filledInputCount = -1,
    this.isProcessCompleted = false,
    this.isIncorrectPasscode = false,
    this.passcodeOne = '',
    this.passcodeTwo = '',
  });

  final bool isProcessCompleted;
  final bool isIncorrectPasscode;
  final int filledInputCount;
  final String passcodeOne;
  final String passcodeTwo;
  final PasscodeStep passcodeStep;

  PasscodeState copyWith({
    PasscodeStep? passcodeStep,
    bool? isProcessCompleted,
    bool? isIncorrectPasscode,
    int? filledInputCount,
    String? passcodeOne,
    String? passcodeTwo,
  });
}

class PasscodeInitial extends PasscodeState {
  const PasscodeInitial({
    super.passcodeStep,
    super.filledInputCount,
    super.isProcessCompleted,
    super.isIncorrectPasscode,
    super.passcodeOne,
    super.passcodeTwo,
  });

  @override
  PasscodeState copyWith({
    PasscodeStep? passcodeStep,
    bool? isProcessCompleted,
    bool? isIncorrectPasscode,
    int? filledInputCount,
    String? passcodeOne,
    String? passcodeTwo,
  }) {
    return PasscodeInitial(
      passcodeStep: passcodeStep ?? this.passcodeStep,
      isProcessCompleted: isProcessCompleted ?? this.isProcessCompleted,
      isIncorrectPasscode: isIncorrectPasscode ?? this.isIncorrectPasscode,
      filledInputCount: filledInputCount ?? this.filledInputCount,
      passcodeOne: passcodeOne ?? this.passcodeOne,
      passcodeTwo: passcodeTwo ?? this.passcodeTwo,
    );
  }
}
