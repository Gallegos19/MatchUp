// lib/features/profile/presentation/widgets/profile_stats.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileStats extends StatelessWidget {
  final int matchesCount;
  final int likesCount;
  final int superLikesCount;
  final int viewsCount;

  const ProfileStats({
    Key? key,
    required this.matchesCount,
    required this.likesCount,
    required this.superLikesCount,
    required this.viewsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('Matches', matchesCount, AppColors.secondary),
          _buildDivider(),
          _buildStatItem('Likes', likesCount, AppColors.like),
          _buildDivider(),
          _buildStatItem('Super Likes', superLikesCount, AppColors.superLike),
          _buildDivider(),
          _buildStatItem('Vistas', viewsCount, AppColors.info),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.borderLight,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}