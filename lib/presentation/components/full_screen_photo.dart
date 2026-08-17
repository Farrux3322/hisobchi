import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ehisob/presentation/assets/theme/app_theme.dart';

/// Rasm ma'lumotlarini saqlash uchun model
class ImageItem {
  final String path;
  final bool isNetwork;
  final String? id; // Ixtiyoriy ID o'chirish yoki tahrirlash uchun

  ImageItem({
    required this.path,
    this.isNetwork = true,
    this.id,
  });
}

/// Senior-level rasm ko'ruvchi sahifa
/// Zoom, Galereya, Page Indicator va Harakatlar (Update/Delete) bilan
class ImageViewerPage extends StatefulWidget {
  final List<ImageItem> images;
  final int initialIndex;
  
  /// O'chirish tugmasi bosilganda chaqiriladigan callback
  final Function(int index, ImageItem image)? onDelete;
  
  /// Tahrirlash tugmasi bosilganda chaqiriladigan callback
  final Function(int index, ImageItem image)? onUpdate;

  const ImageViewerPage({
    super.key,
    required this.images,
    required this.initialIndex,
    this.onDelete,
    this.onUpdate,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late final PageController _controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDelete() {
    if (widget.onDelete == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rasmni o\'chirish'),
        content: const Text('Haqiqatan ham ushbu rasmni o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish', style: TextStyle(color: AppTheme.colors.gray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete!(currentIndex, widget.images[currentIndex]);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              fixedSize: const Size(100, 40),
            ),
            child: const Text('O\'chirish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Galereya korpusi
          PhotoViewGallery.builder(
            pageController: _controller,
            itemCount: widget.images.length,
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (context, index) {
              final image = widget.images[index];
              ImageProvider imageProvider;
              
              if (image.isNetwork) {
                imageProvider = CachedNetworkImageProvider(image.path);
              } else {
                imageProvider = FileImage(File(image.path));
              }
              
              return PhotoViewGalleryPageOptions(
                imageProvider: imageProvider,
                heroAttributes: PhotoViewHeroAttributes(tag: image.path),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.5,
              );
            },
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, event) => Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  value: event == null || event.expectedTotalBytes == null
                      ? null
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                  color: AppTheme.colors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),

          // Yuqori boshqaruv paneli
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Yopish tugmasi
                _buildActionButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),

                Row(
                  children: [
                    // Tahrirlash tugmasi
                    if (widget.onUpdate != null) ...[
                      _buildActionButton(
                        icon: Icons.edit_rounded,
                        onTap: () => widget.onUpdate!(currentIndex, widget.images[currentIndex]),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // O'chirish tugmasi
                    if (widget.onDelete != null)
                      _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        color: AppTheme.colors.red,
                        onTap: _handleDelete,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Pastki page indicator
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: widget.images.length,
                    effect: WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppTheme.colors.primary,
                      dotColor: Colors.white.withValues(alpha: 0.3),
                      spacing: 12,
                    ),
                  ),
                ),
              ),
            ),
            
          // Rasm raqami (masalan: 1/5)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 65,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(blurRadius: 4, color: Colors.black),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: color ?? Colors.white,
          size: 24,
        ),
      ),
    );
  }
}