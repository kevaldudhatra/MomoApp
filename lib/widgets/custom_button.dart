import 'package:flutter/material.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';

class CustomButton extends StatefulWidget {
  final Function()? onTap;
  final double? height;
  final double? width;
  final String? label;
  final double? fontSize;
  final String? fontFamily;
  final bool isEnabled;

  const CustomButton({
    super.key,
    this.onTap,
    this.height,
    this.width,
    this.label,
    this.fontSize,
    this.fontFamily,
    this.isEnabled = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (widget.onTap ?? () {}),
      style: ElevatedButton.styleFrom(
        elevation: widget.isEnabled ? 1 : 0,
        backgroundColor: widget.isEnabled ? orange : white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: widget.isEnabled
              ? BorderSide.none
              : BorderSide(color: lightGray, width: 0.5),
        ),
      ),
      child: Container(
        height: widget.height ?? 50,
        alignment: Alignment.center,
        width: widget.width ?? MediaQuery.of(context).size.width / 2,
        child: Text(
          widget.label ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: widget.fontSize ?? 16,
            fontFamily: widget.fontFamily ?? natoMedium,
            color: widget.isEnabled ? white : black,
          ),
        ),
      ),
    );
  }
}
