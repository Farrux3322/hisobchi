

import 'package:ehisob/image_uploader/models/uploadable_image.dart';

class ImageUploaderState {
  final List<UploadableImage> images;

  ImageUploaderState({
    this.images = const [],
  });

  ImageUploaderState copyWith({
    List<UploadableImage>? images,
  }) {
    return ImageUploaderState(
      images: images ?? this.images,
    );
  }
}
