import 'package:equatable/equatable.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/models/sent_sms_model.dart';

class SentSmsState extends Equatable {
  final Status status;
  final List<SentSmsModel> smsList;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  const SentSmsState({
    this.status = Status.initial,
    this.smsList = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
  });

  SentSmsState copyWith({
    Status? status,
    List<SentSmsModel>? smsList,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
  }) {
    return SentSmsState(
      status: status ?? this.status,
      smsList: smsList ?? this.smsList,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, smsList, currentPage, hasMore, errorMessage];
}
