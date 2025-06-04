import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/network_info.dart';
import '../features/authentication/data/datasource/auth_local_datasource.dart';
import '../features/authentication/data/datasource/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/login_user.dart';
import '../features/authentication/domain/usecases/register_user.dart';
import '../features/authentication/presentation/cubit/auth_cubit.dart';
import '../features/authentication/presentation/cubit/ui_cubit.dart';

// Features - Matches
import '../features/matches/data/datasource/match_remote_datasource.dart';
import '../features/matches/data/datasource/match_remote_datasource_impl.dart';
import '../features/matches/data/repositories/match_repository_impl.dart';
import '../features/matches/domain/repositories/match_repository.dart';
import '../features/matches/domain/usecases/get_potential_matches.dart';
import '../features/matches/presentation/viewmodels/match_viewmodel.dart';

import '../features/discovery/data/datasource/discovery_remote_datasource.dart';
import '../features/discovery/data/repositories/discovery_repository_impl.dart';
import '../features/discovery/domain/repositories/discovery_repository.dart';
import '../features/discovery/domain/usecases/get_profiles.dart';
import '../features/discovery/domain/usecases/swipe_profile.dart';
import '../features/discovery/domain/usecases/get_profile_details.dart';
import '../features/discovery/presentation/cubit/discovery_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External - SharedPreferences primero
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  //! Dio
  sl.registerLazySingleton(() {
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: 'http://192.168.0.16:3000/api/v1/',
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
          final token = await _getStoredToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            }
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

  //! Features - Matches

  // UseCase
  sl.registerLazySingleton(() => GetPotentialMatches(sl()));

  // Repository
  sl.registerLazySingleton<MatchRepository>(() => MatchRepositoryImpl(sl()));

  // DataSource
  sl.registerLazySingletonAsync<MatchRemoteDatasource>(
    () async => MatchRemoteDatasourceImpl(
      client: sl(), // assuming 'client' is the correct parameter for Dio
      baseUrl: 'http://192.168.0.16:3000/api/v1/',
      token: await _getStoredToken() ?? '', // pass the actual token String
    ),
  );

  // ViewModel
  sl.registerFactory(() => MatchViewModel(sl()));
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

}

Future<String?> _getStoredToken() async {
  final prefs = sl<SharedPreferences>();
  return prefs.getString('auth_token');
}

Future<bool> _refreshToken() async {
  // TODO: Implement token refresh logic
  return false;
}