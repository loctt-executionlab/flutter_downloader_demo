import 'package:flutter/material.dart';
import 'package:flutter_download_demo/views/progress_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Flutter download demo'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.download)),
            Tab(
              icon: Icon(Icons.file_present_outlined),
            )
          ]),
        ),
        body: const TabBarView(children: [
          ProgressTab(),
          ProgressTab(),
        ]),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(onPressed: () {
            }, child: const Icon(Icons.download)),
             FloatingActionButton(onPressed: () {
            }, child: const Icon(Icons.download)),
          ],
        ),
      ),
    
    );
  }
}
