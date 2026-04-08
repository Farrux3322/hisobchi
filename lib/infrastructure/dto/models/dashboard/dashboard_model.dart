class DashboardModel {
  bool? status;
  DashboardResult? result;

  DashboardModel({this.status, this.result});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result = json['result'] != null ? DashboardResult.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class DashboardResult {
  PartnersData? partners;
  ProjectsData? projects;

  DashboardResult({this.partners, this.projects});

  DashboardResult.fromJson(Map<String, dynamic> json) {
    partners = json['partners'] != null ? PartnersData.fromJson(json['partners']) : null;
    projects = json['projects'] != null ? ProjectsData.fromJson(json['projects']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (partners != null) data['partners'] = partners!.toJson();
    if (projects != null) data['projects'] = projects!.toJson();
    return data;
  }
}

class PartnersData {
  int? partnersCount;
  PartnersDetails? details;

  PartnersData({this.partnersCount, this.details});

  PartnersData.fromJson(Map<String, dynamic> json) {
    partnersCount = json['partners_count'];
    details = json['details'] != null ? PartnersDetails.fromJson(json['details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['partners_count'] = partnersCount;
    if (details != null) data['details'] = details!.toJson();
    return data;
  }
}

class PartnersDetails {
  PartnerDetailItem? qarzExpired;
  PartnerDetailItem? qarzToday;
  PartnerDetailItem? qarz3Days;
  PartnerDetailItem? installmentExpired;
  PartnerDetailItem? installmentToday;
  PartnerDetailItem? installment3Days;

  PartnersDetails({
    this.qarzExpired,
    this.qarzToday,
    this.qarz3Days,
    this.installmentExpired,
    this.installmentToday,
    this.installment3Days,
  });

  PartnersDetails.fromJson(Map<String, dynamic> json) {
    qarzExpired = json['qarz_expired'] != null ? PartnerDetailItem.fromJson(json['qarz_expired']) : null;
    qarzToday = json['qarz_today'] != null ? PartnerDetailItem.fromJson(json['qarz_today']) : null;
    qarz3Days = json['qarz_3_days'] != null ? PartnerDetailItem.fromJson(json['qarz_3_days']) : null;
    installmentExpired = json['installment_expired'] != null ? PartnerDetailItem.fromJson(json['installment_expired']) : null;
    installmentToday = json['installment_today'] != null ? PartnerDetailItem.fromJson(json['installment_today']) : null;
    installment3Days = json['installment_3_days'] != null ? PartnerDetailItem.fromJson(json['installment_3_days']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (qarzExpired != null) data['qarz_expired'] = qarzExpired!.toJson();
    if (qarzToday != null) data['qarz_today'] = qarzToday!.toJson();
    if (qarz3Days != null) data['qarz_3_days'] = qarz3Days!.toJson();
    if (installmentExpired != null) data['installment_expired'] = installmentExpired!.toJson();
    if (installmentToday != null) data['installment_today'] = installmentToday!.toJson();
    if (installment3Days != null) data['installment_3_days'] = installment3Days!.toJson();
    return data;
  }
}

class PartnerDetailItem {
  int? count;
  String? type;

  PartnerDetailItem({this.count, this.type});

  PartnerDetailItem.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() => {'count': count, 'type': type};
}

class ProjectsData {
  int? projectsCount;
  int? inProgress;
  int? frozen;
  int? completed;

  ProjectsData({this.projectsCount, this.inProgress, this.frozen, this.completed});

  ProjectsData.fromJson(Map<String, dynamic> json) {
    projectsCount = json['projects_count'];
    inProgress = json['in_progress'];
    frozen = json['frozen'];
    completed = json['completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['projects_count'] = projectsCount;
    data['in_progress'] = inProgress;
    data['frozen'] = frozen;
    data['completed'] = completed;
    return data;
  }
}
