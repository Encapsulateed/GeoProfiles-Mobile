// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';
import 'dart:convert';

import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;

part 'api.swagger.chopper.dart';
part 'api.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class Api extends ChopperService {
  static Api create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$Api(client);
    }

    final newClient = ChopperClient(
        services: [_$Api()],
        converter: converter ?? $JsonSerializableConverter(),
        interceptors: interceptors ?? [],
        client: httpClient,
        authenticator: authenticator,
        errorConverter: errorConverter,
        baseUrl: baseUrl ?? Uri.parse('http://'));
    return _$Api(newClient);
  }

  ///
  Future<chopper.Response<ProjectDto>> apiV1ProjectsPost(
      {required CreateProjectRequest? body}) {
    generatedMapping.putIfAbsent(ProjectDto, () => ProjectDto.fromJsonFactory);

    return _apiV1ProjectsPost(body: body);
  }

  ///
  @Post(
    path: '/api/v1/projects',
    optionalBody: true,
  )
  Future<chopper.Response<ProjectDto>> _apiV1ProjectsPost(
      {@Body() required CreateProjectRequest? body});

  ///
  ///@param projectId
  Future<chopper.Response<ProfileResponse>> apiV1ProjectIdProfilePost({
    required String? projectId,
    required ProfileRequest? body,
  }) {
    generatedMapping.putIfAbsent(
        ProfileResponse, () => ProfileResponse.fromJsonFactory);

    return _apiV1ProjectIdProfilePost(projectId: projectId, body: body);
  }

  ///
  ///@param projectId
  @Post(
    path: '/api/v1/{projectId}/profile',
    optionalBody: true,
  )
  Future<chopper.Response<ProfileResponse>> _apiV1ProjectIdProfilePost({
    @Path('projectId') required String? projectId,
    @Body() required ProfileRequest? body,
  });

  ///
  ///@param id
  Future<chopper.Response<ProjectDto>> apiV1ProjectIdGet(
      {required String? id}) {
    generatedMapping.putIfAbsent(ProjectDto, () => ProjectDto.fromJsonFactory);

    return _apiV1ProjectIdGet(id: id);
  }

  ///
  ///@param id
  @Get(path: '/api/v1/project/{id}')
  Future<chopper.Response<ProjectDto>> _apiV1ProjectIdGet(
      {@Path('id') required String? id});

  ///
  ///@param projectId
  ///@param profileId
  Future<chopper.Response<FullProfileResponse>>
      apiV1ProjectIdProfileProfileIdGet({
    required String? projectId,
    required String? profileId,
  }) {
    generatedMapping.putIfAbsent(
        FullProfileResponse, () => FullProfileResponse.fromJsonFactory);

    return _apiV1ProjectIdProfileProfileIdGet(
        projectId: projectId, profileId: profileId);
  }

  ///
  ///@param projectId
  ///@param profileId
  @Get(path: '/api/v1/{projectId}/profile/{profileId}')
  Future<chopper.Response<FullProfileResponse>>
      _apiV1ProjectIdProfileProfileIdGet({
    @Path('projectId') required String? projectId,
    @Path('profileId') required String? profileId,
  });

  ///
  Future<chopper.Response<ProjectsListDto>> apiV1ProjectListGet() {
    generatedMapping.putIfAbsent(
        ProjectsListDto, () => ProjectsListDto.fromJsonFactory);

    return _apiV1ProjectListGet();
  }

  ///
  @Get(path: '/api/v1/project/list')
  Future<chopper.Response<ProjectsListDto>> _apiV1ProjectListGet();

  ///
  ///@param projectId
  Future<chopper.Response<ProfileList>> apiV1ProjectIdListGet(
      {required String? projectId}) {
    generatedMapping.putIfAbsent(
        ProfileList, () => ProfileList.fromJsonFactory);

    return _apiV1ProjectIdListGet(projectId: projectId);
  }

  ///
  ///@param projectId
  @Get(path: '/api/v1/{projectId}/list')
  Future<chopper.Response<ProfileList>> _apiV1ProjectIdListGet(
      {@Path('projectId') required String? projectId});

  ///
  Future<chopper.Response<TokenDto>> apiV1AuthLoginPost(
      {required UserDataRequest? body}) {
    generatedMapping.putIfAbsent(TokenDto, () => TokenDto.fromJsonFactory);

    return _apiV1AuthLoginPost(body: body);
  }

  ///
  @Post(
    path: '/api/v1/auth/login',
    optionalBody: true,
  )
  Future<chopper.Response<TokenDto>> _apiV1AuthLoginPost(
      {@Body() required UserDataRequest? body});

  ///
  Future<chopper.Response<UserDto>> apiV1AuthMeGet() {
    generatedMapping.putIfAbsent(UserDto, () => UserDto.fromJsonFactory);

    return _apiV1AuthMeGet();
  }

  ///
  @Get(path: '/api/v1/auth/me')
  Future<chopper.Response<UserDto>> _apiV1AuthMeGet();

  ///
  Future<chopper.Response<RefreshDto>> apiV1AuthRefreshPost(
      {required RefreshRequest? body}) {
    generatedMapping.putIfAbsent(RefreshDto, () => RefreshDto.fromJsonFactory);

    return _apiV1AuthRefreshPost(body: body);
  }

  ///
  @Post(
    path: '/api/v1/auth/refresh',
    optionalBody: true,
  )
  Future<chopper.Response<RefreshDto>> _apiV1AuthRefreshPost(
      {@Body() required RefreshRequest? body});

  ///
  Future<chopper.Response<UserDto>> apiV1RegisterPost(
      {required UserDataRequest? body}) {
    generatedMapping.putIfAbsent(UserDto, () => UserDto.fromJsonFactory);

    return _apiV1RegisterPost(body: body);
  }

  ///
  @Post(
    path: '/api/v1/register',
    optionalBody: true,
  )
  Future<chopper.Response<UserDto>> _apiV1RegisterPost(
      {@Body() required UserDataRequest? body});
}

