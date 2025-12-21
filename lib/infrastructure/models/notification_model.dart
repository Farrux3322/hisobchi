class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.viewed,
    required this.date,
  });

  final int? id;
  final String? title;
  final String? body;
  final bool? viewed;
  final String? date;

  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    bool? viewed,
    String? date,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      viewed: viewed ?? this.viewed,
      date: date ?? this.date,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json){
    return NotificationModel(
      id: json["id"],
      title: json["title"],
      body: json["body"],
      viewed: json["viewed"],
      date: json["date"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "body": body,
    "viewed": viewed,
    "date": date,
  };

  @override
  String toString(){
    return "$id, $title, $body, $viewed, $date, ";
  }
}
