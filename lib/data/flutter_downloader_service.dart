import 'package:flutter_download_demo/domain/models/download_task_model.dart';
import 'package:flutter_downloader/flutter_downloader.dart' as downloader;
import 'package:path_provider/path_provider.dart';

class FlutterDownloaderService {
  static Future<List<String>> getTasksIdByUrl(String url) async {
    final String query = "SELECT * FROM task WHERE status=3 AND url='$url";
    final result =
        await downloader.FlutterDownloader.loadTasksWithRawQuery(query: query);
    if (result == null) return [];
    return result.map((e) => e.taskId).toList();
  }

  static Future<List<DownloadTaskModel>> getAllDownloadTasks() async {
    final downloaderTask = await downloader.FlutterDownloader.loadTasks();
    if (downloaderTask == null) return [];
    getTemporaryDirectory();
    return downloaderTask.map((e) => e.toModel()).toList();
  }
}

extension DownloadTaskStatusExt on downloader.DownloadTaskStatus {
  DownloadTaskStatus toStatus() {
    switch (this) {
      case downloader.DownloadTaskStatus.undefined:
        return DownloadTaskStatus.notstarted;
      case downloader.DownloadTaskStatus.running:
        return DownloadTaskStatus.inprogress;
      case downloader.DownloadTaskStatus.complete:
        return DownloadTaskStatus.complete;
      case downloader.DownloadTaskStatus.paused:
        return DownloadTaskStatus.paused;
      default:
        return DownloadTaskStatus.error;
    }
  }
}

extension DownloadTaskExt on downloader.DownloadTask {
  DownloadTaskModel toModel() {
    return DownloadTaskModel(
      id: taskId,
      url: url,
      progress: progress,
      path: savedDir,
      status: status.toStatus(),
    );
  }
}
