part of 'partner_bloc.dart';

class PartnerState extends Equatable {
  final Status status;
  final Status statusKirim;
  final Status statusKirimAdd;
  final Status statusAdd;
  final Status statusIncomeStatement;
  final Status statusIncomeHistory;
  final Status statusGetSmsSettings;
  final Status statusUpdateSmsSettings;
  final Status statusLoadMore;
  final String? errorMessage;
  final IncomeStatementModel? incomeStatementModel;
  final IncomeHistoryModel? incomeHistoryModel;
  final Map<String, dynamic>? smsSettingsMap;
  final List<PartnerModel> models;
  final int currentPage;
  final int lastPage;
  final bool hasReachedMax;

  const PartnerState({
    this.status = Status.pure,
    this.statusAdd = Status.pure,
    this.statusIncomeStatement = Status.pure,
    this.statusIncomeHistory = Status.pure,
    this.statusGetSmsSettings = Status.pure,
    this.statusUpdateSmsSettings = Status.pure,
    this.statusKirim = Status.pure,
    this.statusKirimAdd = Status.pure,
    this.statusLoadMore = Status.pure,
    this.errorMessage,
    this.incomeStatementModel,
    this.incomeHistoryModel,
    this.smsSettingsMap,
    this.models = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasReachedMax = false,
  });

  PartnerState copyWith({
    Status? status,
    Status? statusKirim,
    Status? statusKirimAdd,
    Status? statusAdd,
    Status? statusIncomeStatement,
    Status? statusIncomeHistory,
    Status? statusGetSmsSettings,
    Status? statusUpdateSmsSettings,
    Status? statusLoadMore,
    String? errorMessage,
    IncomeStatementModel? incomeStatementModel,
    IncomeHistoryModel? incomeHistoryModel,
    Map<String, dynamic>? smsSettingsMap,
    List<PartnerModel>? models,
    int? currentPage,
    int? lastPage,
    bool? hasReachedMax,
  }) {
    return PartnerState(
        status: status ?? this.status,
        statusKirim: statusKirim ?? this.statusKirim,
        statusKirimAdd: statusKirimAdd ?? this.statusKirimAdd,
        statusAdd: statusAdd ?? this.statusAdd,
        statusIncomeHistory: statusIncomeHistory ?? this.statusIncomeHistory,
        statusIncomeStatement: statusIncomeStatement ?? this.statusIncomeStatement,
        statusGetSmsSettings: statusGetSmsSettings ?? this.statusGetSmsSettings,
        statusUpdateSmsSettings: statusUpdateSmsSettings ?? this.statusUpdateSmsSettings,
        statusLoadMore: statusLoadMore ?? this.statusLoadMore,
        errorMessage: errorMessage ?? this.errorMessage,
        incomeStatementModel: incomeStatementModel ?? this.incomeStatementModel,
        incomeHistoryModel: incomeHistoryModel ?? this.incomeHistoryModel,
        smsSettingsMap: smsSettingsMap ?? this.smsSettingsMap,
        models: models ?? this.models,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
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
    statusGetSmsSettings,
    statusUpdateSmsSettings,
    statusLoadMore,
    errorMessage,
    incomeStatementModel,
    incomeHistoryModel,
    smsSettingsMap,
    models,
    currentPage,
    lastPage,
    hasReachedMax,
  ];
}
