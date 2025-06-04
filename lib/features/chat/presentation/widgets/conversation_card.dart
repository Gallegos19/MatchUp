// lib/features/chat/presentation/widgets/conversation_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/conversation.dart';

class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;

  const ConversationCard({
    Key? key,
    required this.conversation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: _buildConversationInfo(),
            ),
            const SizedBox(width: 8),
            _buildTrailingInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: conversation.otherUserPhoto != null
                ? CachedNetworkImage(
                    imageUrl: conversation.otherUserPhoto!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceColor,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textHint,
                        size: 28,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceColor,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textHint,
                        size: 28,
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.surfaceColor,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textHint,
                      size: 28,
                    ),
                  ),
          ),
        ),
        if (conversation.isActive)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConversationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                conversation.otherUserName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: conversation.unreadCount > 0 
                      ? FontWeight.bold 
                      : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        if (conversation.lastMessage != null)
          Text(
            conversation.lastMessage!,
            style: TextStyle(
              fontSize: 14,
              color: conversation.unreadCount > 0 
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: conversation.unreadCount > 0 
                  ? FontWeight.w500 
                  : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        else
          Text(
            '¡Es un match! Saluda a ${conversation.otherUserName}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildTrailingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (conversation.lastMessageTime != null)
          Text(
            _formatMessageTime(conversation.lastMessageTime!),
            style: TextStyle(
              fontSize: 12,
              color: conversation.unreadCount > 0 
                  ? AppColors.primary
                  : AppColors.textHint,
              fontWeight: conversation.unreadCount > 0 
                  ? FontWeight.w600 
                  : FontWeight.normal,
            ),
          ),
        const SizedBox(height: 4),
        Icon(
          Icons.chevron_right,
          color: AppColors.textHint,
          size: 20,
        ),
      ],
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}