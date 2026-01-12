import 'dart:io';
import 'package:flutter/material.dart';

/// Full screen image viewer widget with zoom and pan capabilities
///
/// Bu komponent rasmni to'liq ekranda ko'rsatish, zoom qilish va boshqa
/// harakatlarni amalga oshirish uchun ishlatiladi.
///
/// Foydalanish:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     fullscreenDialog: true,
///     builder: (context) => FullScreenPhoto(
///       imageFile: File('path/to/image.jpg'),
///       heroTag: 'unique_tag',
///       onDelete: () {
///         // O'chirish logikasi
///       },
///       onEdit: () {
///         // Tahrirlash logikasi
///       },
///     ),
///   ),
/// );
/// ```
class FullScreenPhoto extends StatefulWidget {
  /// Rasm fayli
  final File? imageFile;

  /// Network rasmning URL manzili
  final String? imageUrl;

  /// Hero animation uchun unique tag
  final String heroTag;

  /// O'chirish tugmasi bosilganda chaqiriladigan callback
  /// Agar null bo'lsa, o'chirish tugmasi ko'rsatilmaydi
  final VoidCallback? onDelete;

  /// Tahrirlash tugmasi bosilganda chaqiriladigan callback
  /// Agar null bo'lsa, tahrirlash tugmasi ko'rsatilmaydi
  final VoidCallback? onEdit;

  /// Rasmni o'chirish tasdiqlash dialogini ko'rsatish kerakmi
  /// Default: true
  final bool showDeleteConfirmation;

  /// O'chirish tasdiqlash dialog sarlavhasi
  final String deleteConfirmationTitle;

  /// O'chirish tasdiqlash dialog xabari
  final String deleteConfirmationMessage;

  const FullScreenPhoto({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.heroTag,
    this.onDelete,
    this.onEdit,
    this.showDeleteConfirmation = true,
    this.deleteConfirmationTitle = 'Rasmni o\'chirish',
    this.deleteConfirmationMessage = 'Tanlangan rasmni o\'chirishni xohlaysizmi?',
  }) : assert(
          imageFile != null || imageUrl != null,
          'imageFile yoki imageUrl kamida bittasi berilishi kerak',
        );

  @override
  State<FullScreenPhoto> createState() => _FullScreenPhotoState();
}

class _FullScreenPhotoState extends State<FullScreenPhoto>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value = _animation!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Handle double tap to zoom in/out
  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    final position = _doubleTapDetails!.localPosition;
    final currentScale = _transformationController.value.getMaxScaleOnAxis();

    Matrix4 matrix;

    if (currentScale > 1.0) {
      // Zoom out to original size
      matrix = Matrix4.identity();
    } else {
      // Zoom in 2.5x at tap position
      final double scale = 2.5;
      final double x = -position.dx * (scale - 1);
      final double y = -position.dy * (scale - 1);
      matrix = Matrix4.identity()
        ..translate(x, y)
        ..scale(scale);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: matrix,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward(from: 0);
  }

  void _handleDelete() {
    if (widget.onDelete == null) return;

    if (widget.showDeleteConfirmation) {
      _showDeleteConfirmation();
    } else {
      widget.onDelete!();
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.deleteConfirmationTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.deleteConfirmationMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'Bekor qilish',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (widget.onDelete != null) {
                            widget.onDelete!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'O\'chirish',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    if (widget.imageFile != null) {
      return Image.file(
        widget.imageFile!,
        fit: BoxFit.contain,
      );
    } else if (widget.imageUrl != null) {
      return Image.network(
        widget.imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Rasmni yuklashda xatolik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Text(
          'Rasm topilmadi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable Image
          GestureDetector(
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: Center(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: widget.heroTag,
                  child: _buildImage(),
                ),
              ),
            ),
          ),

          // Top app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Edit button (agar onEdit berilgan bo'lsa)
                      if (widget.onEdit != null) ...[
                        IconButton(
                          onPressed: widget.onEdit,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],

                      // Delete button (agar onDelete berilgan bo'lsa)
                      if (widget.onDelete != null)
                        IconButton(
                          onPressed: _handleDelete,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom hint text
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Ikki marta bosib zoom qiling',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}