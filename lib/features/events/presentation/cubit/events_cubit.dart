// lib/features/events/presentation/cubit/events_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:matchup/core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/join_event.dart';
import '../../domain/usecases/get_my_events.dart';
import '../../domain/usecases/get_event_by_id.dart';
import '../../domain/usecases/update_event.dart';
import '../../domain/usecases/cancel_event.dart';
import '../../domain/usecases/leave_event.dart';

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

class MyEventsLoaded extends EventsState {
  final List<Event> myEvents;

  const MyEventsLoaded({required this.myEvents});

  @override
  List<Object> get props => [myEvents];
}

class EventDetailsLoaded extends EventsState {
  final Event event;

  const EventDetailsLoaded({required this.event});

  @override
  List<Object> get props => [event];
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

class EventUpdated extends EventsState {
  final Event event;

  const EventUpdated({required this.event});

  @override
  List<Object> get props => [event];
}

class EventJoined extends EventsState {
  final String eventId;

  const EventJoined({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

class EventLeft extends EventsState {
  final String eventId;

  const EventLeft({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

class EventCancelled extends EventsState {
  final String eventId;

  const EventCancelled({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

// Cubit
class EventsCubit extends Cubit<EventsState> {
  final GetEvents getEvents;
  final CreateEvent createEvent;
  final JoinEvent joinEvent;
  final GetMyEvents getMyEvents;
  final GetEventById getEventById;
  final UpdateEvent updateEvent;
  final CancelEvent cancelEvent;
  final LeaveEvent leaveEvent;

  EventsCubit({
    required this.getEvents,
    required this.createEvent,
    required this.joinEvent,
    required this.getMyEvents,
    required this.getEventById,
    required this.updateEvent,
    required this.cancelEvent,
    required this.leaveEvent,
  }) : super(EventsInitial());

  // Current state management
  int _currentPage = 1;
  final List<Event> _events = [];
  final List<Event> _myEvents = [];
  String? _currentCampus;
  EventType? _currentType;
  List<String>? _currentTags;

  // Getters
  bool get isLoading => state is EventsLoading;
  List<Event> get events => _events;
  List<Event> get myEvents => _myEvents;

  // Load initial events
  Future<void> loadEvents({
    String? campus,
    EventType? type,
    List<String>? tags,
    bool refresh = false,
  }) async {
    if (!refresh && _events.isNotEmpty) {
      emit(EventsLoaded(events: List.from(_events)));
      return;
    }

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

  // Load my events
  Future<void> loadMyEvents() async {
    emit(EventsLoading());

    final result = await getMyEvents();

    result.fold(
      (failure) => emit(EventsError(message: _getFailureMessage(failure))),
      (events) {
        _myEvents.clear();
        _myEvents.addAll(events);
        emit(MyEventsLoaded(myEvents: List.from(_myEvents)));
      },
    );
  }

  // Get event details
  Future<void> getEventDetails(String eventId) async {
    emit(EventsLoading());

    final result = await getEventById(GetEventByIdParams(eventId: eventId));

    result.fold(
      (failure) => emit(EventsError(message: _getFailureMessage(failure))),
      (event) => emit(EventDetailsLoaded(event: event)),
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
        // Add to local events list
        _events.insert(0, event);
        _myEvents.insert(0, event);
      },
    );
  }

  // Update event
  Future<void> updateEventById({
    required String eventId,
    String? title,
    String? description,
    String? location,
    int? maxParticipants,
    List<String>? tags,
  }) async {
    emit(EventsLoading());

    final result = await updateEvent(UpdateEventParams(
      eventId: eventId,
      title: title,
      description: description,
      location: location,
      maxParticipants: maxParticipants,
      tags: tags,
    ));

    result.fold(
      (failure) => emit(EventsError(message: _getFailureMessage(failure))),
      (event) {
        emit(EventUpdated(event: event));
        // Update local lists
        _updateEventInLists(event);
      },
    );
  }

  // Cancel event
  Future<void> cancelEventById({
    required String eventId,
    required String reason,
  }) async {
    emit(EventsLoading());

    final result = await cancelEvent(CancelEventParams(
      eventId: eventId,
      reason: reason,
    ));

    result.fold(
      (failure) => emit(EventsError(message: _getFailureMessage(failure))),
      (_) {
        emit(EventCancelled(eventId: eventId));
        // Remove from local lists or mark as cancelled
        _removeEventFromLists(eventId);
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
      },
    );
  }

  // Leave event
  Future<void> leaveEventById(String eventId) async {
    final result = await leaveEvent(LeaveEventParams(eventId: eventId));

    result.fold(
      (failure) => emit(EventsError(message: _getFailureMessage(failure))),
      (_) {
        emit(EventLeft(eventId: eventId));
        // Update local events list
        _updateEventJoinStatus(eventId, false);
      },
    );
  }

  // Apply filters
  Future<void> applyFilters({
    String? campus,
    EventType? type,
    List<String>? tags,
  }) async {
    await loadEvents(campus: campus, type: type, tags: tags, refresh: true);
  }

  // Clear filters
  Future<void> clearFilters() async {
    await loadEvents(refresh: true);
  }

  // Refresh events
  Future<void> refreshEvents() async {
    await loadEvents(
      campus: _currentCampus,
      type: _currentType,
      tags: _currentTags,
      refresh: true,
    );
  }

  // Refresh my events
  Future<void> refreshMyEvents() async {
    await loadMyEvents();
  }

  // Helper methods
  void _updateEventInLists(Event updatedEvent) {
    // Update in all events
    final allEventsIndex = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (allEventsIndex != -1) {
      _events[allEventsIndex] = updatedEvent;
    }

    // Update in my events
    final myEventsIndex = _myEvents.indexWhere((event) => event.id == updatedEvent.id);
    if (myEventsIndex != -1) {
      _myEvents[myEventsIndex] = updatedEvent;
    }
  }

  void _removeEventFromLists(String eventId) {
    _events.removeWhere((event) => event.id == eventId);
    _myEvents.removeWhere((event) => event.id == eventId);
  }

  void _updateEventJoinStatus(String eventId, bool isJoined) {
    final updateEvent = (List<Event> eventsList) {
      final index = eventsList.indexWhere((event) => event.id == eventId);
      if (index != -1) {
        final currentEvent = eventsList[index];
        final updatedEvent = Event(
          id: currentEvent.id,
          title: currentEvent.title,
          description: currentEvent.description,
          type: currentEvent.type,
          location: currentEvent.location,
          campus: currentEvent.campus,
          startDate: currentEvent.startDate,
          endDate: currentEvent.endDate,
          maxParticipants: currentEvent.maxParticipants,
          currentParticipants: isJoined 
              ? currentEvent.currentParticipants + 1
              : (currentEvent.currentParticipants > 0 
                  ? currentEvent.currentParticipants - 1 
                  : 0),
          isPublic: currentEvent.isPublic,
          authorId: currentEvent.authorId,
          authorName: currentEvent.authorName,
          tags: currentEvent.tags,
          requirements: currentEvent.requirements,
          isJoined: isJoined,
          createdAt: currentEvent.createdAt,
        );
        eventsList[index] = updatedEvent;
      }
    };

    updateEvent(_events);
    updateEvent(_myEvents);

    // Re-emit current state with updated data
    if (state is EventsLoaded) {
      final currentState = state as EventsLoaded;
      emit(currentState.copyWith(events: List.from(_events)));
    } else if (state is MyEventsLoaded) {
      emit(MyEventsLoaded(myEvents: List.from(_myEvents)));
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
      case NotFoundException:
        return 'Evento no encontrado';
      default:
        if (failure is ConflictException) {
          return failure.message.isNotEmpty
              ? failure.message
              : 'Ya estás registrado en este evento';
        }
        return failure.message.isNotEmpty 
            ? failure.message 
            : 'Ha ocurrido un error inesperado';
    }
  }
}