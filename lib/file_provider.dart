
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'file_picker_service.dart';

class FileProvider with ChangeNotifier {
  final List<File> _files = [];

  List<File> get files => _files;

  void addFile(File file) {
    _files.add(file);
    notifyListeners();
  }

  void addFiles(List<File> files) {
    _files.addAll(files);
    notifyListeners();
  }

  void removeFile(File file) {
    _files.remove(file);
    // Also remove from web platform files if on web
    if (kIsWeb) {
      FilePickerService.webPlatformFiles.remove(file.path);
    }
    notifyListeners();
  }

  void clearFiles() {
    _files.clear();
    // Also clear web platform files if on web
    if (kIsWeb) {
      FilePickerService.webPlatformFiles.clear();
    }
    notifyListeners();
  }
}
