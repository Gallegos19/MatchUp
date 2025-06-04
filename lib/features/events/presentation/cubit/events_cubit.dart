import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/join_event.dart';

// States
abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Event> events;
  final bool hasReachedMax;

  const EventsLoaded({
    required this.events,
    this.hasReachedMax = false,
  });

  EventsLoaded copyWith({
    List<Event>? events,
    bool? hasReachedMax,
  }) {
    return EventsLoaded(
      events: events ?? this.events,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [events, hasReachedMax];
}

class EventsError extends EventsState {
  final String message;

  const EventsError({required this.message});

  @override
  List<Object> get props => [message];
}

class EventCreated extends EventsState {
  final Event event;

  const EventCreated({required this.event});

  @override
  List<Object> get props => [event];
}

class EventJoined extends EventsState {
  final String eventId;

  const EventJoined({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

// Cubit
class EventsCubit extends Cubit<EventsState> {
  final GetEvents getEvents;
  final CreateEvent createEvent;
  final JoinEvent joinEvent;

  EventsCubit({
    required this.getEvents,
    required this.createEvent,
    required this.joinEvent,
  }) : super(EventsInitial());

  // Current state management
  int _currentPage = 1;
  final List<Event> _events = [];
  String? _currentCampus;
  EventType? _currentType;
  List<String>? _currentTags;

  // Getters
  bool get isLoading => state is EventsLoading;
  List<Event> get events => _events;

  // Load initial events
  Future<void> loadEvents({
    String? campus,
    EventType? type,
    List<String>? tags,
  }) async {
    emit(EventsLoading());
    
    _currentPage = 1;
    _currentCampus = campus;
    _currentType = type;
    _currentTags = tags;
    _events.clear();

    final result = await getEvents(GetEventsParams(
      page: _currentPage,
      limit: 20,
      campus: campus,
      type: type,
      tags: tags,
    ));

    result.fold(
      (failure) => emit(EventsError(message: _getFailureMessage(failure))),
      (events) {
        _events.addAll(events);
        emit(EventsLoaded(
          events: List.from(_events),
          hasReachedMax: events.length < 20,
        ));
      },
    );
  }

  // Load more events (pagination)
  Future<void> loadMoreEvents() async {
    if (state is! EventsLoaded) return;
    
    final currentState = state as EventsLoaded;
    if (currentState.hasReachedMax) return;

    _currentPage++;

    final result = await getEvents(GetEventsParams(
      page: _currentPage,
      limit: 20,
      campus: _currentCampus,
      type: _currentType,
      tags: _currentTags,
    ));

    result.fold(
      (failure) => emit(EventsError(message: _getFailureMessage(failure))),
      (newEvents) {
        _events.addAll(newEvents);
        emit(currentState.copyWith(
          events: List.from(_events),
          hasReachedMax: newEvents.length < 20,
        ));
      },
    );
  }

  // Create new event
  Future<void> createNewEvent({
    required String title,
    required String description,
    required EventType type,
    required String location,
    required String campus,
    required DateTime startDate,
    required DateTime endDate,
    required int maxParticipants,
    required bool isPublic,
    required List<String> tags,
    required List<EventRequirement> requirements,
  }) async {
    emit(EventsLoading());

    final result = await createEvent(CreateEventParams(
      title: title,
      description: description,
      type: type,
      location: location,
      campus: campus,
      startDate: startDate,
      endDate: endDate,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
      tags: tags,
      requirements: requirements,
    ));

    result.fold(
      (failure) => emit(EventsError(message: _getFailureMessage(failure))),
      (event) {
        emit(EventCreated(event: event));
        // Refresh events list
        loadEvents(
          campus: _currentCampus,
          type: _currentType,
          tags: _currentTags,
        );
      },
    );
  }

  // Join event
  Future<void> joinEventById(String eventId) async {
    final result = await joinEvent(JoinEventParams(eventId: eventId));

    result.fold(
      (failure) => emit(EventsError(message: _getFailureMessage(failure))),
      (_) {
        emit(EventJoined(eventId: eventId));
        // Update local events list
        _updateEventJoinStatus(eventId, true);
        if (state is EventsLoaded) {
          final currentState = state as EventsLoaded;
          emit(currentState.copyWith(events: List.from(_events)));
        }
      },
    );
  }

  // Apply filters
  Future<void> applyFilters({
    String? campus,
    EventType? type,
    List<String>? tags,
  }) async {
    await loadEvents(campus: campus, type: type, tags: tags);
  }

  // Clear filters
  Future<void> clearFilters() async {
    await loadEvents();
  }

  // Refresh events
  Future<void> refreshEvents() async {
    await loadEvents(
      campus: _currentCampus,
      type: _currentType,
      tags: _currentTags,
    );
  }

  // Helper method to update event join status locally
  void _updateEventJoinStatus(String eventId, bool isJoined) {
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      final updatedEvent = Event(
        id: _events[index].id,
        title: _events[index].title,
        description: _events[index].description,
        type: _events[index].type,
        location: _events[index].location,
        campus: _events[index].campus,
        startDate: _events[index].startDate,
        endDate: _events[index].endDate,
        maxParticipants: _events[index].maxParticipants,
        currentParticipants: isJoined 
            ? _events[index].currentParticipants + 1
            : _events[index].currentParticipants - 1,
        isPublic: _events[index].isPublic,
        authorId: _events[index].authorId,
        authorName: _events[index].authorName,
        tags: _events[index].tags,
        requirements: _events[index].requirements,
        isJoined: isJoined,
        createdAt: _events[index].createdAt,
      );
      _events[index] = updatedEvent;
    }
  }

  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Error de conexión. Verifica tu internet';
      case ServerFailure:
        return 'Error del servidor. Intenta más tarde';
      case UnauthorizedFailure:
        return 'Sesión expirada. Inicia sesión nuevamente';
      case ValidationFailure:
        return failure.message;
      default:
        return failure.message.isNotEmpty 
            ? failure.message 
            : 'Ha ocurrido un error inesperado';
    }
  }
}