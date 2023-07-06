import 'package:flutter/material.dart';
import 'package:flutter_download_demo/data/flutter_downloader_service.dart';
import 'package:flutter_download_demo/notifier/download_file_status_notifier.dart';
import 'package:flutter_download_demo/notifier/task_status_notifier.dart';
import 'package:flutter_download_demo/views/progress_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/download_task_model.dart';

class TaskEntry extends ConsumerWidget {
  const TaskEntry({super.key, required this.video});

  final DownloadVideo video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadStatus = ref.watch(taskStatusNotifier(video.url));
    if (downloadStatus == null) {
      print('is null somehow');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(video.name),
        Text((downloadStatus != null)
            ? downloadStatus.progress.toString()
            : 'Not downloaded'),
        Row(
          children: [
            if (downloadStatus?.status == DownloadTaskStatus.notstarted)
              IconButton(
                  onPressed: () async {
                    ref
                        .read(downloadFileStatusNotifierProvider.notifier)
                        .requestDownload(video.url);
                  },
                  icon: const Icon(Icons.download)),
            if (downloadStatus?.status == DownloadTaskStatus.complete)
              IconButton(
                  onPressed: () async {
                    final tasks =
                        await FlutterDownloaderService.getAllDownloadTasks();
                    for (var task in tasks) {
                      if (task.url == video.url) {
                        ref
                            .read(downloadFileStatusNotifierProvider.notifier)
                            .delete(task.id);
                      }
                    }
                  },
                  icon: const Icon(Icons.delete)),
          ],
        ),
      ],
    );
  }
}
