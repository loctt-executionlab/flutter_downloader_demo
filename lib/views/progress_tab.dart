import 'package:flutter/material.dart';
import 'package:flutter_download_demo/views/task_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ProgressTab extends ConsumerWidget {
const ProgressTab({ Key? key }) : super(key: key);


  @override
  Widget build(BuildContext context, WidgetRef ref){
    return ListView(
      children: videoList.map((e) => TaskEntry(video: e,)).toList(),
        );
  }
}



class DownloadVideo {
  final String name;
  final String url;

  const DownloadVideo({required this.name, required this.url});
}


final videoList = [
      const DownloadVideo(
          name: 'Big Buck bunny',
          url:
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
      const DownloadVideo(
          name: 'The first Blender Open Movie from 2006',
          url:
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'),
      const DownloadVideo(
          name: 'Sintel - an independently produced short film',
          url:
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'),
    ];
