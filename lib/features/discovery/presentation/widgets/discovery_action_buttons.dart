// lib/features/discovery/presentation/widgets/discovery_action_buttons.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DiscoveryActionButtons extends StatelessWidget {
  final VoidCallback? onRewind;
  final VoidCallback? onDislike;
  final VoidCallback? onSuperLike;
  final VoidCallback? onLike;
  final VoidCallback? onBoost;
  final bool hasRewind;

  const DiscoveryActionButtons({
    Key? key,
    this.onRewind,
    this.onDislike,
    this.onSuperLike,
    this.onLike,
    this.onBoost,
    this.hasRewind = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Rewind button
          if (hasRewind)
            _ActionButton(
              onPressed: onRewind,
              icon: Icons.replay,
              color: AppColors.warning,
              size: ActionButtonSize.small,
              isEnabled: onRewind != null,
            ),
          
          // Dislike button
          _ActionButton(
            onPressed: onDislike,
            icon: Icons.close,
            color: AppColors.dislike,
            size: ActionButtonSize.large,
            isEnabled: onDislike != null,
          ),
          
          // Super Like button
          _ActionButton(
            onPressed: onSuperLike,
            icon: Icons.star,
            color: AppColors.superLike,
            size: ActionButtonSize.medium,
            isEnabled: onSuperLike != null,
          ),
          
          // Like button
          _ActionButton(
            onPressed: onLike,
            icon: Icons.favorite,
            color: AppColors.like,
            size: ActionButtonSize.large,
            isEnabled: onLike != null,
          ),
          
          // Boost button
          _ActionButton(
            onPressed: onBoost,
            icon: Icons.flash_on,
            color: AppColors.primary,
            size: ActionButtonSize.small,
            isEnabled: onBoost != null,
          ),
        ],
      ),
    );
  }
}

enum ActionButtonSize { small, medium, large }

class _ActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;
  final ActionButtonSize size;
  final bool isEnabled;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.size,
    this.isEnabled = true,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = _getButtonSize();
    final iconSize = _getIconSize();

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        if (widget.isEnabled && widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: widget.isEnabled 
                    ? Colors.white 
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.isEnabled 
                        ? widget.color.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: widget.isEnabled 
                      ? widget.color.withOpacity(0.2)
                      : Colors.grey.shade400,
                  width: 1,
                ),
              ),
              child: Icon(
                widget.icon,
                size: iconSize,
                color: widget.isEnabled 
                    ? widget.color
                    : Colors.grey.shade500,
              ),
            ),
          );
        },
      ),
    );
  }

  double _getButtonSize() {
    switch (widget.size) {
      case ActionButtonSize.small:
        return 48;
      case ActionButtonSize.medium:
        return 56;
      case ActionButtonSize.large:
        return 64;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ActionButtonSize.small:
        return 24;
      case ActionButtonSize.medium:
        return 28;
      case ActionButtonSize.large:
        return 32;
    }
  }
}