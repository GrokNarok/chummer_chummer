import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class FilePathAndContent {
  final String? path;
  final String content;

  FilePathAndContent(this.path, this.content);
}

abstract class FileService {
  Future<FilePathAndContent?> open();
}

class FileServiceConnected extends FileService {
  @override
  Future<FilePathAndContent?> open() async {
    FilePickerResult? result;
    if (kIsWeb) {
      result = await FilePicker.platform.pickFiles();
      return (result != null)
          ? FilePathAndContent(
              null, // file path is not available on the web
              utf8.decode(result.files.single.bytes!),
            )
          : null;
    } else {
      // Windows lets you restrict to '.chum5' files, android doesn't, need to check others.
      if (Platform.isWindows) {
        result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['chum5']);
      } else {
        result = await FilePicker.platform.pickFiles();
      }

      return (result != null)
          ? FilePathAndContent(
              result.files.single.path,
              await File(result.files.single.path!).readAsString(),
            )
          : null;
    }
  }
}

class FileServiceDisconnected extends FileService {
  @override
  Future<FilePathAndContent?> open() async {
    final file = File("test/data/test_character.chum5");
    return FilePathAndContent(file.path, await file.readAsString());
  }
}
