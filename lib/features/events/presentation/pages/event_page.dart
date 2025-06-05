// lib/features/events/presentation/pages/events_page.dart - FIXED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matchup/features/events/presentation/widgets/event_filter_bottom_shet.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/event.dart';
import '../cubit/events_cubit.dart';
import '../widgets/event_card.dart';
import '../widgets/create_event_bottom_sheet.dart';
import '../widgets/edit_event_bottom_sheet.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _allEventsScrollController;
  late ScrollController _myEventsScrollController;
  String _cancelReason = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _allEventsScrollController = ScrollController();
    _myEventsScrollController = ScrollController();
    
    // Load initial data
    context.read<EventsCubit>().loadEvents();
    
    // Add scroll listener for pagination
    _allEventsScrollController.addListener(_onAllEventsScroll);
    
    // Listen to tab changes
    _tabController.addListener(() {
      if (_tabController.index == 1 && _tabController.indexIsChanging) {
        // Load my events when switching to tab
        context.read<EventsCubit>().loadMyEvents();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _allEventsScrollController.dispose();
    _myEventsScrollController.dispose();
    super.dispose();
  }

  void _onAllEventsScroll() {
    if (_allEventsScrollController.position.pixels ==
        _allEventsScrollController.position.maxScrollExtent) {
      context.read<EventsCubit>().loadMoreEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<EventsCubit, EventsState>(
          listener: (context, state) {
            if (state is EventsError) {
              _showErrorSnackBar(state.message);
            } else if (state is EventCreated) {
              _showSuccessSnackBar('Evento creado exitosamente');
              // Refresh both tabs
              context.read<EventsCubit>().refreshEvents();
            } else if (state is EventJoined) {
              _showSuccessSnackBar('Te has unido al evento');
            } else if (state is EventLeft) {
              _showSuccessSnackBar('Has salido del evento');
            } else if (state is EventCancelled) {
              _showSuccessSnackBar('Evento cancelado');
              // Refresh my events
              context.read<EventsCubit>().refreshMyEvents();
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildAppBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllEventsTab(state),
                      _buildMyEventsTab(state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Eventos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _showFiltersBottomSheet,
            icon: const Icon(
              Icons.tune,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: _refreshCurrentTab,
            icon: const Icon(
              Icons.refresh,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        tabs: const [
          Tab(
            text: 'Todos los eventos',
            icon: Icon(Icons.public, size: 20),
          ),
          Tab(
            text: 'Mis eventos',
            icon: Icon(Icons.person, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAllEventsTab(EventsState state) {
    if (state is EventsLoading && context.read<EventsCubit>().events.isEmpty) {
      return _buildLoadingState();
    }

    final events = context.read<EventsCubit>().events;

    if (events.isEmpty && state is! EventsLoading) {
      return _buildEmptyState(
        icon: Icons.event_busy,
        title: 'No hay eventos disponibles',
        subtitle: 'Sé el primero en crear un evento',
        actionText: 'Crear evento',
        onActionPressed: _showCreateEventBottomSheet,
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<EventsCubit>().refreshEvents(),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _allEventsScrollController,
        padding: const EdgeInsets.all(16),
        itemCount: events.length + (state is EventsLoading && state is! EventsLoaded ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == events.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final event = events[index];
          return EventCard(
            event: event,
            onTap: () => _showEventDetails(event),
            onJoin: () => _joinEvent(event.id),
            onLeave: () => _leaveEvent(event.id),
            showActions: event.isJoined, // Mostrar acciones si está unido
            onEdit: () => _editEvent(event),
            onCancel: () => _cancelEvent(event.id),
          );
        },
      ),
    );
  }

  Widget _buildMyEventsTab(EventsState state) {
    if (state is EventsLoading && context.read<EventsCubit>().myEvents.isEmpty) {
      return _buildLoadingState();
    }

    if (state is MyEventsLoaded) {
      final myEvents = state.myEvents;
      
      print('🔍 Mis eventos cargados: ${myEvents.length}'); // Debug
      for (var event in myEvents) {
        print('🔍 Evento: ${event.title} - isJoined: ${event.isJoined}'); // Debug
      }
      
      if (myEvents.isEmpty) {
        return _buildEmptyState(
          icon: Icons.event_available,
          title: 'No tienes eventos',
          subtitle: 'Crea o únete a eventos para verlos aquí',
          actionText: 'Explorar eventos',
          onActionPressed: () => _tabController.animateTo(0),
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<EventsCubit>().refreshMyEvents(),
        color: AppColors.primary,
        child: ListView.builder(
          controller: _myEventsScrollController,
          padding: const EdgeInsets.all(16),
          itemCount: myEvents.length,
          itemBuilder: (context, index) {
            final event = myEvents[index];
            print('🔍 Renderizando evento: ${event.title} - isJoined: ${event.isJoined}'); // Debug
            
            return EventCard(
              event: event,
              onTap: () => _showEventDetails(event),
              onJoin: () => _joinEvent(event.id),
              onLeave: () => _leaveEvent(event.id),
              showActions: true, // Siempre mostrar acciones en "Mis eventos"
              onEdit: () => _editEvent(event),
              onCancel: () => _cancelEvent(event.id),
            );
          },
        ),
      );
    }

    // Default state for my events tab
    return _buildEmptyState(
      icon: Icons.event_available,
      title: 'Mis eventos',
      subtitle: 'Toca para cargar tus eventos',
      actionText: 'Cargar eventos',
      onActionPressed: () => context.read<EventsCubit>().loadMyEvents(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Cargando eventos...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onActionPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.add),
              label: Text(actionText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showCreateEventBottomSheet,
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Crear evento',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
    );
  }

  // Action methods - FIXED: Pass EventsCubit as context
  void _showFiltersBottomSheet() {
    final eventsCubit = context.read<EventsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: eventsCubit,
        child: const EventFilterBottomSheet(),
      ),
    );
  }

  void _showCreateEventBottomSheet() {
    final eventsCubit = context.read<EventsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: eventsCubit,
        child: const CreateEventBottomSheet(),
      ),
    );
  }

  Future<void> _refreshCurrentTab() async {
    if (_tabController.index == 0) {
      context.read<EventsCubit>().refreshEvents();
    } else {
      context.read<EventsCubit>().refreshMyEvents();
    }
  }

  void _joinEvent(String eventId) {
    context.read<EventsCubit>().joinEventById(eventId);
  }

  void _leaveEvent(String eventId) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Salir del evento'),
        content: const Text('¿Estás seguro que quieres salir de este evento?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<EventsCubit>().leaveEventById(eventId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Salir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _buildEventDetailsBottomSheet(event),
    );
  }

  void _editEvent(Event event) {
    final eventsCubit = context.read<EventsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: eventsCubit,
        child: EditEventBottomSheet(event: event),
      ),
    );
  }

  void _cancelEvent(String eventId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar evento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro que quieres cancelar este evento?'),
            const SizedBox(height: 16),
            const Text(
              'Motivo de cancelación:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Escribe el motivo...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
              onChanged: (value) {
                _cancelReason = value;
              },
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (_cancelReason.isNotEmpty) {
                context.read<EventsCubit>().cancelEventById(
                  eventId: eventId,
                  reason: _cancelReason,
                );
              } else {
                _showErrorSnackBar('Debes proporcionar un motivo para cancelar');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancelar evento',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsBottomSheet(Event event) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getEventTypeColor(event.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getEventTypeIcon(event.type),
                    color: _getEventTypeColor(event.type),
                    size: 24,
                  ),
                ),
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
                      ),
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
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Event details
                  _buildDetailRow(Icons.calendar_today, 'Fecha y hora', 
                    '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.location_on, 'Ubicación', 
                    '${event.location}, ${event.campus}'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.people, 'Participantes', 
                    '${event.currentParticipants}/${event.maxParticipants}'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.public, 'Visibilidad', 
                    event.isPublic ? 'Público' : 'Privado'),
                  
                  if (event.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Etiquetas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: event.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
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
                    ),
                  ],
                  
                  if (event.requirements.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Requisitos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...event.requirements.map((req) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, 
                              size: 16, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text(
                              _getRequirementText(req),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.borderMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: event.isJoined 
                        ? () {
                            Navigator.of(context).pop();
                            _leaveEvent(event.id);
                          }
                        : event.isFull || event.hasEnded
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            _joinEvent(event.id);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: event.isJoined 
                          ? AppColors.error 
                          : (event.isFull || event.hasEnded)
                          ? AppColors.textHint
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          event.isJoined 
                              ? Icons.exit_to_app 
                              : event.isFull || event.hasEnded
                              ? Icons.block
                              : Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.isJoined 
                              ? 'Salir del evento' 
                              : event.hasEnded 
                              ? 'Finalizado'
                              : event.isFull
                              ? 'Evento lleno'
                              : 'Unirse al evento',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textHint),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year $hour:$minute';
  }

  String _getRequirementText(EventRequirement req) {
    switch (req.type) {
      case 'semester':
        return 'Semestre mínimo: ${req.value}';
      case 'gpa':
        return 'Promedio mínimo: ${req.value}';
      default:
        return '${req.type}: ${req.value}';
    }
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.academic:
        return AppColors.info;
      case EventType.sports:
        return AppColors.warning;
      case EventType.cultural:
        return AppColors.secondary;
      case EventType.networking:
        return AppColors.success;
      case EventType.social:
        return AppColors.primary;
    }
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.academic:
        return Icons.school;
      case EventType.sports:
        return Icons.sports_soccer;
      case EventType.cultural:
        return Icons.palette;
      case EventType.networking:
        return Icons.people;
      case EventType.social:
        return Icons.celebration;
    }
  }
}