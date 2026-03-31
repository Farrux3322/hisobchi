import 'package:equatable/equatable.dart';

abstract class WarrantyPeriodsEvent extends Equatable {
  const WarrantyPeriodsEvent();

  @override
  List<Object?> get props => [];
}

class LoadWarrantyPeriodsEvent extends WarrantyPeriodsEvent {
  const LoadWarrantyPeriodsEvent();
}
