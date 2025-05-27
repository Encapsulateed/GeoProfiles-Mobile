import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geo_profiles_mobile/api/api.swagger.dart';


class AuthInterceptor implements Interceptor {
  final FlutterSecureStorage _storage;
  AuthInterceptor(this._storage);

  /// На каждый запрос добавляем "Authorization: Bearer <jwt>" — если токен есть.
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final token = await _storage.read(key: 'jwt_token');

    final Request request = (token != null && token.isNotEmpty)
        ? chain.request.copyWith(headers: {
      ...chain.request.headers,
      'Authorization': 'Bearer $token',
    })
        : chain.request;

    return chain.proceed(request);
  }
}

class ApiService {
  final Api _api;
  final ChopperClient _client;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService._(this._api, this._client);

  factory ApiService.create({required String baseUrl}) {
    final storage = const FlutterSecureStorage();

    final client = ChopperClient(
        baseUrl: Uri.parse(baseUrl),
        services: [Api.create()],
        converter: $JsonSerializableConverter(),
        interceptors: [
    AuthInterceptor(storage),
    HttpLoggingInterceptor(),
    ],
    );

    return ApiService._(Api.create(client: client), client);
  }

  // ================= PRIVATE =================
  Future<void> _cacheTokens(TokenDto t) async {
    if (t.token != null) await _storage.write(key: 'jwt_token', value: t.token);
    if (t.refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: t.refreshToken);
    }
  }

  // ================= AUTH =================
  Future<TokenDto> login({
    required String username,
    required String email,
    required String passwordHash,
  }) async {
    final r = await _api.apiV1AuthLoginPost(
      body: UserDataRequest(
        username: username,
        email: email,
        passwordHash: passwordHash,
      ),
    );
    await _cacheTokens(r.body!);
    return r.body!;
  }

  Future<UserDto> register({
    required String username,
    required String email,
    required String passwordHash,
  }) async {
    final r = await _api.apiV1RegisterPost(
      body: UserDataRequest(
        username: username,
        email: email,
        passwordHash: passwordHash,
      ),
    );
    return r.body!;
  }

  Future<UserDto> me() async {
    final r = await _api.apiV1AuthMeGet();
    return r.body!;
  }

  Future<RefreshDto> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) throw Exception('No refresh token');

    final r = await _api.apiV1AuthRefreshPost(
      body: RefreshRequest(refreshToken: refreshToken),
    );
    await _cacheTokens(r.body! as TokenDto);
    return r.body!;
  }

  // ================= PROJECTS =================
  Future<ProjectsListDto> getProjectsList() async {
    final r = await _api.apiV1ProjectListGet();
    return r.body!;
  }

  Future<ProjectDto> createProject({required String name}) async {
    final r = await _api.apiV1ProjectsPost(
      body: CreateProjectRequest(name: name),
    );
    return r.body!;
  }

  Future<ProjectDto> getProjectById({required String id}) async {
    final r = await _api.apiV1ProjectIdGet(id: id);
    return r.body!;
  }

  // ================= PROFILES =================
  Future<ProfileResponse> createProfile({
    required String projectId,
    required List<double> start,
    required List<double> end,
  }) async {
    final r = await _api.apiV1ProjectIdProfilePost(
      projectId: projectId,
      body: ProfileRequest(start: start, end: end),
    );
    return r.body!;
  }

  Future<ProfileList> getProfilesList({required String projectId}) async {
    final r = await _api.apiV1ProjectIdListGet(projectId: projectId);
    return r.body!;
  }

  Future<FullProfileResponse> getFullProfile({
    required String projectId,
    required String profileId,
  }) async {
    final r = await _api.apiV1ProjectIdProfileProfileIdGet(
      projectId: projectId,
      profileId: profileId,
    );
    return r.body!;
  }
}