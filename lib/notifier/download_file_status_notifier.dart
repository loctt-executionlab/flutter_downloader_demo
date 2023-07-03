

import 'package:flutter_download_demo/data/flutter_downloader_service.dart';
import 'package:flutter_download_demo/domain/models/download_task_model.dart';
import 'package:flutter_download_demo/notifier/flutter_downloader_listener_notifier.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_file_status_notifier.g.dart';

@Riverpod(keepAlive: true)
class DownloadFileStatusNotifier extends _$DownloadFileStatusNotifier {

  @override
   FutureOr<List<DownloadTaskModel>> build() {
    ref.listen(flutterDownloaderListenerNotifierProvider, (previous, next) {
      next.whenData((value) => _handleTaskStatusUpdate(value));
     });

    return FlutterDownloaderService.getAllDownloadTasks();
  }

  _handleTaskStatusUpdate(TaskStatus status) {
    if  (state.value == null) return;
    var newList = <DownloadTaskModel>[];
    for (var element in state.value!) {
      if (element.id == status.id) {
        newList.add(element.copyWith(status: status.status));
      }
      else {
        newList.add(element);
      }
    }
    state = AsyncData(newList);
  }

  requestDownload(String url , String savePath) {
    FlutterDownloader.enqueue(url: url, savedDir: savePath);
  }

  requestCancel(String id) {
    FlutterDownloader.cancel(taskId: id);
  }

  delete(String id) {
    FlutterDownloader.remove(taskId: id, shouldDeleteContent: true);
  }

}
