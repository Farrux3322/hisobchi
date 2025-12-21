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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetNotifications value)?  getNotifications,TResult Function( ShowNotification value)?  showNotification,TResult Function( ReadAllNotifications value)?  readAllNotifications,TResult Function( ResetNotificationState value)?  reset,TResult Function( ReadNotification value)?  readNotification,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetNotifications() when getNotifications != null:
return getNotifications(_that);case ShowNotification() when showNotification != null:
return showNotification(_that);case ReadAllNotifications() when readAllNotifications != null:
return readAllNotifications(_that);case ResetNotificationState() when reset != null:
return reset(_that);case ReadNotification() when readNotification != null:
return readNotification(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetNotifications value)  getNotifications,required TResult Function( ShowNotification value)  showNotification,required TResult Function( ReadAllNotifications value)  readAllNotifications,required TResult Function( ResetNotificationState value)  reset,required TResult Function( ReadNotification value)  readNotification,}){
final _that = this;
switch (_that) {
case GetNotifications():
return getNotifications(_that);case ShowNotification():
return showNotification(_that);case ReadAllNotifications():
return readAllNotifications(_that);case ResetNotificationState():
return reset(_that);case ReadNotification():
return readNotification(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetNotifications value)?  getNotifications,TResult? Function( ShowNotification value)?  showNotification,TResult? Function( ReadAllNotifications value)?  readAllNotifications,TResult? Function( ResetNotificationState value)?  reset,TResult? Function( ReadNotification value)?  readNotification,}){
final _that = this;
switch (_that) {
case GetNotifications() when getNotifications != null:
return getNotifications(_that);case ShowNotification() when showNotification != null:
return showNotification(_that);case ReadAllNotifications() when readAllNotifications != null:
return readAllNotifications(_that);case ResetNotificationState() when reset != null:
return reset(_that);case ReadNotification() when readNotification != null:
return readNotification(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int status)?  getNotifications,TResult Function( NotificationModel notification,  int status)?  showNotification,TResult Function( int status)?  readAllNotifications,TResult Function()?  reset,TResult Function( int id)?  readNotification,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetNotifications() when getNotifications != null:
return getNotifications(_that.status);case ShowNotification() when showNotification != null:
return showNotification(_that.notification,_that.status);case ReadAllNotifications() when readAllNotifications != null:
return readAllNotifications(_that.status);case ResetNotificationState() when reset != null:
return reset();case ReadNotification() when readNotification != null:
return readNotification(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int status)  getNotifications,required TResult Function( NotificationModel notification,  int status)  showNotification,required TResult Function( int status)  readAllNotifications,required TResult Function()  reset,required TResult Function( int id)  readNotification,}) {final _that = this;
switch (_that) {
case GetNotifications():
return getNotifications(_that.status);case ShowNotification():
return showNotification(_that.notification,_that.status);case ReadAllNotifications():
return readAllNotifications(_that.status);case ResetNotificationState():
return reset();case ReadNotification():
return readNotification(_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int status)?  getNotifications,TResult? Function( NotificationModel notification,  int status)?  showNotification,TResult? Function( int status)?  readAllNotifications,TResult? Function()?  reset,TResult? Function( int id)?  readNotification,}) {final _that = this;
switch (_that) {
case GetNotifications() when getNotifications != null:
return getNotifications(_that.status);case ShowNotification() when showNotification != null:
return showNotification(_that.notification,_that.status);case ReadAllNotifications() when readAllNotifications != null:
return readAllNotifications(_that.status);case ResetNotificationState() when reset != null:
return reset();case ReadNotification() when readNotification != null:
return readNotification(_that.id);case _:
  return null;

}
}

}

/// @nodoc


class GetNotifications implements NotificationEvent {
  const GetNotifications({required this.status});
  

 final  int status;

/// Create a copy of NotificationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetNotificationsCopyWith<GetNotifications> get copyWith => _$GetNotificationsCopyWithImpl<GetNotifications>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetNotifications&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'NotificationEvent.getNotifications(status: $status)';
}


}

/// @nodoc
abstract mixin class $GetNotificationsCopyWith<$Res> implements $NotificationEventCopyWith<$Res> {
  factory $GetNotificationsCopyWith(GetNotifications value, $Res Function(GetNotifications) _then) = _$GetNotificationsCopyWithImpl;
@useResult
$Res call({
 int status
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
@pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(GetNotifications(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ShowNotification implements NotificationEvent {
  const ShowNotification(this.notification, this.status);
  

 final  NotificationModel notification;
 final  int status;

/// Create a copy of NotificationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowNotificationCopyWith<ShowNotification> get copyWith => _$ShowNotificationCopyWithImpl<ShowNotification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowNotification&&(identical(other.notification, notification) || other.notification == notification)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,notification,status);

@override
String toString() {
  return 'NotificationEvent.showNotification(notification: $notification, status: $status)';
}


}

/// @nodoc
abstract mixin class $ShowNotificationCopyWith<$Res> implements $NotificationEventCopyWith<$Res> {
  factory $ShowNotificationCopyWith(ShowNotification value, $Res Function(ShowNotification) _then) = _$ShowNotificationCopyWithImpl;
@useResult
$Res call({
 NotificationModel notification, int status
});




}
/// @nodoc
class _$ShowNotificationCopyWithImpl<$Res>
    implements $ShowNotificationCopyWith<$Res> {
  _$ShowNotificationCopyWithImpl(this._self, this._then);

  final ShowNotification _self;
  final $Res Function(ShowNotification) _then;

/// Create a copy of NotificationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? notification = null,Object? status = null,}) {
  return _then(ShowNotification(
null == notification ? _self.notification : notification // ignore: cast_nullable_to_non_nullable
as NotificationModel,null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ReadAllNotifications implements NotificationEvent {
  const ReadAllNotifications({required this.status});
  

 final  int status;

/// Create a copy of NotificationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadAllNotificationsCopyWith<ReadAllNotifications> get copyWith => _$ReadAllNotificationsCopyWithImpl<ReadAllNotifications>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadAllNotifications&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'NotificationEvent.readAllNotifications(status: $status)';
}


}

/// @nodoc
abstract mixin class $ReadAllNotificationsCopyWith<$Res> implements $NotificationEventCopyWith<$Res> {
  factory $ReadAllNotificationsCopyWith(ReadAllNotifications value, $Res Function(ReadAllNotifications) _then) = _$ReadAllNotificationsCopyWithImpl;
@useResult
$Res call({
 int status
});




}
/// @nodoc
class _$ReadAllNotificationsCopyWithImpl<$Res>
    implements $ReadAllNotificationsCopyWith<$Res> {
  _$ReadAllNotificationsCopyWithImpl(this._self, this._then);

  final ReadAllNotifications _self;
  final $Res Function(ReadAllNotifications) _then;

/// Create a copy of NotificationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(ReadAllNotifications(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
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

// dart format on
