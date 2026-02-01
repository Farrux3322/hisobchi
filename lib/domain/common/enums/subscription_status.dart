enum SubscriptionStatus {
  active,
  gracePeriod,
  readOnly,
  archived,
  deleted;

  static SubscriptionStatus fromServer(String? value) {
    switch (value) {
      case 'ACTIVE':
        return SubscriptionStatus.active;
      case 'GRACE_PERIOD':
        return SubscriptionStatus.gracePeriod;
      case 'READ_ONLY':
        return SubscriptionStatus.readOnly;
      case 'ARCHIVED':
        return SubscriptionStatus.archived;
      case 'DELETED':
        return SubscriptionStatus.deleted;
      default:
        return SubscriptionStatus.active;
    }
  }

  bool get isActive => this == SubscriptionStatus.active;
  bool get isGracePeriod => this == SubscriptionStatus.gracePeriod;
  bool get isReadOnly => this == SubscriptionStatus.readOnly;
  bool get isArchived => this == SubscriptionStatus.archived;
  bool get isDeleted => this == SubscriptionStatus.deleted;

  bool get canCreate => this == SubscriptionStatus.active || this == SubscriptionStatus.gracePeriod;
  bool get canViewDetails => this != SubscriptionStatus.archived && this != SubscriptionStatus.deleted;
}
