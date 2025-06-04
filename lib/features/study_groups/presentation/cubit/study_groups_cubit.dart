// lib/features/study_groups/presentation/cubit/study_groups_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/study_group.dart';
import '../../domain/usecases/get_study_groups.dart';
import '../../domain/usecases/create_study_group.dart';
import '../../domain/usecases/join_study_group.dart';

// States
abstract class StudyGroupsState extends Equatable {
  const StudyGroupsState();

  @override
  List<Object?> get props => [];
}

class StudyGroupsInitial extends StudyGroupsState {}

class StudyGroupsLoading extends StudyGroupsState {}

class StudyGroupsLoaded extends StudyGroupsState {
  final List<StudyGroup> groups;
  final bool hasReachedMax;

  const StudyGroupsLoaded({
    required this.groups,
    this.hasReachedMax = false,
  });

  StudyGroupsLoaded copyWith({
    List<StudyGroup>? groups,
    bool? hasReachedMax,
  }) {
    return StudyGroupsLoaded(
      groups: groups ?? this.groups,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [groups, hasReachedMax];
}

class StudyGroupsError extends StudyGroupsState {
  final String message;

  const StudyGroupsError({required this.message});

  @override
  List<Object> get props => [message];
}

class StudyGroupCreated extends StudyGroupsState {
  final StudyGroup group;

  const StudyGroupCreated({required this.group});

  @override
  List<Object> get props => [group];
}

class StudyGroupJoined extends StudyGroupsState {
  final String groupId;

  const StudyGroupJoined({required this.groupId});

  @override
  List<Object> get props => [groupId];
}

// Cubit
class StudyGroupsCubit extends Cubit<StudyGroupsState> {
  final GetStudyGroups getStudyGroups;
  final CreateStudyGroup createStudyGroup;
  final JoinStudyGroup joinStudyGroup;

  StudyGroupsCubit({
    required this.getStudyGroups,
    required this.createStudyGroup,
    required this.joinStudyGroup,
  }) : super(StudyGroupsInitial());

  // Current state management
  int _currentPage = 1;
  final List<StudyGroup> _groups = [];
  String? _currentCampus;
  String? _currentSubject;
  String? _currentCareer;

  // Getters
  bool get isLoading => state is StudyGroupsLoading;
  List<StudyGroup> get groups => _groups;

  // Load initial study groups
  Future<void> loadStudyGroups({
    String? campus,
    String? subject,
    String? career,
  }) async {
    emit(StudyGroupsLoading());
    
    _currentPage = 1;
    _currentCampus = campus;
    _currentSubject = subject;
    _currentCareer = career;
    _groups.clear();

    final result = await getStudyGroups(GetStudyGroupsParams(
      page: _currentPage,
      limit: 20,
      campus: campus,
      subject: subject,
      career: career,
    ));

    result.fold(
      (failure) => emit(StudyGroupsError(message: _getFailureMessage(failure))),
      (groups) {
        _groups.addAll(groups);
        emit(StudyGroupsLoaded(
          groups: List.from(_groups),
          hasReachedMax: groups.length < 20,
        ));
      },
    );
  }

  // Load more study groups (pagination)
  Future<void> loadMoreStudyGroups() async {
    if (state is! StudyGroupsLoaded) return;
    
    final currentState = state as StudyGroupsLoaded;
    if (currentState.hasReachedMax) return;

    _currentPage++;

    final result = await getStudyGroups(GetStudyGroupsParams(
      page: _currentPage,
      limit: 20,
      campus: _currentCampus,
      subject: _currentSubject,
      career: _currentCareer,
    ));

    result.fold(
      (failure) => emit(StudyGroupsError(message: _getFailureMessage(failure))),
      (newGroups) {
        _groups.addAll(newGroups);
        emit(currentState.copyWith(
          groups: List.from(_groups),
          hasReachedMax: newGroups.length < 20,
        ));
      },
    );
  }

  // Create new study group
  Future<void> createNewStudyGroup({
    required String name,
    required String description,
    required String subject,
    required String career,
    required int semester,
    required String campus,
    required int maxMembers,
    required Map<String, StudySchedule> studySchedule,
    required bool isPrivate,
    required List<GroupRequirement> requirements,
  }) async {
    emit(StudyGroupsLoading());

    final result = await createStudyGroup(CreateStudyGroupParams(
      name: name,
      description: description,
      subject: subject,
      career: career,
      semester: semester,
      campus: campus,
      maxMembers: maxMembers,
      studySchedule: studySchedule,
      isPrivate: isPrivate,
      requirements: requirements,
    ));

    result.fold(
      (failure) => emit(StudyGroupsError(message: _getFailureMessage(failure))),
      (group) {
        emit(StudyGroupCreated(group: group));
        // Refresh groups list
        loadStudyGroups(
          campus: _currentCampus,
          subject: _currentSubject,
          career: _currentCareer,
        );
      },
    );
  }

  // Join study group
  Future<void> joinStudyGroupById(String groupId) async {
    final result = await joinStudyGroup(JoinStudyGroupParams(groupId: groupId));

    result.fold(
      (failure) => emit(StudyGroupsError(message: _getFailureMessage(failure))),
      (_) {
        emit(StudyGroupJoined(groupId: groupId));
        // Update local groups list
        _updateGroupJoinStatus(groupId, true);
        if (state is StudyGroupsLoaded) {
          final currentState = state as StudyGroupsLoaded;
          emit(currentState.copyWith(groups: List.from(_groups)));
        }
      },
    );
  }

  // Apply filters
  Future<void> applyFilters({
    String? campus,
    String? subject,
    String? career,
  }) async {
    await loadStudyGroups(campus: campus, subject: subject, career: career);
  }

  // Clear filters
  Future<void> clearFilters() async {
    await loadStudyGroups();
  }

  // Refresh study groups
  Future<void> refreshStudyGroups() async {
    await loadStudyGroups(
      campus: _currentCampus,
      subject: _currentSubject,
      career: _currentCareer,
    );
  }

  // Helper method to update group join status locally
  void _updateGroupJoinStatus(String groupId, bool isJoined) {
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index != -1) {
      final updatedGroup = StudyGroup(
        id: _groups[index].id,
        name: _groups[index].name,
        description: _groups[index].description,
        subject: _groups[index].subject,
        career: _groups[index].career,
        semester: _groups[index].semester,
        campus: _groups[index].campus,
        maxMembers: _groups[index].maxMembers,
        currentMembers: isJoined 
            ? _groups[index].currentMembers + 1
            : _groups[index].currentMembers - 1,
        studySchedule: _groups[index].studySchedule,
        isPrivate: _groups[index].isPrivate,
        authorId: _groups[index].authorId,
        authorName: _groups[index].authorName,
        requirements: _groups[index].requirements,
        isJoined: isJoined,
        createdAt: _groups[index].createdAt,
      );
      _groups[index] = updatedGroup;
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