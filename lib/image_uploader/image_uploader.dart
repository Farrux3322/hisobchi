import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehisob/image_uploader/bloc/image_bloc.dart';
import 'package:ehisob/image_uploader/bloc/image_event.dart';
import 'package:ehisob/image_uploader/bloc/image_state.dart';
import 'package:ehisob/image_uploader/models/local_file_model.dart';
import 'package:ehisob/image_uploader/models/local_image_model.dart';
import 'package:ehisob/image_uploader/models/network_file_model.dart';
import 'package:ehisob/image_uploader/models/network_image_model.dart';
import 'package:ehisob/image_uploader/models/uploadable_image.dart';
import 'package:ehisob/image_uploader/utils/dialogs.dart';
import 'package:ehisob/image_uploader/widgets/file_widget.dart';
import 'package:ehisob/image_uploader/widgets/viewer.dart';
import 'package:ehisob/presentation/assets/theme/app_theme.dart';

class ImageUploader extends StatelessWidget {
  final List<UploadableImage> initialImages;
  final Future<String> Function(File file, void Function(int progress) onProgress) onUpload;
  final Future<void> Function(String id)? onDelete;

  final void Function(List<UploadableImage> images)? onChanged;

  const ImageUploader({
    super.key,
    this.initialImages = const [],
    required this.onUpload,
    this.onDelete,
    this.onChanged,
  });



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImageUploaderBloc(
        initialImages: initialImages,
        onUpload: onUpload,
        onDelete: onDelete,
      ),
      child: BlocConsumer<ImageUploaderBloc, ImageUploaderState>(
        listener: (context, state) {
          if (onChanged != null) {
            onChanged!(state.images);
          }
        },
        builder: (context, state) {
          final bloc = context.read<ImageUploaderBloc>();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.images.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index == state.images.length) {
                return GestureDetector(
                  onTap: () => _showActionSheet(context, bloc),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.add_a_photo),
                    ),
                  ),
                );
              }

              final image = state.images[index];

              Widget preview;
              if (image is NetworkImageModel) {
                preview = CachedNetworkImage(
                  imageUrl: image.path,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                );
              } else if (image is NetworkFileModel) {
                preview = FileWidget(name: image.fileName);
              } else if (image is LocalImageModel) {
                preview = Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              } else if (image is LocalFileModel) {
                preview = FileWidget(name: image.fileName);
              } else {
                preview = const SizedBox();
              }

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ImageViewerPage(
                              images: state.images,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: image.path,
                        child: preview,
                      ),
                    ),
                  ),
                  if (image is LocalImageModel && image.isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "${image.progress}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (image is LocalFileModel && image.isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "${image.progress}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          final confirm = await showDeleteConfirmationDialog(context);
                          if (confirm == true) {
                            bloc.add(RemoveImageEvent(image));
                          }
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showActionSheet(BuildContext context, ImageUploaderBloc bloc) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                bloc.add(PickImageEvent(false));
              },
              child: Text(
                "Galereyadan tanlash",
                style: AppTheme.data.textTheme.titleMedium,
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                bloc.add(PickImageEvent(true));
              },
              child: Text(
                "Kameradan olish",
                style: AppTheme.data.textTheme.titleMedium,
              ),
            ),
            // CupertinoActionSheetAction(
            //   onPressed: () {
            //     Navigator.pop(context);
            //     bloc.add(PickFileEvent());
            //   },
            //   child: Text(
            //     "Fayl tanlash",
            //     style: AppTheme.data.textTheme.titleMedium,
            //   ),
            // ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            isDefaultAction: true,
            child: Text(
              'Bekor qilish',
              style: AppTheme.data.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
