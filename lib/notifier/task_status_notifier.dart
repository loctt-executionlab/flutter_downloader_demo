import 'package:flutter_download_demo/domain/models/download_task_model.dart';
import 'package:flutter_download_demo/notifier/download_file_status_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final taskStatusNotifier =
    StateProviderFamily<DownloadTaskModel?, String>((ref, url) {
  return ref.watch<DownloadTaskModel?>(
    downloadFileStatusNotifierProvider.select(
      (value) {
        final index = value.indexWhere((element) => element.url == url);
        if (index == -1) return null;
        return value[index];
      },
    ),
  );
});
