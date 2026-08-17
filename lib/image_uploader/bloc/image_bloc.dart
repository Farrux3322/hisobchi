import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:ehisob/image_uploader/bloc/image_event.dart';
import 'package:ehisob/image_uploader/bloc/image_state.dart';
import 'package:ehisob/image_uploader/models/local_file_model.dart';
import 'package:ehisob/image_uploader/models/local_image_model.dart';
import 'package:ehisob/image_uploader/models/network_file_model.dart';
import 'package:ehisob/image_uploader/models/network_image_model.dart';
import 'package:ehisob/image_uploader/models/uploadable_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ImageUploaderBloc extends Bloc<ImageUploaderEvent, ImageUploaderState> {
  final Future<String> Function(File file, void Function(int progress) onProgress) onUpload;
  final Future<void> Function(String id)? onDelete;

  final _picker = ImagePicker();

  ImageUploaderBloc({
    required List<UploadableImage> initialImages,
    required this.onUpload,
    this.onDelete,
  }) : super(ImageUploaderState(images: initialImages)) {
    on<PickImageEvent>(_onPickImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<PickFileEvent>(_onPickFile);

  }

  Future<void> _onPickImage(PickImageEvent event, Emitter<ImageUploaderState> emit) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: event.fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Rasmni qirqish',
            toolbarColor: CupertinoColors.black,
            toolbarWidgetColor: CupertinoColors.white,
          ),
          IOSUiSettings(title: 'Rasmni qirqish'),
        ],
      );
      if (croppedFile == null) return;

      var localImage = LocalImageModel(
        path: croppedFile.path,
        isUploading: true,
        progress: 0,
      );
      var updatedImages = [...state.images, localImage];
      emit(state.copyWith(images: updatedImages));

      final uploadedUrl = await onUpload(
        File(croppedFile.path),
            (progress) {
          localImage = localImage.copyWith(
            isUploading: true,
            progress: progress,
          );
          updatedImages[updatedImages.length - 1] = localImage;
          emit(state.copyWith(images: updatedImages));
        },
      );

      final networkImage = NetworkImageModel(
        id: uploadedUrl,
        url: uploadedUrl,
        localPath: croppedFile.path
      );
      updatedImages[updatedImages.length - 1] = networkImage;
      emit(state.copyWith(images: updatedImages));
    } catch (e) {
      debugPrint('Image upload error: $e');
      final updatedImages = [...state.images];
      if (updatedImages.isNotEmpty && updatedImages.last is LocalImageModel) {
        updatedImages.removeLast();
        emit(state.copyWith(images: updatedImages));
      }
    }
  }

  Future<void> _onPickFile(
      PickFileEvent event,
      Emitter<ImageUploaderState> emit,
      ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']
      );

      if (result == null) return;

      final filePath = result.files.single.path;
      final fileName = result.files.single.name;

      if (filePath == null) return;

      var localFile = LocalFileModel(
        path: filePath,
        fileName: fileName,
        isUploading: true,
        progress: 0,
      );

      var updatedImages = [...state.images, localFile];
      emit(state.copyWith(images: updatedImages));

      final uploadedUrl = await onUpload(
        File(filePath),
            (progress) {
          localFile = localFile.copyWith(
            progress: progress,
            isUploading: true,
          );
          updatedImages[updatedImages.length - 1] = localFile;
          emit(state.copyWith(images: updatedImages));
        },
      );

      final networkFile = NetworkFileModel(
        id: uploadedUrl,
        url: uploadedUrl,
        fileName: fileName,
      );

      updatedImages[updatedImages.length - 1] = networkFile;
      emit(state.copyWith(images: updatedImages));
    } catch (e) {
      debugPrint('File upload error: $e');

      var updatedImages = [...state.images];
      if (updatedImages.isNotEmpty && updatedImages.last is LocalFileModel) {
        updatedImages.removeLast();
        emit(state.copyWith(images: updatedImages));
      }
    }
  }


  Future<void> _onRemoveImage(RemoveImageEvent event, Emitter<ImageUploaderState> emit) async {
    try {
      if (event.image.id != null && onDelete != null) {
        await onDelete!(event.image.id!);
      }
    } catch (e) {
      debugPrint('Image delete error: $e');
    }

    final updatedImages = [...state.images]..remove(event.image);
    emit(state.copyWith(images: updatedImages));
  }
}
