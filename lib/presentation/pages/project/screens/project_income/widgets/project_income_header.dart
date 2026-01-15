import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';

class ProjectIncomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ProjectIncomeHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      surfaceTintColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: const Color.fromRGBO(255, 255, 255, 0.1),
                  blurRadius: 1,
                  spreadRadius: 0,
                  offset: const Offset(0, 1)),
              BoxShadow(
                  color: const Color.fromRGBO(50, 50, 93, 0.25),
                  blurRadius: 100,
                  spreadRadius: -20,
                  offset: const Offset(0, 50)),
              BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.3),
                  blurRadius: 60,
                  spreadRadius: -30,
                  offset: const Offset(0, 30)),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
