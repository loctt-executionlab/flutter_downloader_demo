import 'dart:io';

import 'package:flutter_download_demo/data/flutter_downloader_service.dart';
import 'package:flutter_download_demo/data/storage_service.dart';
import 'package:flutter_download_demo/domain/models/download_task_model.dart';
import 'package:flutter_download_demo/notifier/flutter_downloader_listener_notifier.dart';
import 'package:flutter_downloader/flutter_downloader.dart' as downloader;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'download_file_status_notifier.g.dart';

@Riverpod(keepAlive: true)
class DownloadFileStatusNotifier extends _$DownloadFileStatusNotifier {
  @override
  List<DownloadTaskModel> build() {
    final status = ref.watch(flutterDownloaderListenerNotifierProvider);
    status.whenData((value) => _handleTaskStatusUpdate(value),);
    _init();
    return [];
  }

  _init() async {
    state = await FlutterDownloaderService.getAllDownloadTasks();
  }

  _handleTaskStatusUpdate(TaskStatus status) {
    var newList = <DownloadTaskModel>[];
    for (var element in state) {
      if (element.id == status.id) {
        newList.add(element.copyWith(
          status: status.status,
          progress: status.progress,
        ));
      }
    }
    state = newList;
  }

  requestDownload(String url) async {
    final savePath = await StorageService.getStoragePath(null);
    if (!Directory(savePath).existsSync()) {
      await Directory(savePath).create();
    }
    final result = await downloader.FlutterDownloader.enqueue(url: url, savedDir: savePath);
    if (result != null) {
          state = [...state, DownloadTaskModel(id: result, url: url, path: savePath, progress: 0, status: DownloadTaskStatus.notstarted)];
    }
  }

  requestPause(String id) {
    downloader.FlutterDownloader.pause(taskId: id);
  }

  requestResume(String id) {
    downloader.FlutterDownloader.resume(taskId: id);
  }

  requestCancel(String id) {
    downloader.FlutterDownloader.cancel(taskId: id);
  }

  delete(String id) async {
    await downloader.FlutterDownloader.cancel(taskId:  id);
    downloader.FlutterDownloader.remove(taskId: id, shouldDeleteContent: true);
  }
}
