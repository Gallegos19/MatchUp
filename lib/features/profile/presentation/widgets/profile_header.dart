// lib/features/profile/presentation/widgets/profile_header.dart - UPDATED

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final dynamic user; // Can be User from auth or UserProfile
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    Key? key,
    required this.user,
    this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _buildProfileImage(),
                ),
              ),
              if (onEditPressed != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEditPressed,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getUserName(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (_getUserAge() != null) ...[
            const SizedBox(height: 4),
            Text(
              '${_getUserAge()} años',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
          if (_getUserCareer() != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getUserCareer()!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final photoUrls = _getPhotoUrls();
    
    if (photoUrls != null && photoUrls.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrls.first,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.white.withOpacity(0.2),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 40,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.white.withOpacity(0.2),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 40,
          ),
        ),
      );
    }
    
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  String _getUserName() {
    if (user is UserProfile) {
      final profile = user as UserProfile;
      return profile.displayName;
    } else {
      // Fallback for auth User
      return user.name ?? user.email ?? 'Usuario';
    }
  }

  int? _getUserAge() {
    if (user is UserProfile) {
      final profile = user as UserProfile;
      return profile.age;
    } else {
      // Fallback for auth User
      return user.age;
    }
  }

  String? _getUserCareer() {
    if (user is UserProfile) {
      final profile = user as UserProfile;
      return profile.career;
    } else {
      // Fallback for auth User
      return user.career;
    }
  }

  List<String>? _getPhotoUrls() {
    if (user is UserProfile) {
      final profile = user as UserProfile;
      return profile.photoUrls;
    } else {
      // Fallback for auth User
      return user.photoUrls;
    }
  }
}