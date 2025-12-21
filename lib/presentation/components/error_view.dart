import 'package:flutter/material.dart';
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Text(
          error,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
