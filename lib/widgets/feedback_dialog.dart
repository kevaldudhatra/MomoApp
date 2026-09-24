import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

class FeedbackDialog extends StatefulWidget {
  final FutureOr<bool> Function(double rating, String review)? onSubmit;

  const FeedbackDialog({super.key, this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    FutureOr<bool> Function(double rating, String review)? onSubmit,
  }) {
    return showDialog(
      context: context,
      barrierColor: dialogBarrierColor,
      barrierDismissible: true,
      builder: (context) => FeedbackDialog(onSubmit: onSubmit),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  double _selectedRating = 4.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (widget.onSubmit != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final success = await widget.onSubmit!(
          _selectedRating,
          _reviewController.text.trim(),
        );
        if (mounted) {
          if (success) {
            setState(() {
              _isSubmitted = true;
            });
          }
        }
      } catch (e) {
        print(e.toString());
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      elevation: 0,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSubmitted ? _buildSuccessView() : _buildRatingView(),
        ),
      ),
    );
  }

  // --- 1. RATING & REVIEW FORM VIEW ---
  Widget _buildRatingView() {
    return Column(
      key: const ValueKey("RatingView"),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Title & Close Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Rate your experience",
              style: TextStyle(
                fontFamily: natoBold,
                fontSize: 18,
                color: charcoalGray,
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).pop(),
              child: Image.asset(
                AppImages().closeIcon,
                width: 20,
                height: 20,
                color: charcoalGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 5 Stars Row
        Center(
          child: RatingBar.builder(
            initialRating: 4,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 5),
            itemBuilder: (context, _) => Image.asset(
              AppImages().starIcon,
              width: 20,
              height: 20,
              color: const Color(0xFF1EA877),
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _selectedRating = rating;
              });
            },
          ),
        ),
        const SizedBox(height: 24),

        // Subtitle
        const Text(
          "Tell us more about your experience",
          style: TextStyle(
            fontFamily: natoMedium,
            fontSize: 14,
            color: charcoalGray,
          ),
        ),
        const SizedBox(height: 10),

        // Review Text Area
        Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: TextField(
            controller: _reviewController,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: natoRegular,
              fontSize: 14,
              color: charcoalGray,
            ),
            cursorColor: charcoalGray,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: "Write your review here...",
              hintStyle: TextStyle(
                fontFamily: natoRegular,
                fontSize: 14,
                color: textDisabled,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Submit Button
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading ? null : _handleSubmit,
          child: Container(
            height: 48,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: white,
                      strokeWidth: 2.2,
                    ),
                  )
                : const Text(
                    "Submit Review",
                    style: TextStyle(
                      fontFamily: natoMedium,
                      fontSize: 15,
                      color: white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // --- 2. FEEDBACK RECEIVED SUCCESS VIEW ---
  Widget _buildSuccessView() {
    return SizedBox(
      key: const ValueKey("SuccessView"),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Close Button
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).pop(),
              child: Image.asset(
                AppImages().closeIcon,
                width: 20,
                height: 20,
                color: charcoalGray,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Done Checkmark Icon
          Image.asset(AppImages().doneIcon, width: 72, height: 72),
          const SizedBox(height: 20),

          // Feedback Received Text
          const Text(
            "Feedback Received",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: natoMedium,
              fontSize: 16,
              color: charcoalGray,
            ),
          ),
          const SizedBox(height: 6),

          // Thank You! Text
          const Text(
            "Thank You!",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: natoBold, fontSize: 20, color: black),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