@JsonSerializable(explicitToJson: true)
class CreateProjectRequest {
  const CreateProjectRequest({
    this.name,
  });

  factory CreateProjectRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProjectRequestFromJson(json);

  static const toJsonFactory = _$CreateProjectRequestToJson;
  Map<String, dynamic> toJson() => _$CreateProjectRequestToJson(this);

  @JsonKey(name: 'name')
  final String? name;
  static const fromJsonFactory = _$CreateProjectRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreateProjectRequest &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(name) ^ runtimeType.hashCode;
}

extension $CreateProjectRequestExtension on CreateProjectRequest {
  CreateProjectRequest copyWith({String? name}) {
    return CreateProjectRequest(name: name ?? this.name);
  }

  CreateProjectRequest copyWithWrapped({Wrapped<String?>? name}) {
    return CreateProjectRequest(name: (name != null ? name.value : this.name));
  }
}

@JsonSerializable(explicitToJson: true)
class ErrorResponse {
  const ErrorResponse({
    this.errorCode,
    this.errorMessage,
    this.errorDetails,
    this.errorId,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  static const toJsonFactory = _$ErrorResponseToJson;
  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  @JsonKey(name: 'errorCode')
  final String? errorCode;
  @JsonKey(name: 'errorMessage')
  final String? errorMessage;
  @JsonKey(name: 'errorDetails')
  final dynamic errorDetails;
  @JsonKey(name: 'errorId')
  final String? errorId;
  static const fromJsonFactory = _$ErrorResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ErrorResponse &&
            (identical(other.errorCode, errorCode) ||
                const DeepCollectionEquality()
                    .equals(other.errorCode, errorCode)) &&
            (identical(other.errorMessage, errorMessage) ||
                const DeepCollectionEquality()
                    .equals(other.errorMessage, errorMessage)) &&
            (identical(other.errorDetails, errorDetails) ||
                const DeepCollectionEquality()
                    .equals(other.errorDetails, errorDetails)) &&
            (identical(other.errorId, errorId) ||
                const DeepCollectionEquality().equals(other.errorId, errorId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(errorCode) ^
      const DeepCollectionEquality().hash(errorMessage) ^
      const DeepCollectionEquality().hash(errorDetails) ^
      const DeepCollectionEquality().hash(errorId) ^
      runtimeType.hashCode;
}

extension $ErrorResponseExtension on ErrorResponse {
  ErrorResponse copyWith(
      {String? errorCode,
      String? errorMessage,
      dynamic errorDetails,
      String? errorId}) {
    return ErrorResponse(
        errorCode: errorCode ?? this.errorCode,
        errorMessage: errorMessage ?? this.errorMessage,
        errorDetails: errorDetails ?? this.errorDetails,
        errorId: errorId ?? this.errorId);
  }

  ErrorResponse copyWithWrapped(
      {Wrapped<String?>? errorCode,
      Wrapped<String?>? errorMessage,
      Wrapped<dynamic>? errorDetails,
      Wrapped<String?>? errorId}) {
    return ErrorResponse(
        errorCode: (errorCode != null ? errorCode.value : this.errorCode),
        errorMessage:
            (errorMessage != null ? errorMessage.value : this.errorMessage),
        errorDetails:
            (errorDetails != null ? errorDetails.value : this.errorDetails),
        errorId: (errorId != null ? errorId.value : this.errorId));
  }
}

@JsonSerializable(explicitToJson: true)
class FullProfileResponse {
  const FullProfileResponse({
    this.profileId,
    this.start,
    this.end,
    this.lengthM,
    this.createdAt,
    this.points,
  });

  factory FullProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$FullProfileResponseFromJson(json);

  static const toJsonFactory = _$FullProfileResponseToJson;
  Map<String, dynamic> toJson() => _$FullProfileResponseToJson(this);

  @JsonKey(name: 'profileId')
  final String? profileId;
  @JsonKey(name: 'start', defaultValue: <double>[])
  final List<double>? start;
  @JsonKey(name: 'end', defaultValue: <double>[])
  final List<double>? end;
  @JsonKey(name: 'length_m')
  final double? lengthM;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'points', defaultValue: <ProfilePoint>[])
  final List<ProfilePoint>? points;
  static const fromJsonFactory = _$FullProfileResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FullProfileResponse &&
            (identical(other.profileId, profileId) ||
                const DeepCollectionEquality()
                    .equals(other.profileId, profileId)) &&
            (identical(other.start, start) ||
                const DeepCollectionEquality().equals(other.start, start)) &&
            (identical(other.end, end) ||
                const DeepCollectionEquality().equals(other.end, end)) &&
            (identical(other.lengthM, lengthM) ||
                const DeepCollectionEquality()
                    .equals(other.lengthM, lengthM)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality()
                    .equals(other.createdAt, createdAt)) &&
            (identical(other.points, points) ||
                const DeepCollectionEquality().equals(other.points, points)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(profileId) ^
      const DeepCollectionEquality().hash(start) ^
      const DeepCollectionEquality().hash(end) ^
      const DeepCollectionEquality().hash(lengthM) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(points) ^
      runtimeType.hashCode;
}

extension $FullProfileResponseExtension on FullProfileResponse {
  FullProfileResponse copyWith(
      {String? profileId,
      List<double>? start,
      List<double>? end,
      double? lengthM,
      DateTime? createdAt,
      List<ProfilePoint>? points}) {
    return FullProfileResponse(
        profileId: profileId ?? this.profileId,
        start: start ?? this.start,
        end: end ?? this.end,
        lengthM: lengthM ?? this.lengthM,
        createdAt: createdAt ?? this.createdAt,
        points: points ?? this.points);
  }

  FullProfileResponse copyWithWrapped(
      {Wrapped<String?>? profileId,
      Wrapped<List<double>?>? start,
      Wrapped<List<double>?>? end,
      Wrapped<double?>? lengthM,
      Wrapped<DateTime?>? createdAt,
      Wrapped<List<ProfilePoint>?>? points}) {
    return FullProfileResponse(
        profileId: (profileId != null ? profileId.value : this.profileId),
        start: (start != null ? start.value : this.start),
        end: (end != null ? end.value : this.end),
        lengthM: (lengthM != null ? lengthM.value : this.lengthM),
        createdAt: (createdAt != null ? createdAt.value : this.createdAt),
        points: (points != null ? points.value : this.points));
  }
}

@JsonSerializable(explicitToJson: true)
class IsolineDto {
  const IsolineDto({
    this.level,
    this.geomWkt,
  });

  factory IsolineDto.fromJson(Map<String, dynamic> json) =>
      _$IsolineDtoFromJson(json);

  static const toJsonFactory = _$IsolineDtoToJson;
  Map<String, dynamic> toJson() => _$IsolineDtoToJson(this);

  @JsonKey(name: 'level')
  final int? level;
  @JsonKey(name: 'geomWkt')
  final String? geomWkt;
  static const fromJsonFactory = _$IsolineDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is IsolineDto &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.geomWkt, geomWkt) ||
                const DeepCollectionEquality().equals(other.geomWkt, geomWkt)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(geomWkt) ^
      runtimeType.hashCode;
}

extension $IsolineDtoExtension on IsolineDto {
  IsolineDto copyWith({int? level, String? geomWkt}) {
    return IsolineDto(
        level: level ?? this.level, geomWkt: geomWkt ?? this.geomWkt);
  }

  IsolineDto copyWithWrapped(
      {Wrapped<int?>? level, Wrapped<String?>? geomWkt}) {
    return IsolineDto(
        level: (level != null ? level.value : this.level),
        geomWkt: (geomWkt != null ? geomWkt.value : this.geomWkt));
  }
}

@JsonSerializable(explicitToJson: true)
class ProfileList {
  const ProfileList({
    this.items,
  });

  factory ProfileList.fromJson(Map<String, dynamic> json) =>
      _$ProfileListFromJson(json);

  static const toJsonFactory = _$ProfileListToJson;
  Map<String, dynamic> toJson() => _$ProfileListToJson(this);

  @JsonKey(name: 'items', defaultValue: <ProfileListItem>[])
  final List<ProfileListItem>? items;
  static const fromJsonFactory = _$ProfileListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProfileList &&
            (identical(other.items, items) ||
                const DeepCollectionEquality().equals(other.items, items)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(items) ^ runtimeType.hashCode;
}

extension $ProfileListExtension on ProfileList {
  ProfileList copyWith({List<ProfileListItem>? items}) {
    return ProfileList(items: items ?? this.items);
  }

  ProfileList copyWithWrapped({Wrapped<List<ProfileListItem>?>? items}) {
    return ProfileList(items: (items != null ? items.value : this.items));
  }
}

@JsonSerializable(explicitToJson: true)
class ProfileListItem {
  const ProfileListItem({
    this.id,
    this.start,
    this.end,
    this.lengthM,
    this.createdAt,
  });

  factory ProfileListItem.fromJson(Map<String, dynamic> json) =>
      _$ProfileListItemFromJson(json);

  static const toJsonFactory = _$ProfileListItemToJson;
  Map<String, dynamic> toJson() => _$ProfileListItemToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'start', defaultValue: <double>[])
  final List<double>? start;
  @JsonKey(name: 'end', defaultValue: <double>[])
  final List<double>? end;
  @JsonKey(name: 'length_m')
  final double? lengthM;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$ProfileListItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProfileListItem &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.start, start) ||
                const DeepCollectionEquality().equals(other.start, start)) &&
            (identical(other.end, end) ||
                const DeepCollectionEquality().equals(other.end, end)) &&
            (identical(other.lengthM, lengthM) ||
                const DeepCollectionEquality()
                    .equals(other.lengthM, lengthM)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality()
                    .equals(other.createdAt, createdAt)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(start) ^
      const DeepCollectionEquality().hash(end) ^
      const DeepCollectionEquality().hash(lengthM) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ProfileListItemExtension on ProfileListItem {
  ProfileListItem copyWith(
      {String? id,
      List<double>? start,
      List<double>? end,
      double? lengthM,
      DateTime? createdAt}) {
    return ProfileListItem(
        id: id ?? this.id,
        start: start ?? this.start,
        end: end ?? this.end,
        lengthM: lengthM ?? this.lengthM,
        createdAt: createdAt ?? this.createdAt);
  }

  ProfileListItem copyWithWrapped(
      {Wrapped<String?>? id,
      Wrapped<List<double>?>? start,
      Wrapped<List<double>?>? end,
      Wrapped<double?>? lengthM,
      Wrapped<DateTime?>? createdAt}) {
    return ProfileListItem(
        id: (id != null ? id.value : this.id),
        start: (start != null ? start.value : this.start),
        end: (end != null ? end.value : this.end),
        lengthM: (lengthM != null ? lengthM.value : this.lengthM),
        createdAt: (createdAt != null ? createdAt.value : this.createdAt));
  }
}

@JsonSerializable(explicitToJson: true)
class ProfilePoint {
  const ProfilePoint({
    this.distance,
    this.elevation,
  });

  factory ProfilePoint.fromJson(Map<String, dynamic> json) =>
      _$ProfilePointFromJson(json);

  static const toJsonFactory = _$ProfilePointToJson;
  Map<String, dynamic> toJson() => _$ProfilePointToJson(this);

  @JsonKey(name: 'distance')
  final double? distance;
  @JsonKey(name: 'elevation')
  final double? elevation;
  static const fromJsonFactory = _$ProfilePointFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProfilePoint &&
            (identical(other.distance, distance) ||
                const DeepCollectionEquality()
                    .equals(other.distance, distance)) &&
            (identical(other.elevation, elevation) ||
                const DeepCollectionEquality()
                    .equals(other.elevation, elevation)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(distance) ^
      const DeepCollectionEquality().hash(elevation) ^
      runtimeType.hashCode;
}

extension $ProfilePointExtension on ProfilePoint {
  ProfilePoint copyWith({double? distance, double? elevation}) {
    return ProfilePoint(
        distance: distance ?? this.distance,
        elevation: elevation ?? this.elevation);
  }

  ProfilePoint copyWithWrapped(
      {Wrapped<double?>? distance, Wrapped<double?>? elevation}) {
    return ProfilePoint(
        distance: (distance != null ? distance.value : this.distance),
        elevation: (elevation != null ? elevation.value : this.elevation));
  }
}

@JsonSerializable(explicitToJson: true)
class ProfileRequest {
  const ProfileRequest({
    this.start,
    this.end,
  });

  factory ProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileRequestFromJson(json);

  static const toJsonFactory = _$ProfileRequestToJson;
  Map<String, dynamic> toJson() => _$ProfileRequestToJson(this);

  @JsonKey(name: 'start', defaultValue: <double>[])
  final List<double>? start;
  @JsonKey(name: 'end', defaultValue: <double>[])
  final List<double>? end;
  static const fromJsonFactory = _$ProfileRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProfileRequest &&
            (identical(other.start, start) ||
                const DeepCollectionEquality().equals(other.start, start)) &&
            (identical(other.end, end) ||
                const DeepCollectionEquality().equals(other.end, end)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(start) ^
      const DeepCollectionEquality().hash(end) ^
      runtimeType.hashCode;
}

extension $ProfileRequestExtension on ProfileRequest {
  ProfileRequest copyWith({List<double>? start, List<double>? end}) {
    return ProfileRequest(start: start ?? this.start, end: end ?? this.end);
  }

  ProfileRequest copyWithWrapped(
      {Wrapped<List<double>?>? start, Wrapped<List<double>?>? end}) {
    return ProfileRequest(
        start: (start != null ? start.value : this.start),
        end: (end != null ? end.value : this.end));
  }
}

@JsonSerializable(explicitToJson: true)
class ProfileResponse {
  const ProfileResponse({
    this.profileId,
    this.lengthM,
    this.points,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);

  static const toJsonFactory = _$ProfileResponseToJson;
  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);

  @JsonKey(name: 'profileId')
  final String? profileId;
  @JsonKey(name: 'length_m')
  final double? lengthM;
  @JsonKey(name: 'points', defaultValue: <ProfilePoint>[])
  final List<ProfilePoint>? points;
  static const fromJsonFactory = _$ProfileResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProfileResponse &&
            (identical(other.profileId, profileId) ||
                const DeepCollectionEquality()
                    .equals(other.profileId, profileId)) &&
            (identical(other.lengthM, lengthM) ||
                const DeepCollectionEquality()
                    .equals(other.lengthM, lengthM)) &&
            (identical(other.points, points) ||
                const DeepCollectionEquality().equals(other.points, points)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(profileId) ^
      const DeepCollectionEquality().hash(lengthM) ^
      const DeepCollectionEquality().hash(points) ^
      runtimeType.hashCode;
}

extension $ProfileResponseExtension on ProfileResponse {
  ProfileResponse copyWith(
      {String? profileId, double? lengthM, List<ProfilePoint>? points}) {
    return ProfileResponse(
        profileId: profileId ?? this.profileId,
        lengthM: lengthM ?? this.lengthM,
        points: points ?? this.points);
  }

  ProfileResponse copyWithWrapped(
      {Wrapped<String?>? profileId,
      Wrapped<double?>? lengthM,
      Wrapped<List<ProfilePoint>?>? points}) {
    return ProfileResponse(
        profileId: (profileId != null ? profileId.value : this.profileId),
        lengthM: (lengthM != null ? lengthM.value : this.lengthM),
        points: (points != null ? points.value : this.points));
  }
}

@JsonSerializable(explicitToJson: true)
class ProjectDto {
  const ProjectDto({
    this.id,
    this.name,
    this.bboxWkt,
    this.isolines,
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);

  static const toJsonFactory = _$ProjectDtoToJson;
  Map<String, dynamic> toJson() => _$ProjectDtoToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'bboxWkt')
  final String? bboxWkt;
  @JsonKey(name: 'isolines', defaultValue: <IsolineDto>[])
  final List<IsolineDto>? isolines;
  static const fromJsonFactory = _$ProjectDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProjectDto &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.bboxWkt, bboxWkt) ||
                const DeepCollectionEquality()
                    .equals(other.bboxWkt, bboxWkt)) &&
            (identical(other.isolines, isolines) ||
                const DeepCollectionEquality()
                    .equals(other.isolines, isolines)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(bboxWkt) ^
      const DeepCollectionEquality().hash(isolines) ^
      runtimeType.hashCode;
}

extension $ProjectDtoExtension on ProjectDto {
  ProjectDto copyWith(
      {String? id, String? name, String? bboxWkt, List<IsolineDto>? isolines}) {
    return ProjectDto(
        id: id ?? this.id,
        name: name ?? this.name,
        bboxWkt: bboxWkt ?? this.bboxWkt,
        isolines: isolines ?? this.isolines);
  }

  ProjectDto copyWithWrapped(
      {Wrapped<String?>? id,
      Wrapped<String?>? name,
      Wrapped<String?>? bboxWkt,
      Wrapped<List<IsolineDto>?>? isolines}) {
    return ProjectDto(
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name),
        bboxWkt: (bboxWkt != null ? bboxWkt.value : this.bboxWkt),
        isolines: (isolines != null ? isolines.value : this.isolines));
  }
}

@JsonSerializable(explicitToJson: true)
class ProjectSummaryDto {
  const ProjectSummaryDto({
    this.id,
    this.name,
    this.bboxWkt,
    this.createdAt,
  });

  factory ProjectSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectSummaryDtoFromJson(json);

  static const toJsonFactory = _$ProjectSummaryDtoToJson;
  Map<String, dynamic> toJson() => _$ProjectSummaryDtoToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'bboxWkt')
  final String? bboxWkt;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  static const fromJsonFactory = _$ProjectSummaryDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProjectSummaryDto &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.bboxWkt, bboxWkt) ||
                const DeepCollectionEquality()
                    .equals(other.bboxWkt, bboxWkt)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality()
                    .equals(other.createdAt, createdAt)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(bboxWkt) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ProjectSummaryDtoExtension on ProjectSummaryDto {
  ProjectSummaryDto copyWith(
      {String? id, String? name, String? bboxWkt, DateTime? createdAt}) {
    return ProjectSummaryDto(
        id: id ?? this.id,
        name: name ?? this.name,
        bboxWkt: bboxWkt ?? this.bboxWkt,
        createdAt: createdAt ?? this.createdAt);
  }

  ProjectSummaryDto copyWithWrapped(
      {Wrapped<String?>? id,
      Wrapped<String?>? name,
      Wrapped<String?>? bboxWkt,
      Wrapped<DateTime?>? createdAt}) {
    return ProjectSummaryDto(
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name),
        bboxWkt: (bboxWkt != null ? bboxWkt.value : this.bboxWkt),
        createdAt: (createdAt != null ? createdAt.value : this.createdAt));
  }
}

@JsonSerializable(explicitToJson: true)
class ProjectsListDto {
  const ProjectsListDto({
    this.projects,
  });

  factory ProjectsListDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectsListDtoFromJson(json);

  static const toJsonFactory = _$ProjectsListDtoToJson;
  Map<String, dynamic> toJson() => _$ProjectsListDtoToJson(this);

  @JsonKey(name: 'projects', defaultValue: <ProjectSummaryDto>[])
  final List<ProjectSummaryDto>? projects;
  static const fromJsonFactory = _$ProjectsListDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ProjectsListDto &&
            (identical(other.projects, projects) ||
                const DeepCollectionEquality()
                    .equals(other.projects, projects)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(projects) ^ runtimeType.hashCode;
}

extension $ProjectsListDtoExtension on ProjectsListDto {
  ProjectsListDto copyWith({List<ProjectSummaryDto>? projects}) {
    return ProjectsListDto(projects: projects ?? this.projects);
  }

  ProjectsListDto copyWithWrapped(
      {Wrapped<List<ProjectSummaryDto>?>? projects}) {
    return ProjectsListDto(
        projects: (projects != null ? projects.value : this.projects));
  }
}

@JsonSerializable(explicitToJson: true)
class RefreshDto {
  const RefreshDto({
    this.token,
    this.refreshToken,
  });

  factory RefreshDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshDtoFromJson(json);

  static const toJsonFactory = _$RefreshDtoToJson;
  Map<String, dynamic> toJson() => _$RefreshDtoToJson(this);

  @JsonKey(name: 'token')
  final String? token;
  @JsonKey(name: 'refreshToken')
  final String? refreshToken;
  static const fromJsonFactory = _$RefreshDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RefreshDto &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)) &&
            (identical(other.refreshToken, refreshToken) ||
                const DeepCollectionEquality()
                    .equals(other.refreshToken, refreshToken)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(token) ^
      const DeepCollectionEquality().hash(refreshToken) ^
      runtimeType.hashCode;
}

extension $RefreshDtoExtension on RefreshDto {
  RefreshDto copyWith({String? token, String? refreshToken}) {
    return RefreshDto(
        token: token ?? this.token,
        refreshToken: refreshToken ?? this.refreshToken);
  }

  RefreshDto copyWithWrapped(
      {Wrapped<String?>? token, Wrapped<String?>? refreshToken}) {
    return RefreshDto(
        token: (token != null ? token.value : this.token),
        refreshToken:
            (refreshToken != null ? refreshToken.value : this.refreshToken));
  }
}

@JsonSerializable(explicitToJson: true)
class RefreshRequest {
  const RefreshRequest({
    this.refreshToken,
  });

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestFromJson(json);

  static const toJsonFactory = _$RefreshRequestToJson;
  Map<String, dynamic> toJson() => _$RefreshRequestToJson(this);

  @JsonKey(name: 'refreshToken')
  final String? refreshToken;
  static const fromJsonFactory = _$RefreshRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RefreshRequest &&
            (identical(other.refreshToken, refreshToken) ||
                const DeepCollectionEquality()
                    .equals(other.refreshToken, refreshToken)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(refreshToken) ^ runtimeType.hashCode;
}

extension $RefreshRequestExtension on RefreshRequest {
  RefreshRequest copyWith({String? refreshToken}) {
    return RefreshRequest(refreshToken: refreshToken ?? this.refreshToken);
  }

  RefreshRequest copyWithWrapped({Wrapped<String?>? refreshToken}) {
    return RefreshRequest(
        refreshToken:
            (refreshToken != null ? refreshToken.value : this.refreshToken));
  }
}

@JsonSerializable(explicitToJson: true)
class TokenDto {
  const TokenDto({
    this.token,
    this.tokenType,
    this.refreshToken,
    this.expiresIn,
  });

  factory TokenDto.fromJson(Map<String, dynamic> json) =>
      _$TokenDtoFromJson(json);

  static const toJsonFactory = _$TokenDtoToJson;
  Map<String, dynamic> toJson() => _$TokenDtoToJson(this);

  @JsonKey(name: 'token')
  final String? token;
  @JsonKey(name: 'tokenType')
  final String? tokenType;
  @JsonKey(name: 'refreshToken')
  final String? refreshToken;
  @JsonKey(name: 'expiresIn')
  final int? expiresIn;
  static const fromJsonFactory = _$TokenDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TokenDto &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)) &&
            (identical(other.tokenType, tokenType) ||
                const DeepCollectionEquality()
                    .equals(other.tokenType, tokenType)) &&
            (identical(other.refreshToken, refreshToken) ||
                const DeepCollectionEquality()
                    .equals(other.refreshToken, refreshToken)) &&
            (identical(other.expiresIn, expiresIn) ||
                const DeepCollectionEquality()
                    .equals(other.expiresIn, expiresIn)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(token) ^
      const DeepCollectionEquality().hash(tokenType) ^
      const DeepCollectionEquality().hash(refreshToken) ^
      const DeepCollectionEquality().hash(expiresIn) ^
      runtimeType.hashCode;
}

extension $TokenDtoExtension on TokenDto {
  TokenDto copyWith(
      {String? token,
      String? tokenType,
      String? refreshToken,
      int? expiresIn}) {
    return TokenDto(
        token: token ?? this.token,
        tokenType: tokenType ?? this.tokenType,
        refreshToken: refreshToken ?? this.refreshToken,
        expiresIn: expiresIn ?? this.expiresIn);
  }

  TokenDto copyWithWrapped(
      {Wrapped<String?>? token,
      Wrapped<String?>? tokenType,
      Wrapped<String?>? refreshToken,
      Wrapped<int?>? expiresIn}) {
    return TokenDto(
        token: (token != null ? token.value : this.token),
        tokenType: (tokenType != null ? tokenType.value : this.tokenType),
        refreshToken:
            (refreshToken != null ? refreshToken.value : this.refreshToken),
        expiresIn: (expiresIn != null ? expiresIn.value : this.expiresIn));
  }
}

@JsonSerializable(explicitToJson: true)
class UserDataRequest {
  const UserDataRequest({
    this.username,
    this.email,
    this.passwordHash,
  });

  factory UserDataRequest.fromJson(Map<String, dynamic> json) =>
      _$UserDataRequestFromJson(json);

  static const toJsonFactory = _$UserDataRequestToJson;
  Map<String, dynamic> toJson() => _$UserDataRequestToJson(this);

  @JsonKey(name: 'username')
  final String? username;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'passwordHash')
  final String? passwordHash;
  static const fromJsonFactory = _$UserDataRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserDataRequest &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.passwordHash, passwordHash) ||
                const DeepCollectionEquality()
                    .equals(other.passwordHash, passwordHash)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(passwordHash) ^
      runtimeType.hashCode;
}

