import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:momos/utils/const_image_key.dart';

class LoadingDialog extends StatefulWidget {
  final Color? color;
  final double? width;
  final double? height;

  const LoadingDialog({super.key, this.color, this.width, this.height});

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.color ?? Colors.white24,
      body: Center(
        child: Lottie.asset(
          AppImages().loading,
          height: widget.height ?? 60.00,
          width: widget.width ?? 60.00,
        ),
      ),
    );
  }
}
