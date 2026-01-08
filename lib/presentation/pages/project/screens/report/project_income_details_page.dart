import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hisobchi/application/project_report/income_details/project_income_details_bloc.dart';
import 'package:hisobchi/infrastructure/dto/models/project_report/project_income_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ProjectIncomeDetailsPage extends StatelessWidget {
  final int projectId;

  const ProjectIncomeDetailsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectIncomeDetailsBloc()..add(GetIncomeDetailsEvent(projectId: projectId)),
      child: const _ProjectIncomeDetailsView(),
    );
  }
}

class _ProjectIncomeDetailsView extends StatelessWidget {
  const _ProjectIncomeDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Kirimlar tarixi',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        centerTitle: true,
      ),
      body: BlocBuilder<ProjectIncomeDetailsBloc, ProjectIncomeDetailsState>(
        builder: (context, state) {
          if (state.status == IncomeDetailsStatus.loading) {
            return const _LoadingShimmer();
          } else if (state.status == IncomeDetailsStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Xatolik'));
          } else if (state.status == IncomeDetailsStatus.success) {
            if (state.incomes.isEmpty) {
              return const Center(child: Text("Ma'lumot topilmadi"));
            }
            return ListView.separated(
              padding:  EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom),
              itemCount: state.incomes.length,
              separatorBuilder: (_, __) => const Gap(12),
              itemBuilder: (context, index) {
                return _IncomeCard(income: state.incomes[index]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _IncomeCard extends StatelessWidget {
  final ProjectIncomeDetailModel income;

  const _IncomeCard({required this.income});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###", "ru_RU");
    final isUzs = income.currencyTypeId == 1 || income.currencyType == 'UZS';
    final currencySymbol = isUzs ? 'UZS' : 'USD';
    final amountColor = const Color(0xFF10B981); // Green

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, size: 16, color: amountColor),
                    const Gap(6),
                    Text(
                      'Kirim',
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                income.createdAt ?? '',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            "${formatter.format(income.summa ?? 0).replaceAll(',', ' ')} $currencySymbol",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          if (income.description != null && income.description!.isNotEmpty) ...[
            const Gap(8),
            Text(
              income.description!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          if (income.files != null && income.files!.isNotEmpty) ...[
            const Gap(12),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: income.files!.length,
                separatorBuilder: (_, __) => const Gap(8),
                itemBuilder: (context, fileIndex) {
                  return GestureDetector(
                    onTap: () {
                      _openImageGallery(context, income.files!, fileIndex);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: income.files![fileIndex],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openImageGallery(BuildContext context, List<String> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoViewGallery.builder(
            itemCount: images.length,
            pageController: PageController(initialPage: index),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (_, __) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
