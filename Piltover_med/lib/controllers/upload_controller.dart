import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/lab_report_model.dart';
import '../models/test_result_model.dart';

enum UploadStatus { idle, picking, processing, success, error }

class UploadController extends ChangeNotifier {
  UploadStatus _status = UploadStatus.idle;
  File? _selectedFile;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  String? _errorMessage;

  UploadStatus get status => _status;
  File? get selectedFile => _selectedFile;
  Uint8List? get selectedFileBytes => _selectedFileBytes;
  String? get selectedFileName => _selectedFileName;
  String? get errorMessage => _errorMessage;

  // Maximum file size: 10MB
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  // Allowed file types
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  /// Pick an image from gallery
  Future<File?> pickFromGallery() async {
    try {
      _status = UploadStatus.picking;
      _errorMessage = null;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _status = UploadStatus.idle;
        notifyListeners();
        return null;
      }

      final pickedFile = result.files.single;
      
      // Handle web platform - use bytes instead of path
      if (kIsWeb) {
        if (pickedFile.bytes == null) {
          _status = UploadStatus.error;
          _errorMessage = 'Failed to read file bytes';
          notifyListeners();
          return null;
        }
        
        _selectedFileBytes = pickedFile.bytes;
        _selectedFileName = pickedFile.name;
        _selectedFile = null; // File not available on web
        
        // Validate file size
        if (_selectedFileBytes!.length > maxFileSizeBytes) {
          _status = UploadStatus.error;
          _errorMessage = 'File size exceeds 10MB limit';
          _selectedFileBytes = null;
          _selectedFileName = null;
          notifyListeners();
          return null;
        }
        
        // Validate file extension
        final extension = _selectedFileName!.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(extension)) {
          _status = UploadStatus.error;
          _errorMessage = 'File type not supported. Use JPG, PNG, or PDF';
          _selectedFileBytes = null;
          _selectedFileName = null;
          notifyListeners();
          return null;
        }
        
        _status = UploadStatus.success;
        notifyListeners();
        return null; // Return null on web since File is not available
      } else {
        // Handle non-web platforms - use path
        if (pickedFile.path == null) {
          _status = UploadStatus.error;
          _errorMessage = 'Failed to get file path';
          notifyListeners();
          return null;
        }
        
        final file = File(pickedFile.path!);
        return _validateAndSetFile(file);
      }
    } catch (e) {
      _status = UploadStatus.error;
      _errorMessage = 'Failed to pick file: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Pick an image from camera (uses same picker with camera option)
  Future<File?> pickFromCamera() async {
    try {
      _status = UploadStatus.picking;
      _errorMessage = null;
      notifyListeners();

      // Note: For camera, you'd typically use image_picker package
      // But since we only have file_picker, we'll use the same method
      // In production, add image_picker package for proper camera support
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _status = UploadStatus.idle;
        notifyListeners();
        return null;
      }

      final pickedFile = result.files.single;
      
      // Handle web platform - use bytes instead of path
      if (kIsWeb) {
        if (pickedFile.bytes == null) {
          _status = UploadStatus.error;
          _errorMessage = 'Failed to read file bytes';
          notifyListeners();
          return null;
        }
        
        _selectedFileBytes = pickedFile.bytes;
        _selectedFileName = pickedFile.name;
        _selectedFile = null; // File not available on web
        
        // Validate file size
        if (_selectedFileBytes!.length > maxFileSizeBytes) {
          _status = UploadStatus.error;
          _errorMessage = 'File size exceeds 10MB limit';
          _selectedFileBytes = null;
          _selectedFileName = null;
          notifyListeners();
          return null;
        }
        
        _status = UploadStatus.success;
        notifyListeners();
        return null; // Return null on web since File is not available
      } else {
        // Handle non-web platforms - use path
        if (pickedFile.path == null) {
          _status = UploadStatus.error;
          _errorMessage = 'Failed to get file path';
          notifyListeners();
          return null;
        }
        
        final file = File(pickedFile.path!);
        return _validateAndSetFile(file);
      }
    } catch (e) {
      _status = UploadStatus.error;
      _errorMessage = 'Failed to capture photo: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Validate file and set if valid
  File? _validateAndSetFile(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      _status = UploadStatus.error;
      _errorMessage = 'File does not exist';
      notifyListeners();
      return null;
    }

    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > maxFileSizeBytes) {
      _status = UploadStatus.error;
      _errorMessage = 'File size exceeds 10MB limit';
      notifyListeners();
      return null;
    }

    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      _status = UploadStatus.error;
      _errorMessage = 'File type not supported. Use JPG, PNG, or PDF';
      notifyListeners();
      return null;
    }

    _selectedFile = file;
    _status = UploadStatus.success;
    notifyListeners();
    return file;
  }

  /// Create a mock lab report from uploaded file
  LabReport createMockReport(File file) {
    final fileName = file.path.split('/').last;
    final timestamp = DateTime.now();

    return LabReport(
      id: 'upload_${timestamp.millisecondsSinceEpoch}',
      patientName: 'Processing...', // Will be updated after AI analysis
      patientId: 'UPLOAD',
      reportDate: timestamp,
      testResults: [
        TestResult(
          testName: 'Report Analysis',
          value: 'Processing',
          unit: '',
          status: 'processing',
          date: timestamp,
        ),
      ],
      notes: 'Uploaded: $fileName - Analyzing with AI...',
    );
  }

  /// Reset controller state
  void reset() {
    _status = UploadStatus.idle;
    _selectedFile = null;
    _selectedFileBytes = null;
    _selectedFileName = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Get file size in human-readable format
  String getFileSizeString(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}