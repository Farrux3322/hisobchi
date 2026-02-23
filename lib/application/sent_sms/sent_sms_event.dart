import 'package:equatable/equatable.dart';

abstract class SentSmsEvent extends Equatable {
  const SentSmsEvent();

  @override
  List<Object?> get props => [];
}

class FetchSentSmsEvent extends SentSmsEvent {
  final int partnerId;
  final bool isRefresh;

  const FetchSentSmsEvent({
    required this.partnerId,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [partnerId, isRefresh];
}
