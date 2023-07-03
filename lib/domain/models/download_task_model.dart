
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_task_model.freezed.dart';
part 'download_task_model.g.dart';


enum DownloadTaskStatus{
  notstarted,
  inprogress,
  paused,
  error,
  complete,
}

@freezed
class DownloadTaskModel with _$DownloadTaskModel {

  factory DownloadTaskModel({
    required String id,
    required String url,
    required String path,
    required DownloadTaskStatus status,
  }) = _DownloadTaskModel;
  
  factory DownloadTaskModel.fromJson(Map<String, dynamic> json) => _$DownloadTaskModelFromJson(json);
}