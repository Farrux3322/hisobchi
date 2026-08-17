import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ehisob/image_uploader/models/uploadable_image.dart';
import 'package:ehisob/presentation/assets/theme/app_theme.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
class ImageViewerPage extends StatefulWidget {
  final List<UploadableImage> images;
  final int initialIndex;

  const ImageViewerPage({
    super.key,
    required this.images,
    required this.initialIndex,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(bottom:MediaQuery.of(context).padding.bottom),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                final image = widget.images[index];

                // 🟡 PDFmi yoki IMAGEmi tekshiramiz
                if (_isPdf(image.path)) {
                  // Agar PDF bo'lsa
                  return SizedBox();
                  // return _buildPdfViewer(image);
                } else {
                  // Agar rasm bo'lsa
                  return PhotoView(
                    backgroundDecoration: BoxDecoration(color: Colors.white),
                    imageProvider: image.isNetwork
                        ? CachedNetworkImageProvider(image.path)
                        : FileImage(File(image.path)),
                    heroAttributes: PhotoViewHeroAttributes(tag: image.path),
                  );
                }
              },
            ),
            Positioned(
              top: 80,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: widget.images.length,
                    effect:  WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppTheme.colors.primary,
                      dotColor: Colors.grey,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
  //
  // /// 🟡 PDF ko'rsatish uchun widget
  // Widget _buildPdfViewer(UploadableImage image) {
  //   if (image.isNetwork) {
  //     return SfPdfViewer.network(
  //       image.path,
  //       canShowScrollStatus: true,
  //       canShowPaginationDialog: true,
  //     );
  //   } else {
  //     return SfPdfViewer.file(
  //       File(image.path),
  //       canShowScrollStatus: true,
  //       canShowPaginationDialog: true,
  //     );
  //   }
  // }

  /// 🟡 PDFni aniqlash
  bool _isPdf(String path) {
    return path.toLowerCase().endsWith(".pdf");
  }
}
