import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';

class CustomTextField extends StatefulWidget {
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final bool? obscureText;
  final TextAlign? textAlign;
  final double? contentPaddingTop;
  final double? contentPaddingBottom;
  final double? contentPaddingLeft;
  final double? contentPaddingRight;
  final double? fontSize;
  final String? fontFamily;
  final int? maxLength;
  final Color? fontColor;
  final TextEditingController? textEditingController;
  final bool? readOnly;
  final bool? enabled;
  final int? maxLine;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? fillColor;

  const CustomTextField({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.labelText,
    this.hintText,
    this.textInputAction,
    this.textEditingController,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText,
    this.textAlign,
    this.contentPaddingTop,
    this.contentPaddingBottom,
    this.contentPaddingLeft,
    this.contentPaddingRight,
    this.fontSize,
    this.fontFamily,
    this.fontColor,
    this.maxLength,
    this.readOnly,
    this.enabled,
    this.maxLine,
    this.suffixIcon,
    this.prefixIcon,
    this.fillColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.labelText != null
            ? Text(
                widget.labelText!,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: black,
                  fontSize: 14,
                  fontFamily: natoMedium,
                ),
              )
            : Container(),
        SizedBox(height: widget.labelText != null ? 5.0 : 0.0),
        TextField(
          enabled: widget.enabled ?? true,
          maxLines: widget.maxLine,
          controller:
              widget.textEditingController ?? TextEditingController(text: ""),
          autocorrect: true,
          readOnly: widget.readOnly ?? false,
          onChanged: widget.onChanged ?? (values) {},
          onSubmitted: widget.onSubmitted ?? (values) {},
          maxLength: widget.maxLength,
          textAlign: widget.textAlign ?? TextAlign.start,
          obscureText: widget.obscureText ?? false,
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          inputFormatters: widget.inputFormatters ?? [],
          style: TextStyle(
            color: widget.fontColor ?? black,
            fontSize: widget.fontSize ?? 16.0,
            fontFamily: widget.fontFamily ?? natoRegular,
          ),
          cursorColor: black,
          cursorHeight: 18,
          decoration: InputDecoration(
            counterText: "",
            suffixIcon: widget.suffixIcon,
            prefixIcon: widget.prefixIcon,
            contentPadding: EdgeInsets.only(
              bottom: widget.contentPaddingBottom ?? 10.0,
              top: widget.contentPaddingTop ?? 10.0,
              left: widget.contentPaddingLeft ?? 15.0,
              right: widget.contentPaddingRight ?? 15.0,
            ),
            filled: true,
            hintText: widget.hintText ?? "",
            hintStyle: TextStyle(
              color: lightGray,
              fontFamily: natoRegular,
              fontSize: 16.0,
            ),
            fillColor: widget.fillColor ?? white,
            disabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: lightGray),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: lightGray),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: lightGray),
            ),
          ),
        ),
      ],
    );
  }
}
