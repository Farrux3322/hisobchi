class ProjectReportModel {
  final num? incomeUzs;
  final num? incomeUsd;
  final num? balanceUzs;
  final num? balanceUsd;
  final ProjectCosts? costs;

  ProjectReportModel({
    this.incomeUzs,
    this.incomeUsd,
    this.balanceUzs,
    this.balanceUsd,
    this.costs,
  });

  factory ProjectReportModel.fromJson(Map<String, dynamic> json) {
    return ProjectReportModel(
      incomeUzs: json['income_uzs'] as num?,
      incomeUsd: json['income_usd'] as num?,
      balanceUzs: json['balance_uzs'] as num?,
      balanceUsd: json['balance_usd'] as num?,
      costs: json['costs'] != null
          ? ProjectCosts.fromJson(json['costs'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'income_uzs': incomeUzs,
      'income_usd': incomeUsd,
      'balance_uzs': balanceUzs,
      'balance_usd': balanceUsd,
      'costs': costs?.toJson(),
    };
  }
}

class ProjectCosts {
  final num? costUzs;
  final num? costUsd;
  final List<ProjectCostDetail>? details;

  ProjectCosts({
    this.costUzs,
    this.costUsd,
    this.details,
  });

  factory ProjectCosts.fromJson(Map<String, dynamic> json) {
    return ProjectCosts(
      costUzs: json['cost_uzs'] as num?,
      costUsd: json['cost_usd'] as num?,
      details: json['details'] != null
          ? (json['details'] as List)
              .map((e) => ProjectCostDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cost_uzs': costUzs,
      'cost_usd': costUsd,
      'details': details?.map((e) => e.toJson()).toList(),
    };
  }
}

class ProjectCostDetail {
  final int? costTypeId;
  final String? costTypeName;
  final num? summaUzs;
  final num? summaUsd;

  ProjectCostDetail({
    this.costTypeId,
    this.costTypeName,
    this.summaUzs,
    this.summaUsd,
  });

  factory ProjectCostDetail.fromJson(Map<String, dynamic> json) {
    return ProjectCostDetail(
      costTypeId: json['cost_type_id'] as int?,
      costTypeName: json['cost_type_name'] as String?,
      summaUzs: json['summa_uzs'] as num?,
      summaUsd: json['summa_usd'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cost_type_id': costTypeId,
      'cost_type_name': costTypeName,
      'summa_uzs': summaUzs,
      'summa_usd': summaUsd,
    };
  }
}
