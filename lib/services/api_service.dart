// lib/services/api_service.dart
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geo_profiles_mobile/api/api.swagger.dart';

import '../api/client_mapping.dart';

/// Adds the `Authorization: Bearer <jwt>` header to every outgoing request
/// when an access-token is cached in [FlutterSecureStorage].
class AuthInterceptor implements Interceptor {
  const AuthInterceptor(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain,
      ) async {
    final token = await _storage.read(key: 'jwt_token');

    final Request authorisedRequest = (token != null && token.isNotEmpty)
        ? chain.request.copyWith(headers: {
      ...chain.request.headers,
      'Authorization': 'Bearer $token',
    })
        : chain.request;

    return chain.proceed(authorisedRequest);
  }
}

/// Thin wrapper around the generated [Api] client that
/// * plugs in token caching / refresh logic
/// * exposes strongly-typed helper methods
/// * hides the underlying [ChopperClient] from the rest of the app.
class ApiService {
  ApiService._(this._api, this._client, this._storage);

  final Api _api;
  final ChopperClient _client;
  final FlutterSecureStorage _storage;

  /// Creates the service pointing to [baseUrl].
  factory ApiService.create({required String baseUrl}) {
    const storage = FlutterSecureStorage();

    final client = ChopperClient(
      baseUrl: Uri.parse(baseUrl),
      services: [Api.create()],
      converter: $JsonSerializableConverter(),
      interceptors: [
        AuthInterceptor(storage),
        if (kDebugMode) HttpLoggingInterceptor(),
      ],
    );

    return ApiService._(Api.create(client: client), client, storage);
  }

  /// Dispose the underlying HTTP client.
  void dispose() => _client.dispose();

  // ---------------------------------------------------------------------------
  //  Helpers
  // ---------------------------------------------------------------------------

  Future<void> _cacheTokens({String? token, String? refreshToken}) async {
    if (token != null && token.isNotEmpty) {
      await _storage.write(key: 'jwt_token', value: token);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  // ---------------------------------------------------------------------------
  //  Auth
  // ---------------------------------------------------------------------------

  Future<TokenDto> login({
    required String username,
    required String email,
    required String passwordHash,
  }) async {
    final response = await _api.apiV1AuthLoginPost(
      body: UserDataRequest(
        username: username,
        email: email,
        passwordHash: passwordHash,
      ),
    );

    final dto = response.body!;
    await _cacheTokens(token: dto.token, refreshToken: dto.refreshToken);
    return dto;
  }

  Future<UserDto> register({
    required String username,
    required String email,
    required String passwordHash,
  }) async {
    final response = await _api.apiV1RegisterPost(
      body: UserDataRequest(
        username: username,
        email: email,
        passwordHash: passwordHash,
      ),
    );
    return response.body!;
  }

  Future<UserDto> me() async {
    final response = await _api.apiV1AuthMeGet();
    return response.body!;
  }

  Future<RefreshDto> refreshToken() async {
    final storedRefresh = await _storage.read(key: 'refresh_token');
    if (storedRefresh == null || storedRefresh.isEmpty) {
      throw StateError('No refresh token stored');
    }

    final response = await _api.apiV1AuthRefreshPost(
      body: RefreshRequest(refreshToken: storedRefresh),
    );

    final dto = response.body!;
    await _cacheTokens(token: dto.token, refreshToken: dto.refreshToken);
    return dto;
  }

  // ---------------------------------------------------------------------------
  //  Projects
  // ---------------------------------------------------------------------------

  Future<ProjectsListDto> getProjectsList() async {
    final response = await _api.apiV1ProjectListGet();
    return response.body!;
  }

  Future<ProjectDto> createProject({required String name}) async {
    final response = await _api.apiV1ProjectsPost(
      body: CreateProjectRequest(name: name),
    );
    return response.body!;
  }

  Future<ProjectDto> getProjectById({required String id}) async {
    // метод после регенерации будет apiV1ProjectsIdGet
    final response = await _api.apiV1ProjectsIdGet(id: id);
    return response.body!;
  }

  // ---------------------------------------------------------------------------
  //  Profiles
  // ---------------------------------------------------------------------------

  Future<ProfileResponse> createProfile({
    required String projectId,
    required List<double> start,
    required List<double> end,
  }) async {
    final response = await _api.apiV1ProjectIdProfilePost(
      projectId: projectId,
      body: ProfileRequest(start: start, end: end),
    );
    return response.body!;
  }

  Future<ProfileList> getProfilesList({required String projectId}) async {
    final response = await _api.apiV1ProjectIdListGet(projectId: projectId);
    return response.body!;
  }

  Future<FullProfileResponse> getFullProfile({
    required String projectId,
    required String profileId,
  }) async {
    final response = await _api.apiV1ProjectIdProfileProfileIdGet(
      projectId: projectId,
      profileId: profileId,
    );
    return response.body!;
  }

  // ---------------------------------------------------------------------------
  //  Reports
  // ---------------------------------------------------------------------------

  // lib/services/api_service.dart  (полный файл не меняем, только метод)

  Future<ReportResponse> getProfileReport({
    required String projectId,
    required String profileId,
  }) async {
    final response =
    await _api.apiV1ProjectsProjectIdProfilesProfileIdReportGet(
      projectId: projectId,
      profileId: profileId,
    );
    return response.body!;
  }
}
