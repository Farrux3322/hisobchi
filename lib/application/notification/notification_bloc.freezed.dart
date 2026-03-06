// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationEvent()';
}


}

/// @nodoc
class $NotificationEventCopyWith<$Res>  {
$NotificationEventCopyWith(NotificationEvent _, $Res Function(NotificationEvent) __);
}


/// Adds pattern-matching-related methods to [NotificationEvent].
extension NotificationEventPatterns on NotificationEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetNotifications value)?  getNotifications,TResult Function( ReadNotification value)?  readNotification,TResult Function( ReadAllNotifications value)?  readAllNotifications,TResult Function( GetUnreadCount value)?  getUnreadCount,TResult Function( ResetNotificationState value)?  reset,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetNotifications() when getNotifications != null:
return getNotifications(_that);case ReadNotification() when readNotification != null:
return readNotification(_that);case ReadAllNotifications() when readAllNotifications != null:
return readAllNotifications(_that);case GetUnreadCount() when getUnreadCount != null:
return getUnreadCount(_that);case ResetNotificationState() when reset != null:
return reset(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetNotifications value)  getNotifications,required TResult Function( ReadNotification value)  readNotification,required TResult Function( ReadAllNotifications value)  readAllNotifications,required TResult Function( GetUnreadCount value)  getUnreadCount,required TResult Function( ResetNotificationState value)  reset,}){
final _that = this;
switch (_that) {
case GetNotifications():
return getNotifications(_that);case ReadNotification():
return readNotification(_that);case ReadAllNotifications():
return readAllNotifications(_that);case GetUnreadCount():
return getUnreadCount(_that);case ResetNotificationState():
return reset(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetNotifications value)?  getNotifications,TResult? Function( ReadNotification value)?  readNotification,TResult? Function( ReadAllNotifications value)?  readAllNotifications,TResult? Function( GetUnreadCount value)?  getUnreadCount,TResult? Function( ResetNotificationState value)?  reset,}){
final _that = this;
switch (_that) {
case GetNotifications() when getNotifications != null:
return getNotifications(_that);case ReadNotification() when readNotification != null:
return readNotification(_that);case ReadAllNotifications() when readAllNotifications != null:
return readAllNotifications(_that);case GetUnreadCount() when getUnreadCount != null:
return getUnreadCount(_that);case ResetNotificationState() when reset != null:
return reset(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool isLoadMore)?  getNotifications,TResult Function( int id)?  readNotification,TResult Function()?  readAllNotifications,TResult Function()?  getUnreadCount,TResult Function()?  reset,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetNotifications() when getNotifications != null:
return getNotifications(_that.isLoadMore);case ReadNotification() when readNotification != null:
return readNotification(_that.id);case ReadAllNotifications() when readAllNotifications != null:
return readAllNotifications();case GetUnreadCount() when getUnreadCount != null:
return getUnreadCount();case ResetNotificationState() when reset != null:
return reset();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool isLoadMore)  getNotifications,required TResult Function( int id)  readNotification,required TResult Function()  readAllNotifications,required TResult Function()  getUnreadCount,required TResult Function()  reset,}) {final _that = this;
switch (_that) {
case GetNotifications():
return getNotifications(_that.isLoadMore);case ReadNotification():
return readNotification(_that.id);case ReadAllNotifications():
return readAllNotifications();case GetUnreadCount():
return getUnreadCount();case ResetNotificationState():
return reset();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool isLoadMore)?  getNotifications,TResult? Function( int id)?  readNotification,TResult? Function()?  readAllNotifications,TResult? Function()?  getUnreadCount,TResult? Function()?  reset,}) {final _that = this;
switch (_that) {
case GetNotifications() when getNotifications != null:
return getNotifications(_that.isLoadMore);case ReadNotification() when readNotification != null:
return readNotification(_that.id);case ReadAllNotifications() when readAllNotifications != null:
return readAllNotifications();case GetUnreadCount() when getUnreadCount != null:
return getUnreadCount();case ResetNotificationState() when reset != null:
return reset();case _:
  return null;

}
}

}

/// @nodoc


class GetNotifications implements NotificationEvent {
  const GetNotifications({this.isLoadMore = false});
  

@JsonKey() final  bool isLoadMore;

/// Create a copy of NotificationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetNotificationsCopyWith<GetNotifications> get copyWith => _$GetNotificationsCopyWithImpl<GetNotifications>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetNotifications&&(identical(other.isLoadMore, isLoadMore) || other.isLoadMore == isLoadMore));
}


@override
int get hashCode => Object.hash(runtimeType,isLoadMore);

@override
String toString() {
  return 'NotificationEvent.getNotifications(isLoadMore: $isLoadMore)';
}


}

/// @nodoc
abstract mixin class $GetNotificationsCopyWith<$Res> implements $NotificationEventCopyWith<$Res> {
  factory $GetNotificationsCopyWith(GetNotifications value, $Res Function(GetNotifications) _then) = _$GetNotificationsCopyWithImpl;
@useResult
$Res call({
 bool isLoadMore
});




}
/// @nodoc
class _$GetNotificationsCopyWithImpl<$Res>
    implements $GetNotificationsCopyWith<$Res> {
  _$GetNotificationsCopyWithImpl(this._self, this._then);

  final GetNotifications _self;
  final $Res Function(GetNotifications) _then;

/// Create a copy of NotificationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? isLoadMore = null,}) {
  return _then(GetNotifications(
isLoadMore: null == isLoadMore ? _self.isLoadMore : isLoadMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ReadNotification implements NotificationEvent {
  const ReadNotification({required this.id});
  

 final  int id;

/// Create a copy of NotificationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadNotificationCopyWith<ReadNotification> get copyWith => _$ReadNotificationCopyWithImpl<ReadNotification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadNotification&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'NotificationEvent.readNotification(id: $id)';
}


}

/// @nodoc
abstract mixin class $ReadNotificationCopyWith<$Res> implements $NotificationEventCopyWith<$Res> {
  factory $ReadNotificationCopyWith(ReadNotification value, $Res Function(ReadNotification) _then) = _$ReadNotificationCopyWithImpl;
@useResult
$Res call({
 int id
});




}
/// @nodoc
class _$ReadNotificationCopyWithImpl<$Res>
    implements $ReadNotificationCopyWith<$Res> {
  _$ReadNotificationCopyWithImpl(this._self, this._then);

  final ReadNotification _self;
  final $Res Function(ReadNotification) _then;

/// Create a copy of NotificationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(ReadNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ReadAllNotifications implements NotificationEvent {
  const ReadAllNotifications();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadAllNotifications);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationEvent.readAllNotifications()';
}


}




/// @nodoc


class GetUnreadCount implements NotificationEvent {
  const GetUnreadCount();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetUnreadCount);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationEvent.getUnreadCount()';
}


}




/// @nodoc


class ResetNotificationState implements NotificationEvent {
  const ResetNotificationState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetNotificationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationEvent.reset()';
}


}




// dart format on
