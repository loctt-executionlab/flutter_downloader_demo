

import 'package:flutter_download_demo/domain/repositories/download_file_repository.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadFileRepositoryImpl implements DownloadFileRepository {

  @override
  void downloadItem(String url, String storagePath) {
    FlutterDownloader.enqueue(url: url, savedDir: storagePath);
  }

  @override
  void removeItemByPath(String storagePath) {
  }

  @override
  void removeItemByUrl(String url) {
    // TODO: implement removeItemByUrl
  }

}