// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DownloadTaskModel _$$_DownloadTaskModelFromJson(Map<String, dynamic> json) =>
    _$_DownloadTaskModel(
      id: json['id'] as String,
      url: json['url'] as String,
      path: json['path'] as String,
      status: $enumDecode(_$DownloadTaskStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$$_DownloadTaskModelToJson(
        _$_DownloadTaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'path': instance.path,
      'status': _$DownloadTaskStatusEnumMap[instance.status]!,
    };

const _$DownloadTaskStatusEnumMap = {
  DownloadTaskStatus.notstarted: 'notstarted',
  DownloadTaskStatus.inprogress: 'inprogress',
  DownloadTaskStatus.paused: 'paused',
  DownloadTaskStatus.error: 'error',
  DownloadTaskStatus.complete: 'complete',
};
