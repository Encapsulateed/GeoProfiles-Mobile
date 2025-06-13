// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$Api extends Api {
  _$Api([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = Api;

  @override
  Future<Response<ProjectDto>> _apiV1ProjectsPost(
      {required CreateProjectRequest? body}) {
    final Uri $url = Uri.parse('/api/v1/projects');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<ProjectDto, ProjectDto>($request);
  }

  @override
  Future<Response<ProfileResponse>> _apiV1ProjectIdProfilePost({
    required String? projectId,
    required ProfileRequest? body,
  }) {
    final Uri $url = Uri.parse('/api/v1/${projectId}/profile');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<ProfileResponse, ProfileResponse>($request);
  }

  @override
  Future<Response<ReportResponse>>
      _apiV1ProjectsProjectIdProfilesProfileIdReportGet({
    required String? projectId,
    required String? profileId,
  }) {
    final Uri $url =
        Uri.parse('/api/v1/projects/${projectId}/profiles/${profileId}/report');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<ReportResponse, ReportResponse>($request);
  }

  @override
  Future<Response<ProjectDto>> _apiV1ProjectsIdGet({required String? id}) {
    final Uri $url = Uri.parse('/api/v1/projects/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<ProjectDto, ProjectDto>($request);
  }

  @override
  Future<Response<FullProfileResponse>> _apiV1ProjectIdProfileProfileIdGet({
    required String? projectId,
    required String? profileId,
  }) {
    final Uri $url = Uri.parse('/api/v1/${projectId}/profile/${profileId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<FullProfileResponse, FullProfileResponse>($request);
  }

  @override
  Future<Response<ProjectsListDto>> _apiV1ProjectListGet() {
    final Uri $url = Uri.parse('/api/v1/project/list');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<ProjectsListDto, ProjectsListDto>($request);
  }

  @override
  Future<Response<ProfileList>> _apiV1ProjectIdListGet(
      {required String? projectId}) {
    final Uri $url = Uri.parse('/api/v1/${projectId}/list');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<ProfileList, ProfileList>($request);
  }

  @override
  Future<Response<TokenDto>> _apiV1AuthLoginPost(
      {required UserDataRequest? body}) {
    final Uri $url = Uri.parse('/api/v1/auth/login');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<TokenDto, TokenDto>($request);
  }

  @override
  Future<Response<UserDto>> _apiV1AuthMeGet() {
    final Uri $url = Uri.parse('/api/v1/auth/me');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<UserDto, UserDto>($request);
  }

  @override
  Future<Response<RefreshDto>> _apiV1AuthRefreshPost(
      {required RefreshRequest? body}) {
    final Uri $url = Uri.parse('/api/v1/auth/refresh');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<RefreshDto, RefreshDto>($request);
  }

  @override
  Future<Response<UserDto>> _apiV1RegisterPost(
      {required UserDataRequest? body}) {
    final Uri $url = Uri.parse('/api/v1/register');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<UserDto, UserDto>($request);
  }
}
