// lib/features/events/presentation/pages/events_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/event.dart';
import '../cubit/events_cubit.dart';
import '../widgets/event_card.dart';
import '../widgets/event_filter_bottom_shet.dart';
import '../widgets/create_event_bottom_sheet.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<EventsCubit>().loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            } else if (state is EventJoined) {
              _showSuccessSnackBar('Te has unido al evento');
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
            onPressed: _refreshEvents,
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
          Tab(text: 'Todos los eventos'),
          Tab(text: 'Mis eventos'),
        ],
      ),
    );
  }

  Widget _buildAllEventsTab(EventsState state) {
    if (state is EventsLoading && context.read<EventsCubit>().events.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final events = context.read<EventsCubit>().events;

    if (events.isEmpty && state is! EventsLoading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshEvents,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length + (state is EventsLoading ? 1 : 0),
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
          );
        },
      ),
    );
  }

  Widget _buildMyEventsTab(EventsState state) {
    // TODO: Implement get my events functionality
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16),
          Text(
            'Mis eventos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Próximamente: Gestión de tus eventos',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay eventos disponibles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sé el primero en crear un evento',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateEventBottomSheet,
            icon: const Icon(Icons.add),
            label: const Text('Crear evento'),
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

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showCreateEventBottomSheet,
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  // Action methods
  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EventFilterBottomSheet(),
    );
  }

  void _showCreateEventBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateEventBottomSheet(),
    );
  }

  Future<void> _refreshEvents() async {
    context.read<EventsCubit>().refreshEvents();
  }

  void _joinEvent(String eventId) {
    context.read<EventsCubit>().joinEventById(eventId);
  }

  void _showEventDetails(Event event) {
    // TODO: Navigate to event details page
    _showFeatureNotAvailable('Detalles del evento');
  }

  void _showFeatureNotAvailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
}