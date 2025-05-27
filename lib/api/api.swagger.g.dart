// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateProjectRequest _$CreateProjectRequestFromJson(
        Map<String, dynamic> json) =>
    CreateProjectRequest(
      name: json['name'] as String?,
    );

Map<String, dynamic> _$CreateProjectRequestToJson(
        CreateProjectRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      errorCode: json['errorCode'] as String?,
      errorMessage: json['errorMessage'] as String?,
      errorDetails: json['errorDetails'],
      errorId: json['errorId'] as String?,
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'errorCode': instance.errorCode,
      'errorMessage': instance.errorMessage,
      'errorDetails': instance.errorDetails,
      'errorId': instance.errorId,
    };

FullProfileResponse _$FullProfileResponseFromJson(Map<String, dynamic> json) =>
    FullProfileResponse(
      profileId: json['profileId'] as String?,
      start: (json['start'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      end: (json['end'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      lengthM: (json['length_m'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      points: (json['points'] as List<dynamic>?)
              ?.map((e) => ProfilePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$FullProfileResponseToJson(
        FullProfileResponse instance) =>
    <String, dynamic>{
      'profileId': instance.profileId,
      'start': instance.start,
      'end': instance.end,
      'length_m': instance.lengthM,
      'created_at': instance.createdAt?.toIso8601String(),
      'points': instance.points?.map((e) => e.toJson()).toList(),
    };

IsolineDto _$IsolineDtoFromJson(Map<String, dynamic> json) => IsolineDto(
      level: (json['level'] as num?)?.toInt(),
      geomWkt: json['geomWkt'] as String?,
    );

Map<String, dynamic> _$IsolineDtoToJson(IsolineDto instance) =>
    <String, dynamic>{
      'level': instance.level,
      'geomWkt': instance.geomWkt,
    };

ProfileList _$ProfileListFromJson(Map<String, dynamic> json) => ProfileList(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ProfileListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ProfileListToJson(ProfileList instance) =>
    <String, dynamic>{
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };

ProfileListItem _$ProfileListItemFromJson(Map<String, dynamic> json) =>
    ProfileListItem(
      id: json['id'] as String?,
      start: (json['start'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      end: (json['end'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      lengthM: (json['length_m'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ProfileListItemToJson(ProfileListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start': instance.start,
      'end': instance.end,
      'length_m': instance.lengthM,
      'created_at': instance.createdAt?.toIso8601String(),
    };

ProfilePoint _$ProfilePointFromJson(Map<String, dynamic> json) => ProfilePoint(
      distance: (json['distance'] as num?)?.toDouble(),
      elevation: (json['elevation'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProfilePointToJson(ProfilePoint instance) =>
    <String, dynamic>{
      'distance': instance.distance,
      'elevation': instance.elevation,
    };

ProfileRequest _$ProfileRequestFromJson(Map<String, dynamic> json) =>
    ProfileRequest(
      start: (json['start'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      end: (json['end'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );

Map<String, dynamic> _$ProfileRequestToJson(ProfileRequest instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
    };

ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) =>
    ProfileResponse(
      profileId: json['profileId'] as String?,
      lengthM: (json['length_m'] as num?)?.toDouble(),
      points: (json['points'] as List<dynamic>?)
              ?.map((e) => ProfilePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ProfileResponseToJson(ProfileResponse instance) =>
    <String, dynamic>{
      'profileId': instance.profileId,
      'length_m': instance.lengthM,
      'points': instance.points?.map((e) => e.toJson()).toList(),
    };

ProjectDto _$ProjectDtoFromJson(Map<String, dynamic> json) => ProjectDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      bboxWkt: json['bboxWkt'] as String?,
      isolines: (json['isolines'] as List<dynamic>?)
              ?.map((e) => IsolineDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ProjectDtoToJson(ProjectDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bboxWkt': instance.bboxWkt,
      'isolines': instance.isolines?.map((e) => e.toJson()).toList(),
    };

ProjectSummaryDto _$ProjectSummaryDtoFromJson(Map<String, dynamic> json) =>
    ProjectSummaryDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      bboxWkt: json['bboxWkt'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ProjectSummaryDtoToJson(ProjectSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bboxWkt': instance.bboxWkt,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

ProjectsListDto _$ProjectsListDtoFromJson(Map<String, dynamic> json) =>
    ProjectsListDto(
      projects: (json['projects'] as List<dynamic>?)
              ?.map(
                  (e) => ProjectSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ProjectsListDtoToJson(ProjectsListDto instance) =>
    <String, dynamic>{
      'projects': instance.projects?.map((e) => e.toJson()).toList(),
    };

RefreshDto _$RefreshDtoFromJson(Map<String, dynamic> json) => RefreshDto(
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$RefreshDtoToJson(RefreshDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refreshToken': instance.refreshToken,
    };

RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    RefreshRequest(
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
    };

TokenDto _$TokenDtoFromJson(Map<String, dynamic> json) => TokenDto(
      token: json['token'] as String?,
      tokenType: json['tokenType'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TokenDtoToJson(TokenDto instance) => <String, dynamic>{
      'token': instance.token,
      'tokenType': instance.tokenType,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
    };

UserDataRequest _$UserDataRequestFromJson(Map<String, dynamic> json) =>
    UserDataRequest(
      username: json['username'] as String?,
      email: json['email'] as String?,
      passwordHash: json['passwordHash'] as String?,
    );

Map<String, dynamic> _$UserDataRequestToJson(UserDataRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'passwordHash': instance.passwordHash,
    };

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      id: json['id'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
    };
