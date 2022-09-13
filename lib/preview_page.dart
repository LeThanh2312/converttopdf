import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.picture, }) : super(key: key);

  final List<XFile> picture;

  @override
  Widget build(BuildContext context) {
    print('==========${picture.length}');
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: picture.length == 2
          ?
        Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(picture[0].path), fit: BoxFit.cover, width: 100),
          Image.file(File(picture[1].path), fit: BoxFit.cover, width: 100),
        ])
           :
        Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(picture[0].path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          Text(picture[0].name),
        ])
      ),
    );
  }
}