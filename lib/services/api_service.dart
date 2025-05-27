import 'package:chopper/chopper.dart';
import 'package:geo_profiles_mobile/api/api.swagger.dart';

class ApiService {
  final Api _api;

  ApiService._(this._api);

  factory ApiService.create({
    required String baseUrl,
    String? bearerToken,
  }) {
    final client = ChopperClient(
      baseUrl: Uri.parse(baseUrl),
      services: [
        Api.create(),
      ],
      converter: $JsonSerializableConverter(),
      interceptors: [
        if (bearerToken != null)
          HeadersInterceptor({'Authorization': 'Bearer $bearerToken'}),
        HttpLoggingInterceptor(),
      ],
    );

    final api = Api.create(client: client);
    return ApiService._(api);
  }

  // ======== Authentication ========

  /// POST /api/v1/auth/login
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
    return r.body!;
  }

  /// POST /api/v1/register
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

  /// GET /api/v1/auth/me
  Future<UserDto> me() async {
    final r = await _api.apiV1AuthMeGet();
    return r.body!;
  }

  /// POST /api/v1/auth/refresh
  Future<RefreshDto> refresh({
    required String refreshToken,
  }) async {
    final r = await _api.apiV1AuthRefreshPost(
      body: RefreshRequest(refreshToken: refreshToken),
    );
    return r.body!;
  }

  // ======== Projects ========

  /// GET /api/v1/project/list
  Future<ProjectsListDto> getProjectsList() async {
    final r = await _api.apiV1ProjectListGet();
    return r.body!;
  }

  /// POST /api/v1/projects
  Future<ProjectDto> createProject({
    required String name,
  }) async {
    final r = await _api.apiV1ProjectsPost(
      body: CreateProjectRequest(name: name),
    );
    return r.body!;
  }

  /// GET /api/v1/project/{id}
  Future<ProjectDto> getProjectById({
    required String id,
  }) async {
    final r = await _api.apiV1ProjectIdGet(id: id);
    return r.body!;
  }

  // ======== Profiles ========

  /// POST /api/v1/{projectId}/profile
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

  /// GET /api/v1/{projectId}/list
  Future<ProfileList> getProfilesList({
    required String projectId,
  }) async {
    final r = await _api.apiV1ProjectIdListGet(projectId: projectId);
    return r.body!;
  }

  /// GET /api/v1/{projectId}/profile/{profileId}
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
