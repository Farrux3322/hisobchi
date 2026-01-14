import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';

class ImageUploadItem {
  File? file;
  int? id;
  String? existingUrl;
  bool isUploading;
  double progress;

  ImageUploadItem({this.file, this.id, this.existingUrl, this.isUploading = false, this.progress = 0});
}

class EditKirimImagePicker extends StatelessWidget {
  final List<ImageUploadItem> images;
  final bool isEditing;
  final Function(int) onAddImage;
  final Function(int) onViewImage;

  const EditKirimImagePicker({
    super.key,
    required this.images,
    required this.isEditing,
    required this.onAddImage,
    required this.onViewImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rasmlar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              final img = images[index];
              final hasImage = img.file != null || img.existingUrl != null;

              return GestureDetector(
                onTap: () {
                  if (isEditing && !hasImage) {
                    onAddImage(index);
                  } else if (hasImage) {
                    onViewImage(index);
                  }
                },
                child: Container(
                  width: 100.w,
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (img.existingUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: img.existingUrl!,
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        )
                      else if (img.file != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            img.file!,
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Icon(Icons.add_photo_alternate_outlined, color: const Color(0xFF94A3B8), size: 32.sp),
                      
                      if (img.isUploading)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: img.progress / 100,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${img.progress.toInt()}%',
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
