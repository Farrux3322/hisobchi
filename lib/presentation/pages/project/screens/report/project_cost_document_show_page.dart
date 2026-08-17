import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ehisob/infrastructure/dto/models/project_report/project_cost_detail_item_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/back_button.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ProjectCostDocumentShowPage extends StatefulWidget {
  final ProjectCostDetailItemModel cost;

  const ProjectCostDocumentShowPage({super.key, required this.cost});

  @override
  State<ProjectCostDocumentShowPage> createState() => _ProjectCostDocumentShowPageState();
}

class _ProjectCostDocumentShowPageState extends State<ProjectCostDocumentShowPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.9, curve: Curves.easeIn),
    );

    _slideAnimations = List.generate(
      8,
      (index) {
        // Stability Fix: Ensure interval bounds are strictly within [0.0, 1.0]
        final double start = (0.1 + (index * 0.04)).clamp(0.0, 0.9);
        final double end = (start + 0.4).clamp(0.0, 1.0);
        
        return Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(start, end, curve: Curves.easeOutBack),
          ),
        );
      },
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###", "ru_RU");
    final summa = widget.cost.summa?.toDouble() ?? 0;
    final formattedSumma = formatter.format(summa).replaceAll(',', ' ');
    final currency = widget.cost.currencyType ?? '';
    final createdAt = widget.cost.createdAt ?? '';
    final workerName = widget.cost.workerName;
    final hasWorker = workerName != null && workerName.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackArrowButton(),
        centerTitle: true,
        title: Text(
          'Xarajat tafsiloti',

        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Elite Sculpted Header
            _buildAnimatedItem(
              index: 0,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 12.h),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.cost.costTypeName?.toUpperCase() ?? 'LOYIHA XARAJATI',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Gap(24),
                    Text(
                      formattedSumma,
                      style: TextStyle(
                        fontSize: 46.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -1.2,
                      ),
                    ),
                    Text(
                      currency,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      createdAt,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                children: [
                  // Unified Ledger Card
                  _buildAnimatedItem(
                    index: 1,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: Colors.white),
                      ),
                      child: Column(
                        children: [
                          if (hasWorker) ...[
                            _buildLedgerRow(
                              icon: AppIcons.clients,
                              label: "Mas'ul ishchi",
                              value: workerName,
                              color: const Color(0xFF6366F1),
                              showDivider: true,
                            ),
                          ],
                          _buildLedgerRow(
                            icon: AppIcons.chiqim,
                            label: "Xarajat turi",
                            value: widget.cost.costTypeName ?? "Aniqlanmagan",
                            color: const Color(0xFF10B981),
                            showDivider: widget.cost.description != null && widget.cost.description!.isNotEmpty,
                          ),
                          if (widget.cost.description != null && widget.cost.description!.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE2E8F0),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const Gap(12),
                                      Text(
                                        "IZOH",
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF94A3B8),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(12),
                                  Text(
                                    widget.cost.description!,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      height: 1.6,
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const Gap(12),

                  // Elite Gallery Section
                  if (widget.cost.files != null && widget.cost.files!.isNotEmpty) ...[
                    _buildAnimatedItem(
                      index: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "BIRIKTIRILGAN FAYLLAR",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF64748B),
                                letterSpacing: 1.2,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.cost.files!.length.toString(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(16),
                    _buildAnimatedItem(
                      index: 4,
                      child: _buildEliteGallery(context),
                    ),
                  ],
                  Gap(40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerRow({
    required String icon,
    required String label,
    required String value,
    required Color color,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(12.w),
                child: SvgPicture.asset(
                  icon,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
      ],
    );
  }

  Widget _buildEliteGallery(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemCount: widget.cost.files!.length,
      itemBuilder: (context, index) {
        final fileUrl = widget.cost.files![index];
        return GestureDetector(
          onTap: () => _openImageGallery(context, widget.cost.files!, index),
          child: Hero(
            tag: fileUrl,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: fileUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Center(child: CircularProgressIndicator.adaptive()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(Icons.broken_image_outlined, color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimations[index % _slideAnimations.length],
        child: child,
      ),
    );
  }

  void _openImageGallery(BuildContext context, List<String> files, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: PhotoViewGallery.builder(
            itemCount: files.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(files[index]),
                heroAttributes: PhotoViewHeroAttributes(tag: files[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
        ),
      ),
    );
  }
}
