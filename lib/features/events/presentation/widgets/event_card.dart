// lib/features/events/presentation/widgets/event_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  const EventCard({
    Key? key,
    required this.event,
    this.onTap,
    this.onJoin,
    this.onLeave,
    this.showActions = false,
    this.onEdit,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildEventTypeIcon(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Por ${event.authorName}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(event.startDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.currentParticipants}/${event.maxParticipants} participantes',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.school,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.campus,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  
                  if (event.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildTags(),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildParticipantsBar(),
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(),
                    ],
                  ),
                ],
              ),
            ),
            // Actions menu - Mostrar si está unido O si tiene permisos de edición
            if (showActions || event.isJoined)
              Positioned(
                top: 8,
                right: 8,
                child: _buildActionsMenu(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeIcon() {
    IconData icon;
    Color color;
    
    switch (event.type) {
      case EventType.academic:
        icon = Icons.school;
        color = AppColors.info;
        break;
      case EventType.sports:
        icon = Icons.sports_soccer;
        color = AppColors.warning;
        break;
      case EventType.cultural:
        icon = Icons.palette;
        color = AppColors.secondary;
        break;
      case EventType.networking:
        icon = Icons.people;
        color = AppColors.success;
        break;
      default:
        icon = Icons.celebration;
        color = AppColors.primary;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (event.hasEnded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.textHint.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Finalizado',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (event.hasStarted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'En curso',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.warning,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (event.isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Lleno',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.error,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Abierto',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.success,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: event.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParticipantsBar() {
    final progress = event.maxParticipants > 0 
        ? event.currentParticipants / event.maxParticipants 
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: _getProgressColor(progress),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).round()}% de ocupación',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (event.isJoined) {
      return Row(
        children: [
          // Botón de "Unido" (indicador)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check, size: 16, color: AppColors.success),
                  SizedBox(width: 4),
                  Text(
                    'Unido',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón de "Salir"
          InkWell(
            onTap: onJoin, // Esta función manejará salir del evento
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.exit_to_app, size: 16, color: AppColors.error),
                  SizedBox(width: 4),
                  Text(
                    'Salir',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (event.isFull || event.hasEnded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textHint.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          event.hasEnded ? 'Finalizado' : 'Lleno',
          style: const TextStyle(
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onJoin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.add, size: 16),
          SizedBox(width: 4),
          Text(
            'Unirse',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    // Debug
    print('🔍 EventCard - Evento: ${event.title}');
    print('🔍 EventCard - isJoined: ${event.isJoined}');
    print('🔍 EventCard - showActions: $showActions');
    
    // Determinar qué opciones mostrar
    final canEdit = showActions; // Si showActions está en true, puede editar (es el creador)
    final canLeave = event.isJoined || showActions; // Si está unido O si es "Mis eventos" (showActions = true)
    final canCancel = !event.hasStarted && showActions; // Solo creador y evento no empezado

    print('🔍 EventCard - canEdit: $canEdit, canLeave: $canLeave, canCancel: $canCancel');

    // Si no hay opciones disponibles, no mostrar el menú
    if (!canEdit && !canLeave && !canCancel) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        print('🔍 Acción seleccionada: $value para evento ${event.title}');
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'cancel':
            onCancel?.call();
            break;
          case 'leave':
            if (onLeave != null) {
              onLeave!();
            } else if (onJoin != null) {
              onJoin!();
            }
            break;
        }
      },
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.more_vert,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> items = [];

        // Opción de editar (solo si es el creador/organizador)
        if (canEdit) {
          items.add(
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text('Editar evento'),
                ],
              ),
            ),
          );
        }

        // Opción de salir del evento (si está unido O si está en "Mis eventos")
        if (canLeave) {
          items.add(
            const PopupMenuItem<String>(
              value: 'leave',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, size: 20, color: AppColors.warning),
                  SizedBox(width: 12),
                  Text('Salir del evento'),
                ],
              ),
            ),
          );
        }

        // Separador si hay tanto opciones de edición como de salir
        if (canEdit && canLeave && canCancel) {
          items.add(const PopupMenuDivider());
        }

        // Opción de cancelar (solo si no ha empezado y es el creador)
        if (canCancel) {
          items.add(
            const PopupMenuItem<String>(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel, size: 20, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Cancelar evento'),
                ],
              ),
            ),
          );
        }

        return items;
      },
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) return AppColors.success;
    if (progress < 0.8) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Hoy ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Mañana ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}