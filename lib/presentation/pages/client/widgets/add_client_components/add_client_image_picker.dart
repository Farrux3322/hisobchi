import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';

class AddClientImagePicker extends StatelessWidget {
  final File? selectedImage;
  final bool isUploading;
  final double uploadProgress;
  final VoidCallback onTap;

  const AddClientImagePicker({
    super.key,
    this.selectedImage,
    required this.isUploading,
    required this.uploadProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: isUploading ? null : onTap,
        child: Stack(
          children: [
            Hero(
              tag: 'client_image_preview',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                child: selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(35),
                        child: SvgPicture.asset(AppIcons.photo),
                      ),
              ),
            ),

            // Upload Progress Overlay
            if (isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: uploadProgress / 100,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${uploadProgress.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Yuklanmoqda...',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
