

import 'package:ehisob/image_uploader/models/uploadable_image.dart';

abstract class ImageUploaderEvent {}

class PickImageEvent extends ImageUploaderEvent {
  final bool fromCamera;
  PickImageEvent(this.fromCamera);
}

class RemoveImageEvent extends ImageUploaderEvent {
  final UploadableImage image;
  RemoveImageEvent(this.image);
}

class PickFileEvent extends ImageUploaderEvent {}
