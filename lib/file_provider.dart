
import 'dart:io';
import 'package:flutter/foundation.dart';

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
    notifyListeners();
  }

  void clearFiles() {
    _files.clear();
    notifyListeners();
  }
}
