import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/full_screen_photo.dart';

class ImageData {
  final File? file;
  final int? fileId;
  final int? existingId;
  final String? existingUrl;
  final bool isUploading;
  final double progress;

  ImageData({
    this.file,
    this.fileId,
    this.existingId,
    this.existingUrl,
    this.isUploading = false,
    this.progress = 0,
  });
}

class ProjectIncomeImagePicker extends StatelessWidget {
  final List<ImageData> images;
  final Function(int index) onAddImage;
  final Function(int index) onRemoveImage;
  final Function(int index)? onUpdateImage;

  const ProjectIncomeImagePicker({
    super.key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
    this.onUpdateImage,
  });

  void _openFullScreen(BuildContext context, int initialIndex) {
    final activeImages = <ImageItem>[];
    final originalIndices = <int>[];

    for (int i = 0; i < images.length; i++) {
      final img = images[i];
      if (img.file != null) {
        activeImages.add(ImageItem(path: img.file!.path, isNetwork: false, id: img.fileId?.toString()));
        originalIndices.add(i);
      } else if (img.existingUrl != null) {
        activeImages.add(ImageItem(path: img.existingUrl!, isNetwork: true, id: img.existingId?.toString()));
        originalIndices.add(i);
      }
    }

    if (activeImages.isEmpty) return;
    
    if (initialIndex >= activeImages.length) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerPage(
          images: activeImages,
          initialIndex: initialIndex,
          onDelete: (index, item) {
             if (index < originalIndices.length) {
               onRemoveImage(originalIndices[index]);
              //  We might want to close the viewer here if behavior requires it, 
              //  but we'll let the user decide if they want to stay in the viewer.
              //  Usually standard behavior is to stay or pop.
              //  Given the simple ImageViewerPage, popping might be safer to avoid showing stale data.
               Navigator.of(context).maybePop();
             }
          },
          onUpdate: onUpdateImage != null ? (index, item) {
             if (index < originalIndices.length) {
               onUpdateImage!(originalIndices[index]);
               Navigator.of(context).maybePop(); // Close viewer to show picker/update
             }
          } : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.image_outlined, size: 20.sp, color: AppTheme.colors.primary),
            ),
            SizedBox(width: 12.w),
            Text(
              'Hujjat rasmlari',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1,
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            final imageData = images[index];
            final hasImage = imageData.file != null || imageData.existingUrl != null;
            final canAddImage = index == 0 || (images[index - 1].file != null || images[index - 1].existingUrl != null);

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (hasImage) {
                  _openFullScreen(context, index);
                } else if (canAddImage) {
                  onAddImage(index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: hasImage ? Colors.white : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: hasImage ? AppTheme.colors.primary.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                    width: hasImage ? 2 : 1.5,
                  ),
                  boxShadow: hasImage
                      ? [
                          BoxShadow(
                            color: AppTheme.colors.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: hasImage ? _buildImagePreview(imageData, index) : _buildImagePlaceholder(canAddImage, index),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImagePreview(ImageData imageData, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: imageData.file != null
              ? Image.file(
                  imageData.file!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: imageData.existingUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                ),
        ),
        if (imageData.isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32.w,
                    height: 32.h,
                    child: CircularProgressIndicator(
                      value: imageData.progress / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${imageData.progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Positioned(
            top: 6.h,
            right: 6.w,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onRemoveImage(index);
              },
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.close, color: Colors.white, size: 14.sp),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePlaceholder(bool canAddImage, int index) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            canAddImage ? Icons.add_photo_alternate_outlined : Icons.image_outlined,
            color: canAddImage ? AppTheme.colors.primary : const Color(0xFF94A3B8),
            size: 32.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'Rasm ${index + 1}',
            style: TextStyle(
              fontSize: 11.sp,
              color: canAddImage ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
