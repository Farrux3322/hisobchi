import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/identification/identification_bloc.dart';
import 'package:hisobchi/domain/common/myid_config.dart';
import 'package:hisobchi/infrastructure/repository/identification/identification_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:myid/enums.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';

class IdentificationPage extends StatelessWidget {
  const IdentificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IdentificationBloc(IdentificationRepository()),
      child: const IdentificationView(),
    );
  }
}

class IdentificationView extends StatelessWidget {
  const IdentificationView({super.key});

  Future<void> _startMyId(BuildContext context) async {
    final bloc = context.read<IdentificationBloc>();
    bloc.add(StartMyIdEvent());

    final config = MyIdConfig(
      sessionId: MyIdKeys.clientId, // In this SDK clientId is called sessionId
      clientHash: MyIdKeys.clientHash,
      clientHashId: MyIdKeys.clientHashId,
      entryType: MyIdEntryType.IDENTIFICATION,
      locale: MyIdLocale.UZBEK,
      cameraShape: MyIdCameraShape.CIRCLE,
      cameraResolution: MyIdCameraResolution.HIGH,
      withSoundGuides: true,
    );

    try {
      final result = await MyIdClient.start(config: config);
      
      if (result.code != null) {
        bloc.add(IdentityVerifiedEvent(result.code!));
      } else {
        bloc.add(const IdentityErrorEvent('Identifikatsiya kodi olinmadi'));
      }
    } catch (e) {
      bloc.add(IdentityErrorEvent('Xatolik: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IdentificationBloc, IdentificationState>(
      listener: (context, state) {
        if (state.status == IdentificationStatus.success) {
          _showSuccessMessage(context);
        } else if (state.status == IdentificationStatus.error) {
          _showErrorMessage(context, state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.colors.background,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                _buildIllustration(),
                SizedBox(height: 40.h),
                _buildInfoSection(),
                const Spacer(),
                _buildActionButton(context),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "Shaxsni tasdiqlash",
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
      ),
      leading: const BackArrowButton(),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.face_unlock_rounded,
          size: 64.sp,
          color: AppTheme.colors.primary,
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        Text(
          "MyID orqali identifikatsiya",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppTheme.colors.black),
        ),
        SizedBox(height: 16.h),
        Text(
          "Ilovadan to'liq foydalanish va operatsiyalar xavfsizligini ta'minlash uchun shaxsingizni tasdiqlashingiz lozim.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppTheme.colors.black.withValues(alpha: 0.6),
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 32.h),
        _buildStepItem(
          icon: Icons.camera_alt_outlined,
          text: "Yuzingizni kameraga ko'rsating",
        ),
        SizedBox(height: 12.h),
        _buildStepItem(
          icon: Icons.badge_outlined,
          text: "Pasport ma'lumotlarini tasdiqlang",
        ),
        SizedBox(height: 12.h),
        _buildStepItem(
          icon: Icons.verified_user_outlined,
          text: "Muvaffaqiyatli ro'yxatdan o'ting",
        ),
      ],
    );
  }

  Widget _buildStepItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.sp, color: AppTheme.colors.primary),
        ),
        SizedBox(width: 16.w),
        Text(
          text,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return BlocBuilder<IdentificationBloc, IdentificationState>(
      builder: (context, state) {
        final isLoading = state.status == IdentificationStatus.verifying || state.status == IdentificationStatus.loading;

        return ElevatedButton(
          onPressed: isLoading ? null : () => _startMyId(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.primary,
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            elevation: 0,
          ),
          child: isLoading
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              : Text(
                  "Identifikatsiyadan o'tish",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white),
                ),
        );
      },
    );
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Identifikatsiya muvaffaqiyatli yakunlandi!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
