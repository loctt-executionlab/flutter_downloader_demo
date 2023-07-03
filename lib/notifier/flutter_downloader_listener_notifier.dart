import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_download_demo/data/flutter_downloader_service.dart';
import 'package:flutter_download_demo/domain/models/download_task_model.dart';
import 'package:flutter_downloader/flutter_downloader.dart' as downloader;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/subjects.dart';

part 'flutter_downloader_listener_notifier.g.dart';

@Riverpod(keepAlive: true)
class FlutterDownloaderListenerNotifier
    extends _$FlutterDownloaderListenerNotifier {
  static String portName = 'flutter_downloader_port';

  final ReceivePort _port = ReceivePort();

  final isolateSubject = PublishSubject<TaskStatus>();

  @override
  Stream<TaskStatus> build() {
    _bindCallback();
    ref.onDispose(() {
      isolateSubject.close();
      _unbindCallback();
    });
    return isolateSubject.stream;
  }

  void _bindCallback() {
    final bindSuccess =
        IsolateNameServer.registerPortWithName(_port.sendPort, portName);

    if (!bindSuccess) {
      _unbindCallback();
      _bindCallback();
      return;
    }
    downloader.FlutterDownloader.registerCallback(_downloadCallback, step: 1);
    _port.listen((data) {
      final taskId = (data as List<dynamic>)[0] as String;
      final status = downloader.DownloadTaskStatus(data[1] as int);
      final progress = data[2] as int;

      final task = TaskStatus(taskId, status.toStatus(), progress);
      isolateSubject.add(task);
    });
  }

  void _unbindCallback() {
    IsolateNameServer.removePortNameMapping(portName);
  }

  @pragma('vm:entry-point')
  static void _downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    IsolateNameServer.lookupPortByName(portName)
        ?.send([id, status, progress]);
  }
}

class TaskStatus {
  final String id;
  final DownloadTaskStatus status;
  final int progress;

  const TaskStatus(this.id, this.status, this.progress);

  @override
  String toString() => 'TaskStatus($id, $status, $progress)';
}
