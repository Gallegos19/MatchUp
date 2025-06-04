// lib/core/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final IconData? icon;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 50,
    this.icon,
    this.borderRadius = 25,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled && !isLoading ? onPressed : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: width,
          height: height,
          decoration: _getDecoration(),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _getTextColor(),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _getTextColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: isEnabled
              ? AppColors.primaryGradient
              : const LinearGradient(
                  colors: [Color(0xFFB2BEC3), Color(0xFFB2BEC3)],
                ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        );

      case ButtonType.secondary:
        return BoxDecoration(
          gradient: isEnabled
              ? AppColors.secondaryGradient
              : const LinearGradient(
                  colors: [Color(0xFFB2BEC3), Color(0xFFB2BEC3)],
                ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        );

      case ButtonType.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isEnabled ? AppColors.primary : AppColors.textHint,
            width: 2,
          ),
        );

      case ButtonType.text:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
        );
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return AppColors.textWhite;

      case ButtonType.outline:
        return isEnabled ? AppColors.primary : AppColors.textHint;

      case ButtonType.text:
        return isEnabled ? AppColors.primary : AppColors.textHint;
    }
  }
}
