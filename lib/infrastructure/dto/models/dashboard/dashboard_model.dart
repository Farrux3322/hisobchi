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
    if (partners != null) {
      data['partners'] = partners!.toJson();
    }
    if (projects != null) {
      data['projects'] = projects!.toJson();
    }
    return data;
  }
}

class PartnersData {
  int? partnersCount;
  Map<String, PartnersDetails>? details;

  PartnersData({this.partnersCount, this.details});

  PartnersData.fromJson(Map<String, dynamic> json) {
    partnersCount = json['partners_count'];
    if (json['details'] != null) {
      details = {};
      json['details'].forEach((key, value) {
        details![key] = PartnersDetails.fromJson(value);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['partners_count'] = partnersCount;
    if (details != null) {
      data['details'] = details!.map((key, value) => MapEntry(key, value.toJson()));
    }
    return data;
  }
}

class PartnersDetails {
  QarzDetail? qarzExpired;
  QarzDetail? qarzToday;
  QarzDetail? qarz3Days;

  PartnersDetails({this.qarzExpired, this.qarzToday, this.qarz3Days});

  PartnersDetails.fromJson(Map<String, dynamic> json) {
    qarzExpired = json['qarz_expired'] != null ? QarzDetail.fromJson(json['qarz_expired']) : null;
    qarzToday = json['qarz_today'] != null ? QarzDetail.fromJson(json['qarz_today']) : null;
    qarz3Days = json['qarz_3_days'] != null ? QarzDetail.fromJson(json['qarz_3_days']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (qarzExpired != null) {
      data['qarz_expired'] = qarzExpired!.toJson();
    }
    if (qarzToday != null) {
      data['qarz_today'] = qarzToday!.toJson();
    }
    if (qarz3Days != null) {
      data['qarz_3_days'] = qarz3Days!.toJson();
    }
    return data;
  }
}

class QarzDetail {
  int? count;
  String? type;

  QarzDetail({this.count, this.type});

  QarzDetail.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['type'] = type;
    return data;
  }
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