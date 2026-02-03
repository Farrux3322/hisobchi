class NotificationResponseModel {
  final bool? status;
  final NotificationPaginationData? result;

  NotificationResponseModel({this.status, this.result});

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      status: json['status'],
      result: json['result'] != null ? NotificationPaginationData.fromJson(json['result']) : null,
    );
  }
}

class NotificationPaginationData {
  final int? currentPage;
  final List<NotificationItemModel>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  NotificationPaginationData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory NotificationPaginationData.fromJson(Map<String, dynamic> json) {
    return NotificationPaginationData(
      currentPage: json['current_page'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => NotificationItemModel.fromJson(i)).toList()
          : null,
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class NotificationItemModel {
  final int? id;
  final int? userId;
  final int? notificationId;
  final bool? isRead;
  final String? readAt;
  final String? createdAt;
  final String? updatedAt;
  final NotificationDetailModel? notification;

  NotificationItemModel({
    this.id,
    this.userId,
    this.notificationId,
    this.isRead,
    this.readAt,
    this.createdAt,
    this.updatedAt,
    this.notification,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'],
      userId: json['user_id'],
      notificationId: json['notification_id'],
      isRead: json['is_read'] is bool ? json['is_read'] : (json['is_read'] == 1),
      readAt: json['read_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      notification: json['notification'] != null ? NotificationDetailModel.fromJson(json['notification']) : null,
    );
  }

  NotificationItemModel copyWith({bool? isRead}) {
    return NotificationItemModel(
      id: id,
      userId: userId,
      notificationId: notificationId,
      isRead: isRead ?? this.isRead,
      readAt: readAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notification: notification,
    );
  }
}

class NotificationDetailModel {
  final int? id;
  final String? uuid;
  final String? type;
  final String? title;
  final String? body;
  final dynamic data;
  final String? imageUrl;
  final String? targetType;
  final List<dynamic>? targetUsers;
  final int? sentCount;
  final int? failedCount;
  final String? status;
  final String? sentAt;
  final String? createdAt;
  final String? updatedAt;

  NotificationDetailModel({
    this.id,
    this.uuid,
    this.type,
    this.title,
    this.body,
    this.data,
    this.imageUrl,
    this.targetType,
    this.targetUsers,
    this.sentCount,
    this.failedCount,
    this.status,
    this.sentAt,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationDetailModel.fromJson(Map<String, dynamic> json) {
    return NotificationDetailModel(
      id: json['id'],
      uuid: json['uuid'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      data: json['data'],
      imageUrl: json['image_url'],
      targetType: json['target_type'],
      targetUsers: json['target_users'],
      sentCount: json['sent_count'],
      failedCount: json['failed_count'],
      status: json['status'],
      sentAt: json['sent_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
