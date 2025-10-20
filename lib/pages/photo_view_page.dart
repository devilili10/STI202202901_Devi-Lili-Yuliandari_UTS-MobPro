import 'dart:io';
import 'package:flutter/material.dart';

class PhotoViewPage extends StatelessWidget {
  final String path;
  const PhotoViewPage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foto')),
      body: Center(child: Image.file(File(path))),
    );
  }
}
