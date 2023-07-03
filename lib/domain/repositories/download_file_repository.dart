
abstract class DownloadFileRepository {
  void downloadItem(String url, String storagePath);
  void removeItemByUrl(String url);
  void removeItemByPath(String storagePath);
}
