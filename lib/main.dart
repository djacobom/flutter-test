
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'file_provider.dart';
import 'file_picker_service.dart';
import 'upload_result_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FileProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-File Uploader',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  MediaType _getMediaType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'xml':
        return MediaType('application', 'xml');
      case 'txt':
        return MediaType('text', 'plain');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  Future<void> _uploadFiles(BuildContext context, List<File> files) async {
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select files to upload.')),
      );
      return;
    }

    var uri = Uri.parse('https://dev-gastos-de-viaje-635303073550.us-east4.run.app/process-documents');
    var request = http.MultipartRequest('POST', uri);

    for (var file in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path,
          contentType: _getMediaType(file.path),
        ),
      );
    }

    try {
      var response = await request.send();

      final respStr = await response.stream.bytesToString();
      // Log the response content
      debugPrint('Upload response: $respStr');

      if (context.mounted) {
        Provider.of<FileProvider>(context, listen: false).clearFiles();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UploadResultPage(jsonResponse: respStr),
          ),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Files uploaded successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload completed with status: ${response.statusCode}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      }
    }
    }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);
    final filePickerService = FilePickerService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-File Uploader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    var files = await filePickerService.pickFiles();
                    if (files.isNotEmpty) {
                      fileProvider.addFiles(files);
                    }
                  },
                  icon: const Icon(Icons.file_copy),
                  label: const Text('Select Files'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    var file = await filePickerService.pickImageFromCamera();
                    if (file != null) {
                      fileProvider.addFile(file);
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture Photo'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: fileProvider.files.length,
                itemBuilder: (context, index) {
                  File file = fileProvider.files[index];
                  bool isImage = ['.jpg', '.jpeg', '.png'].any((ext) => file.path.toLowerCase().endsWith(ext));

                  return Stack(
                    children: [
                      isImage
                          ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                          : Container(
                              alignment: Alignment.center,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.insert_drive_file, size: 40),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      file.path.split('/').last,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            fileProvider.removeFile(file);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _uploadFiles(context, fileProvider.files),
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload Files'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
