part of 'partner_bloc.dart';

class PartnerState extends Equatable {
  final Status status;
  final Status statusKirim;
  final Status statusKirimAdd;
  final Status statusAdd;
  final Status statusIncomeStatement;
  final Status statusIncomeHistory;
  final String? errorMessage;
  final IncomeStatementModel? incomeStatementModel;
  final IncomeHistoryModel? incomeHistoryModel;
  final List<PartnerModel> models;


  const PartnerState({
    this.status = Status.pure,
    this.statusAdd = Status.pure,
    this.statusIncomeStatement = Status.pure,
    this.statusIncomeHistory = Status.pure,
    this.statusKirim = Status.pure,
    this.statusKirimAdd = Status.pure,
    this.errorMessage,
    this.incomeStatementModel,
    this.incomeHistoryModel,
    this.models = const [],
  });

  PartnerState copyWith({
    Status? status,
    Status? statusKirim,
    Status? statusKirimAdd,
    Status? statusAdd,
    Status? statusIncomeStatement,
    Status? statusIncomeHistory,
    String? errorMessage,
    IncomeStatementModel? incomeStatementModel,
    IncomeHistoryModel? incomeHistoryModel,
    List<PartnerModel>? models,
  }) {
    return PartnerState(
        status: status ?? this.status,
        statusKirim: statusKirim ?? this.statusKirim,
        statusKirimAdd: statusKirimAdd ?? this.statusKirimAdd,
        statusAdd: statusAdd ?? this.statusAdd,
        statusIncomeHistory: statusIncomeHistory ?? this.statusIncomeHistory,
        statusIncomeStatement: statusIncomeStatement ?? this.statusIncomeStatement,
        errorMessage: errorMessage ?? this.errorMessage,
        incomeStatementModel: incomeStatementModel ?? this.incomeStatementModel,
        incomeHistoryModel: incomeHistoryModel ?? this.incomeHistoryModel,
        models: models ?? this.models
    );
  }

  @override
  List<Object?> get props => [
    status,
    statusKirim,
    statusKirimAdd,
    statusAdd,
    statusIncomeHistory,
    statusIncomeStatement,
    errorMessage,
    incomeStatementModel,
    incomeHistoryModel,
    models,
  ];
}
