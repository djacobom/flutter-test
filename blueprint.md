
# Project Blueprint

## Overview

This document outlines the plan for creating a multi-file uploader Flutter application. The application will allow users to select multiple files from their device storage or capture new photos with the camera, preview the selected files, and upload them to a server.

## Features

*   **File Selection**: Users can select multiple files of any type from their device storage.
*   **Camera Capture**: Users can capture new photos using the device's camera.
*   **File Preview**: A preview of selected images is displayed in a grid view. Non-image files are represented by a generic icon and filename.
*   **Remove Files**: Users can remove a file from the selection before uploading.
*   **State Management**: The `provider` package will be used to manage the state of the selected files.
*   **Modern UI**: The app will have a modern user interface with a purple and white color scheme, using the `google_fonts` package for typography.
*   **File Upload**: The selected files will be sent as a multipart form data request to a specified API endpoint using the `http` package.

## Plan

1.  **Add Dependencies**: Add `image_picker`, `file_picker`, `http`, `provider`, and `google_fonts` to the `pubspec.yaml` file.
2.  **Update `main.dart`**:
    *   Set up `ChangeNotifierProvider` for state management.
    *   Define a custom theme with a purple and white color scheme.
    *   Create the main application widget and home screen.
3.  **Create `file_provider.dart`**: A `ChangeNotifier` class to manage the list of selected files.
4.  **Create `file_picker_service.dart`**: A service class to handle file and image selection using the `file_picker` and `image_picker` packages.
5.  **Create the UI**:
    *   Implement a home screen with a `Scaffold`.
    *   Add buttons to trigger file selection and image capture.
    *   Display selected files in a `GridView`.
    *   Add a button to each file preview to allow for removal.
    *   Add an "Upload" button to initiate the file upload process.
6.  **Implement File Upload**: Create a service that takes the list of files and sends them to a predefined API endpoint as a multipart request.
