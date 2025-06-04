// lib/features/discovery/presentation/widgets/profile_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/profile.dart';

class ProfileCard extends StatefulWidget {
  final Profile profile;
  final VoidCallback? onTap;
  final bool isTopCard;

  const ProfileCard({
    Key? key,
    required this.profile,
    this.onTap,
    this.isTopCard = false,
  }) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              _buildPhotoBackground(),
              
              // Photo indicators
              if (widget.profile.photoUrls.length > 1)
                _buildPhotoIndicators(),
              
              // Gradient overlay
              _buildGradientOverlay(),
              
              // Profile Info
              _buildProfileInfo(),
              
              // Verification badge
              if (widget.profile.isVerified)
                _buildVerificationBadge(),
              
              // Distance badge
              if (widget.profile.distance != null)
                _buildDistanceBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoBackground() {
    if (widget.profile.photoUrls.isEmpty) {
      return Container(
        color: AppColors.surfaceColor,
        child: const Center(
          child: Icon(
            Icons.person,
            size: 80,
            color: AppColors.textHint,
          ),
        ),
      );
    }

    return GestureDetector(
      onTapUp: (details) => _handlePhotoTap(details),
      child: CachedNetworkImage(
        imageUrl: widget.profile.photoUrls[_currentPhotoIndex],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: AppColors.surfaceColor,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surfaceColor,
          child: const Center(
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoIndicators() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        children: List.generate(
          widget.profile.photoUrls.length,
          (index) => Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(
                right: index < widget.profile.photoUrls.length - 1 ? 4 : 0,
              ),
              decoration: BoxDecoration(
                color: index == _currentPhotoIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name and Age
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.profile.name}, ${widget.profile.age}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.profile.isVerified) const SizedBox(width: 8),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Career and Campus
          Text(
            widget.profile.ageAndCareer,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 2),
          
          // Semester and Campus
          Text(
            widget.profile.semesterAndCampus,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Bio preview
          if (widget.profile.bio != null && widget.profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.profile.bio!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Interests preview
          if (widget.profile.interests.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInterestsPreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildInterestsPreview() {
    final displayInterests = widget.profile.interests.take(3).toList();
    
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: displayInterests.map((interest) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            interest,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVerificationBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary,
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
          Icons.verified,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildDistanceBadge() {
    return Positioned(
      top: 16,
      right: widget.profile.isVerified ? 56 : 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${widget.profile.distance!.toStringAsFixed(1)} km',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handlePhotoTap(TapUpDetails details) {
    if (widget.profile.photoUrls.length <= 1) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.localPosition.dx;
    
    setState(() {
      if (tapPosition < screenWidth / 2) {
        // Tap left side - previous photo
        _currentPhotoIndex = _currentPhotoIndex > 0 
            ? _currentPhotoIndex - 1 
            : widget.profile.photoUrls.length - 1;
      } else {
        // Tap right side - next photo
        _currentPhotoIndex = _currentPhotoIndex < widget.profile.photoUrls.length - 1 
            ? _currentPhotoIndex + 1 
            : 0;
      }
    });
  }
}