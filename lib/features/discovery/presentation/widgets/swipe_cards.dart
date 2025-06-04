
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/discovery_repository.dart';
import 'profile_card.dart';

class SwipeCards extends StatefulWidget {
  final List<Profile> profiles;
  final Function(String profileId, SwipeAction action) onSwipe;
  final VoidCallback? onProfileTap;
  final VoidCallback? onEmptyStack;

  const SwipeCards({
    Key? key,
    required this.profiles,
    required this.onSwipe,
    this.onProfileTap,
    this.onEmptyStack,
  }) : super(key: key);

  @override
  State<SwipeCards> createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<SwipeCards>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  
  // Stack management
  final int _maxCards = 3; // Show maximum 3 cards in stack
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_animationController);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController);

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        setState(() {
          _dragOffset = Offset.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profiles.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: 600,
      child: Stack(
        children: _buildCardStack(),
      ),
    );
  }

  List<Widget> _buildCardStack() {
    final visibleCards = widget.profiles.take(_maxCards).toList();
    final cards = <Widget>[];

    for (int i = visibleCards.length - 1; i >= 0; i--) {
      final profile = visibleCards[i];
      final isTopCard = i == 0;
      
      if (isTopCard) {
        // Top card - draggable
        cards.add(_buildTopCard(profile));
      } else {
        // Background cards - scaled and offset
        cards.add(_buildBackgroundCard(profile, i));
      }
    }

    return cards;
  }

  Widget _buildTopCard(Profile profile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rotation = _isDragging 
        ? _dragOffset.dx / screenWidth * 0.3 
        : _rotationAnimation.value;
    
    final offset = _isDragging 
        ? _dragOffset 
        : _offsetAnimation.value;

    final scale = _isDragging 
        ? 1.0 
        : 1.0 - (_scaleAnimation.value * 0.1);

    return Positioned.fill(
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Stack(
                children: [
                  ProfileCard(
                    profile: profile,
                    isTopCard: true,
                    onTap: widget.onProfileTap,
                  ),
                  // Swipe indicators
                  if (_isDragging) _buildSwipeIndicators(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundCard(Profile profile, int index) {
    final scale = 1.0 - (index * 0.05);
    final yOffset = index * 8.0;

    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(0, yOffset),
        child: Transform.scale(
          scale: scale,
          child: ProfileCard(
            profile: profile,
            isTopCard: false,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeProgress = (_dragOffset.dx.abs() / (screenWidth * 0.3)).clamp(0.0, 1.0);
    final isLikeDirection = _dragOffset.dx > 0;

    return Positioned.fill(
      child: Stack(
        children: [
          // Like indicator (right swipe)
          if (isLikeDirection)
            Positioned(
              top: 100,
              left: 40,
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.like,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LIKE',
                    style: TextStyle(
                      color: AppColors.like,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // Dislike indicator (left swipe)
          if (!isLikeDirection)
            Positioned(
              top: 100,
              right: 40,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.dislike,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'NOPE',
                    style: TextStyle(
                      color: AppColors.dislike,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay más perfiles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajusta tus filtros o vuelve más tarde',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: widget.onEmptyStack,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeThreshold = screenWidth * 0.25;
    
    setState(() {
      _isDragging = false;
    });

    if (_dragOffset.dx.abs() > swipeThreshold) {
      // Complete the swipe
      _completeSwipe();
    } else {
      // Return to center
      _returnToCenter();
    }
  }

  void _completeSwipe() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLike = _dragOffset.dx > 0;
    final action = isLike ? SwipeAction.like : SwipeAction.dislike;
    
    // Set animation end values
    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(isLike ? screenWidth : -screenWidth, _dragOffset.dy),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx / screenWidth * 0.3,
      end: isLike ? 0.5 : -0.5,
    ).animate(_animationController);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(_animationController);

    // Start animation
    _animationController.forward().then((_) {
      // Call swipe callback
      if (widget.profiles.isNotEmpty) {
        widget.onSwipe(widget.profiles.first.id, action);
      }
    });
  }

  void _returnToCenter() {
    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx / MediaQuery.of(context).size.width * 0.3,
      end: 0.0,
    ).animate(_animationController);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  // Public methods for programmatic swiping
  void swipeLeft() {
    if (widget.profiles.isEmpty) return;
    
    setState(() {
      _dragOffset = Offset(-MediaQuery.of(context).size.width * 0.3, 0);
    });
    _completeSwipe();
  }

  void swipeRight() {
    if (widget.profiles.isEmpty) return;
    
    setState(() {
      _dragOffset = Offset(MediaQuery.of(context).size.width * 0.3, 0);
    });
    _completeSwipe();
  }
}