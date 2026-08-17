import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ehisob/presentation/components/back_button.dart';

class ProjectIncomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ProjectIncomeHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading:  BackArrowButton(),
      title: Text(
        title,

      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
