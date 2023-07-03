### Author:  [XuanBach](mailto:bach.vo@executionlab.asia) + [LocTran](mailto:loc.tran@executionlab.asia)
Last updated: 28 Jul 2023

# BACKGROUND DOWNLOAD IN FLUTTER <!-- omit from toc -->


**Table of content**
- [Preface](#preface)
  - ["Naive" approcach](#naive-approcach)
  - [Using packages](#using-packages)
  - [Things to consider](#things-to-consider)
- [flutter\_downloader](#flutter_downloader)
  - [Getting started](#getting-started)
  - [API usage](#api-usage)
- [Architecture with Riverpod](#architecture-with-riverpod)
- [Alternative \[WIP\]](#alternative-wip)

## TODO <!-- omit from toc -->
Will delete when done

- [x] Introduction
- [x] Package introduction
- [x] Api usage
- [x] Architecture
- [ ] Alternative
- [ ] Code demo

## Preface

Bài viết này để chia sẻ cách download file ở Android & iOS thông qua thư viện của Flutter. Trong bài viết này sẽ sử dụng thư viện flutter_downloader và al_downloader, cả hai thư viện này cung cấp những API cần thiết để sử lý công việc tải file trên cả hai nền tảng Android và iOS, cho phép người dùng sử dụng trực tiếp mà không cần (quá nhiều) kiến thức về Native Development.

### "Naive" approcach


Ta có thể dùng `HttpClient` để download bằng cách mở http connection để lấy được data stream, rồi convert data stream đó thành định dạng mong muốn (dưới đây là string) rồi đổ vào file để lưu vào bộ nhớ. 

```dart
var client = HttpClient();
try {
    HttpClientRequest request = await client.get('localhost', 80, '/file.txt');
    // Optionally set up headers...
    // Optionally write to the request object...
    HttpClientResponse response = await request.close();
    // Process the response
    final stringData = await response.transform(utf8.decoder).join();
    print(stringData);
} finally {
    client.close();
}

```

Dùng `Dio` có api riêng để hỗ trợ download, mình khai báo download path thì dio sẽ download vào file đó, ngoài ra còn có thể thêm callback để update sự kiện :
```dart
var dio = Dio();
dio.download('uri', 'download path', onReceiveProgress: (count, total) {
    //callback whenever progress change
},);
```

### Using packages
>\- vậy tại sao lại cần thư viện để download?

Vì một trong những requirement thiết yếu khi download với thiết bị di động là chạy background. Với phương pháp trên, nếu code được chạy trên main thread thì sẽ bị dừng ngay khi app bị đưa vào background. Ngay cả khi spawn isolate riêng để chạy download ngầm thì hệ điệu hành mobile sẽ tự động tối ưu gây đóng thread bất kì lúc nào. Để khắc phục thì code sử dụng package `workmanager` cung cấp các api để khởi tạo  background task cho các nền tảng native tương ứng, sau đó implement chức năng download task để chạy ngầm, nói chung là khó, và flutter có nhiều package có sẵn để xử lý download nên không cần phải như thế.

### Things to consider

**Device storage**

Dùng package path_provider để gọi APIs của native platform để lấy path storage lúc download. IOS cho phép người dùng truy cập storage thoải mái, còn Android thì một số quyền truy cập storage cần phải được cấp quyền trước. 

Tham khảo thêm về data storage của Android tại [đây](https://developer.android.com/training/data-storage)



## flutter_downloader

[flutter_downloader](https://pub.dev/packages/flutter_downloader) *Version: 1.10.2*

flutter_downloader là package download được nhiều người sử dụng nhất trên pub.dev (1000+ likes), tuy nhiên hiện tại đã bị discontinued. Dù vậy, (theo tìm hiểu) thì các package khác cũng có cơ chế rất giống nhau, nên kinh nghiệm sử dụng flutter_downloader vẫn có ích trong tương lai :D

### Getting started

Cơ chế của flutter_downloader là khi khởi tạo tiến trình download, package sẽ tạo task tương ứng bằng code native tuỳ vào platform, và thêm info của download task đó vào sqllite của package để hỗ trợ các thao tác sau này, ví dụ như trạng thái download, url hay path trên device,... 

Package  Vì tác vụ download này được thực thi biệt lập qua background isolate, nên mình cần thêm `SendPort` cho nó để có thể liên lạc được giữa thread download và main thread qua port này.

Mình sẽ lược qua các bước setup package, vì docs của từng package rất chi tiết rõ ràng.

### API usage

Đầu tiên chạy hàm initialize trước khi `runApp()`

```dart
import 'package:flutter_downloader/flutter_downloader.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();

    // Plugin must be initialized before using
    await FlutterDownloader.initialize(
    debug: true, // optional: set to false to disable printing logs to console (default: true)
    ignoreSsl: true // option: set to false to disable working with http links (default: false)
    );

    runApp(/*...*/)
}
```

## Architecture with Riverpod

Download sử dụng flutter_downloader và flutter_riverpod 

Ý tưởng là mình sẽ có một class để bắt data trả về từ isolate download status, trả data đó ra thông qua stream, Một class Controller listen đến stream đó để update data, đồng thời expose các method request download, delete, ... để UI sử dụng.

**CODE**

Đây là model của download task. Mỗi entity thể hiện một file được download, có thể thêm các thuộc tính khác tuỳ thuộc vào business. Dùng freezed để không cần viết boilerplate.
```dart
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
```

Class `FlutterDownloaderService` có hàm query các task download từ sql của thư viện giúp init data cho provider, thêm extension của các class thư viện để convert thành object model như trên.

```dart
import 'package:flutter_downloader/flutter_downloader.dart' as downloader;

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
        path: savedDir,
        status: status.toStatus(),
    );
    }
}
```

Class `FlutterDownloaderListenerNotifier` sẽ handle việc binding callback với background download isolate. Ở đây sử dụng `ReceivePort` để giao tiếp giữa isolate này với main isolate như đã nói ở trên. Callback download sẽ lookup port tương ứng để trả về data thông qua port đó. Tiếp đó object này chỉ cần listen data từ port đó data trả về để emit lại qua stream (trong trường hợp này convert data primitive thành `DownloadTaskStatus`).

**Important:** `registercallback` tuỳ vào version của package sẽ yêu cầu param status là  `int` hoặc  `DownloadTaskStatus`, đọc implementation để biết số nào ứng với status nào lol.

```dart
import 'package:flutter_downloader/flutter_downloader.dart' as downloader;

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
```

`DownloadFileStatusNotifier` trong initialization sẽ query các task donwload ban đầu, và subscribe stream data trả về từ `FlutterDownloaderListenerNotifier` để update data ban đầu đó ứng với status trả về từ stream, đồng thời class này expose method để UI gọi download, delete, pause, etc.

```dart
import 'package:flutter_downloader/flutter_downloader.dart' as downloader;

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
    /// ...
}
```

## Alternative [WIP]

Do package này đã discontinued do thiếu người maintain (Jun 2023), nên trong tương lai không xài được. Nhưng hiện tại cũng đã có nhiều lựa chọn khác thay thế:

- [background_downloader](https://pub.dev/packages/background_downloader) : theo quảng cáo thì xịn hơn flutter_downloader, stable hơn.
- [al_downloader](https://pub.dev/packages/al_downloader) : tương tự

