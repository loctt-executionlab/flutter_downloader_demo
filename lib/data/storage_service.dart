
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StorageService {


  static Future<String> getStoragePath(String? folderStr) async {
    final folderPath = folderStr == null? '' : '/$folderStr';
    final String documentDir;
    try {
      if(Platform.isAndroid) {
      documentDir = (await getExternalStorageDirectory())!.absolute.path;
     } else {
      documentDir = (await getApplicationDocumentsDirectory()).absolute.path;
     }

     return documentDir + folderPath;

    } catch (e) {
      throw StorageException();
    }
  }
}

class StorageException implements Exception {
}