extension $UserDataRequestExtension on UserDataRequest {
  UserDataRequest copyWith(
      {String? username, String? email, String? passwordHash}) {
    return UserDataRequest(
        username: username ?? this.username,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash);
  }

  UserDataRequest copyWithWrapped(
      {Wrapped<String?>? username,
      Wrapped<String?>? email,
      Wrapped<String?>? passwordHash}) {
    return UserDataRequest(
        username: (username != null ? username.value : this.username),
        email: (email != null ? email.value : this.email),
        passwordHash:
            (passwordHash != null ? passwordHash.value : this.passwordHash));
  }
}

@JsonSerializable(explicitToJson: true)
class UserDto {
  const UserDto({
    this.id,
    this.username,
    this.email,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  static const toJsonFactory = _$UserDtoToJson;
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'username')
  final String? username;
  @JsonKey(name: 'email')
  final String? email;
  static const fromJsonFactory = _$UserDtoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserDto &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.username, username) ||
                const DeepCollectionEquality()
                    .equals(other.username, username)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(username) ^
      const DeepCollectionEquality().hash(email) ^
      runtimeType.hashCode;
}

extension $UserDtoExtension on UserDto {
  UserDto copyWith({String? id, String? username, String? email}) {
    return UserDto(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email);
  }

  UserDto copyWithWrapped(
      {Wrapped<String?>? id,
      Wrapped<String?>? username,
      Wrapped<String?>? email}) {
    return UserDto(
        id: (id != null ? id.value : this.id),
        username: (username != null ? username.value : this.username),
        email: (email != null ? email.value : this.email));
  }
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
      chopper.Response response) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
          body: DateTime.parse((response.body as String).replaceAll('"', ''))
              as ResultType);
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
        body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType);
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
