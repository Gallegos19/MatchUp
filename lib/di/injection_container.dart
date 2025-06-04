// lib/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Core
import '../core/network/network_info.dart';

// Authentication
import '../features/authentication/data/datasource/auth_local_datasource.dart';
import '../features/authentication/data/datasource/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/login_user.dart';
import '../features/authentication/domain/usecases/register_user.dart';
import '../features/authentication/presentation/cubit/auth_cubit.dart';
import '../features/authentication/presentation/cubit/ui_cubit.dart';

// Discovery
import '../features/discovery/data/datasource/discovery_remote_datasource.dart';
import '../features/discovery/data/repositories/discovery_repository_impl.dart';
import '../features/discovery/domain/repositories/discovery_repository.dart';
import '../features/discovery/domain/usecases/get_profiles.dart';
import '../features/discovery/domain/usecases/swipe_profile.dart';
import '../features/discovery/domain/usecases/get_profile_details.dart';
import '../features/discovery/presentation/cubit/discovery_cubit.dart';

// Matches
import '../features/matches/data/datasource/match_remote_datasource.dart';
import '../features/matches/data/datasource/match_remote_datasource_impl.dart';
import '../features/matches/data/repositories/match_repository_impl.dart';
import '../features/matches/domain/repositories/match_repository.dart';
import '../features/matches/domain/usecases/get_potential_matches.dart';
import '../features/matches/presentation/viewmodels/match_viewmodel.dart';

// Chat
import '../features/chat/data/datasource/chat_remote_datasource.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/domain/usecases/get_conversations.dart';
import '../features/chat/domain/usecases/get_messages.dart';
import '../features/chat/domain/usecases/send_message.dart';
import '../features/chat/presentation/cubit/chat_cubit.dart';

// Events
import '../features/events/data/datasource/events_remote_datasource.dart';
import '../features/events/data/repositories/events_repository_impl.dart';
import '../features/events/domain/repositories/events_repository.dart';
import '../features/events/domain/usecases/get_events.dart';
import '../features/events/domain/usecases/create_event.dart';
import '../features/events/domain/usecases/join_event.dart';
import '../features/events/presentation/cubit/events_cubit.dart';

// Study Groups
import '../features/study_groups/data/datasource/study_groups_remote_datasource.dart';
import '../features/study_groups/data/repositories/study_groups_repository_impl.dart';
import '../features/study_groups/domain/repositories/study_groups_repository.dart';
import '../features/study_groups/domain/usecases/get_study_groups.dart';
import '../features/study_groups/domain/usecases/create_study_group.dart';
import '../features/study_groups/domain/usecases/join_study_group.dart';
import '../features/study_groups/presentation/cubit/study_groups_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External - SharedPreferences primero
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => http.Client());

  //! Dio
  sl.registerLazySingleton(() {
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: 'http://192.168.167.107:3000/api/v1/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getStoredToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, clear local storage
            await clearAuthData();
          }
          handler.next(error);
        },
      ),
    ]);

    return dio;
  });

  //! Features - Authentication
  sl.registerFactory(
    () => AuthCubit(
      loginUser: sl(),
      registerUser: sl(),
    ),
  );

  sl.registerFactory(() => UiCubit());

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Discovery
  // Cubit
  sl.registerFactory(
    () => DiscoveryCubit(
      getProfiles: sl(),
      swipeProfile: sl(),
      getProfileDetails: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProfiles(sl()));
  sl.registerLazySingleton(() => SwipeProfile(sl()));
  sl.registerLazySingleton(() => GetProfileDetails(sl()));

  // Repository
  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<DiscoveryRemoteDataSource>(
    () => DiscoveryRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Matches
  // UseCase
  sl.registerLazySingleton(() => GetPotentialMatches(sl()));

  // Repository
  sl.registerLazySingleton<MatchRepository>(() => MatchRepositoryImpl(sl()));

  // DataSource
  sl.registerLazySingleton<MatchRemoteDatasource>(
    () => MatchRemoteDatasourceImpl(
      client: sl(),
      baseUrl: 'http://192.168.167.107:3000',
      token: '', // Token will be handled by interceptor
    ),
  );

  // ViewModel
  sl.registerFactory(() => MatchViewModel(sl()));

  //! Features - Chat
  // Cubit
  sl.registerFactory(
    () => ChatCubit(
      getConversations: sl(),
      getMessages: sl(),
      sendMessage: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetConversations(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Events
  // Cubit
  sl.registerFactory(
    () => EventsCubit(
      getEvents: sl(),
      createEvent: sl(),
      joinEvent: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetEvents(sl()));
  sl.registerLazySingleton(() => CreateEvent(sl()));
  sl.registerLazySingleton(() => JoinEvent(sl()));

  // Repository
  sl.registerLazySingleton<EventsRepository>(
    () => EventsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<EventsRemoteDataSource>(
    () => EventsRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Study Groups
  // Cubit
  sl.registerFactory(
    () => StudyGroupsCubit(
      getStudyGroups: sl(),
      createStudyGroup: sl(),
      joinStudyGroup: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetStudyGroups(sl()));
  sl.registerLazySingleton(() => CreateStudyGroup(sl()));
  sl.registerLazySingleton(() => JoinStudyGroup(sl()));

  // Repository
  sl.registerLazySingleton<StudyGroupsRepository>(
    () => StudyGroupsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<StudyGroupsRemoteDataSource>(
    () => StudyGroupsRemoteDataSourceImpl(dio: sl()),
  );
}

// Public helper functions (no leading underscore)
Future<String?> getStoredToken() async {
  try {
    final prefs = sl<SharedPreferences>();
    return prefs.getString('auth_token');
  } catch (e) {
    return null;
  }
}

Future<void> clearAuthData() async {
  try {
    final prefs = sl<SharedPreferences>();
    await prefs.clear();
  } catch (e) {
    throw Exception('Error clearing auth data: $e');
  }
}

// Helper function to update token
Future<void> updateStoredToken(String token) async {
  try {
    final prefs = sl<SharedPreferences>();
    await prefs.setString('auth_token', token);
    
    // Update Dio headers
    final dio = sl<Dio>();
    dio.options.headers['Authorization'] = 'Bearer $token';
  } catch (e) {
    // Ignore errors
  }
}