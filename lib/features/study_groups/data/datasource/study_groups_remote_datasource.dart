
// lib/features/study_groups/data/datasource/study_groups_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/study_group_model.dart';
import '../../domain/entities/study_group.dart';

abstract class StudyGroupsRemoteDataSource {
  Future<List<StudyGroupModel>> getStudyGroups({
    int page = 1,
    int limit = 20,
    String? campus,
    String? subject,
    String? career,
  });

  Future<StudyGroupModel> createStudyGroup({
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
  });

  Future<List<StudyGroupModel>> searchStudyGroups({
    required String query,
    String? campus,
    int limit = 20,
  });

  Future<List<String>> getPopularSubjects({
    String? campus,
    int limit = 20,
  });

  Future<List<StudyGroupModel>> getMyGroups();
  Future<StudyGroupModel> getStudyGroupById(String groupId);
  Future<List<GroupMemberModel>> getGroupMembers(String groupId);
  Future<StudyGroupModel> updateStudyGroup({
    required String groupId,
    String? name,
    String? description,
    Map<String, StudySchedule>? studySchedule,
    int? maxMembers,
    bool? isPrivate,
    List<GroupRequirement>? requirements,
  });
  Future<void> deleteStudyGroup({
    required String groupId,
    required String reason,
  });
  Future<void> joinStudyGroup(String groupId);
  Future<void> leaveStudyGroup(String groupId);
}

class StudyGroupsRemoteDataSourceImpl implements StudyGroupsRemoteDataSource {
  final Dio dio;

  StudyGroupsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StudyGroupModel>> getStudyGroups({
    int page = 1,
    int limit = 20,
    String? campus,
    String? subject,
    String? career,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (campus != null) queryParams['campus'] = campus;
      if (subject != null) queryParams['subject'] = subject;
      if (career != null) queryParams['career'] = career;

      final response = await dio.get('study-groups', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> groupsJson = data is List ? data : data['groups'] ?? [];
        
        return groupsJson.map((json) => StudyGroupModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener grupos de estudio',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<StudyGroupModel> createStudyGroup({
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
    try {
      final response = await dio.post(
        'study-groups',
        data: {
          'name': name,
          'description': description,
          'subject': subject,
          'career': career,
          'semester': semester,
          'campus': campus,
          'maxMembers': maxMembers,
          'studySchedule': studySchedule.map((key, value) => MapEntry(key, {
            'start': value.start,
            'end': value.end,
          })),
          'isPrivate': isPrivate,
          'requirements': requirements.map((req) => {
            'type': req.type,
            if (req.type == 'semester') 'minSemester': req.value,
            if (req.type == 'gpa') 'minGpa': req.value,
          }).toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return StudyGroupModel.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al crear grupo de estudio',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<StudyGroupModel>> searchStudyGroups({
    required String query,
    String? campus,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'limit': limit,
      };

      if (campus != null) queryParams['campus'] = campus;

      final response = await dio.get('study-groups/search', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> groupsJson = data is List ? data : data['groups'] ?? [];
        
        return groupsJson.map((json) => StudyGroupModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al buscar grupos',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<String>> getPopularSubjects({
    String? campus,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };

      if (campus != null) queryParams['campus'] = campus;

      final response = await dio.get('study-groups/popular-subjects', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> subjectsJson = data is List ? data : data['subjects'] ?? [];
        
        return subjectsJson.map((e) => e.toString()).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener materias populares',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<StudyGroupModel>> getMyGroups() async {
    try {
      final response = await dio.get('study-groups/my-groups');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> groupsJson = data is List ? data : data['groups'] ?? [];
        
        return groupsJson.map((json) => StudyGroupModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener mis grupos',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<StudyGroupModel> getStudyGroupById(String groupId) async {
    try {
      final response = await dio.get('study-groups/$groupId');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return StudyGroupModel.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener grupo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<GroupMemberModel>> getGroupMembers(String groupId) async {
    try {
      final response = await dio.get('study-groups/$groupId/members');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> membersJson = data is List ? data : data['members'] ?? [];
        
        return membersJson.map((json) => GroupMemberModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener miembros',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<StudyGroupModel> updateStudyGroup({
    required String groupId,
    String? name,
    String? description,
    Map<String, StudySchedule>? studySchedule,
    int? maxMembers,
    bool? isPrivate,
    List<GroupRequirement>? requirements,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (studySchedule != null) {
        data['studySchedule'] = studySchedule.map((key, value) => MapEntry(key, {
          'start': value.start,
          'end': value.end,
        }));
      }
      if (maxMembers != null) data['maxMembers'] = maxMembers;
      if (isPrivate != null) data['isPrivate'] = isPrivate;
      if (requirements != null) {
        data['requirements'] = requirements.map((req) => {
          'type': req.type,
          if (req.type == 'semester') 'minSemester': req.value,
          if (req.type == 'gpa') 'minGpa': req.value,
        }).toList();
      }

      final response = await dio.put('study-groups/$groupId', data: data);

      if (response.statusCode == 200) {
        final responseData = response.data['data'] ?? response.data;
        return StudyGroupModel.fromJson(responseData);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al actualizar grupo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteStudyGroup({
    required String groupId,
    required String reason,
  }) async {
    try {
      final response = await dio.delete(
        'study-groups/$groupId',
        data: {'reason': reason},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al eliminar grupo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> joinStudyGroup(String groupId) async {
    try {
      final response = await dio.post('study-groups/$groupId/join');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al unirse al grupo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> leaveStudyGroup(String groupId) async {
    try {
      final response = await dio.delete('study-groups/$groupId/leave');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al salir del grupo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Tiempo de espera agotado',
          statusCode: e.response?.statusCode,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Error del servidor';
        
        switch (statusCode) {
          case 400:
            return ValidationException(message: message, statusCode: statusCode);
          case 401:
            return AuthenticationException(message: message, statusCode: statusCode);
          case 403:
            return UnauthorizedException(message: message, statusCode: statusCode);
          case 404:
            return NotFoundException(message: message, statusCode: statusCode);
          default:
            return ServerException(message: message, statusCode: statusCode);
        }
      
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Error de conexión. Verifica tu internet',
          statusCode: null,
        );
      
      default:
        return ServerException(
          message: 'Error inesperado: ${e.message}',
          statusCode: e.response?.statusCode,
        );
    }
  }
}