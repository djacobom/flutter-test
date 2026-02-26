
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerService {
  final ImagePicker _picker = ImagePicker();

  // Store platform files for web access
  static Map<String, PlatformFile> webPlatformFiles = {};

  Future<List<File>> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'xml', 'gif'],
        withData: kIsWeb, // Load file data for web
      );

      if (result != null && result.files.isNotEmpty) {
        debugPrint('FilePicker result: ${result.files.length} files');

        if (kIsWeb) {
          // On web, store the platform files and create dummy File objects with names
          List<File> files = [];
          for (var platformFile in result.files) {
            if (platformFile.bytes != null && platformFile.name.isNotEmpty) {
              // Store the platform file for later access
              webPlatformFiles[platformFile.name] = platformFile;
              // Create a "file" using the name as path
              files.add(File(platformFile.name));
              debugPrint('Web file added: ${platformFile.name}');
            }
          }
          return files;
        } else {
          // On mobile, use file paths
          return result.files
              .where((file) => file.path != null)
              .map((file) {
                debugPrint('Mobile file added: ${file.path}');
                return File(file.path!);
              })
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }

    return [];
  }

  Future<File?> pickImageFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      return File(photo.path);
    } else {
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    } else {
      return null;
    }
  }
}
