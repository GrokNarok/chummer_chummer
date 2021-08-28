import 'dart:io';

import 'package:file_picker/file_picker.dart';

abstract class FileService {
  Future<File?> open();
}

class FileServiceConnected extends FileService {
  @override
  Future<File?> open() async {
    FilePickerResult? result;
    // Windows lets you restrict to '.chum5' files, android doesn't, need to check others.
    if (Platform.isWindows) {
      result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['chum5']);
    } else {
      result = await FilePicker.platform.pickFiles();
    }
    return (result != null) ? File(result.files.single.path!) : null;
  }
}

class FileServiceDisconnected extends FileService {
  @override
  Future<File?> open() async {
    return File("test/data/test_character.chum5");
  }
}
