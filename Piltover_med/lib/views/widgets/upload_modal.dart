import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/upload_controller.dart';
import '../../controllers/report_controller.dart';

class UploadModal extends StatefulWidget {
  const UploadModal({super.key});

  @override
  State<UploadModal> createState() => _UploadModalState();
}

class _UploadModalState extends State<UploadModal> {
  File? _selectedFile;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  bool _isProcessing = false;
  
  bool get _hasFile => _selectedFile != null || _selectedFileBytes != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    color: Color(0xFF0EA5E9),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Medical Report',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Select a clear, readable document',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Helper text
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF0EA5E9),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ensure text is clear and well-lit for best results',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // File preview or upload options
          _hasFile ? _buildFilePreview() : _buildUploadOptions(),

          // File requirements
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Supported: JPG, PNG, PDF • Max: 10MB',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildOptionButton(
            icon: Icons.photo_library_outlined,
            title: 'Choose from Gallery',
            subtitle: 'Select photo or PDF',
            onTap: _handleGalleryPick,
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.camera_alt_outlined,
            title: 'Take Photo',
            subtitle: 'Capture with camera',
            onTap: _handleCameraPick,
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Upload PDF',
            subtitle: 'Select PDF document',
            onTap: _handlePdfPick,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isProcessing ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF0EA5E9), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    final uploadController = context.read<UploadController>();
    
    String fileName;
    String fileSize;
    bool isImage;
    
    if (kIsWeb && _selectedFileBytes != null) {
      fileName = _selectedFileName ?? 'selected_file';
      fileSize = _formatBytes(_selectedFileBytes!.length);
      isImage = fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg') ||
          fileName.toLowerCase().endsWith('.png');
    } else if (_selectedFile != null) {
      fileName = _selectedFile!.path.split('/').last;
      fileSize = uploadController.getFileSizeString(_selectedFile!);
      isImage = fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg') ||
          fileName.toLowerCase().endsWith('.png');
    } else {
      fileName = 'Unknown';
      fileSize = '0 B';
      isImage = false;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb && _selectedFileBytes != null
                        ? Image.memory(_selectedFileBytes!, height: 200, width: double.infinity, fit: BoxFit.cover)
                        : _selectedFile != null
                            ? Image.file(_selectedFile!, height: 200, width: double.infinity, fit: BoxFit.cover)
                            : const SizedBox.shrink(),
                  )
                else
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.picture_as_pdf, size: 60, color: Color(0xFF0EA5E9)),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            fileSize,
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _isProcessing ? null : () {
                        setState(() {
                          _selectedFile = null;
                          _selectedFileBytes = null;
                          _selectedFileName = null;
                        });
                        uploadController.reset();
                      },
                      icon: const Icon(Icons.close, size: 20),
                      color: const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.psychology, size: 20),
                        const SizedBox(width: 8),
                        Text('Analyze Report', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGalleryPick() async {
    final uploadController = context.read<UploadController>();
    final file = await uploadController.pickFromGallery();
    
    setState(() {
      if (kIsWeb) {
        _selectedFileBytes = uploadController.selectedFileBytes;
        _selectedFileName = uploadController.selectedFileName;
        _selectedFile = null;
      } else {
        _selectedFile = file;
        _selectedFileBytes = null;
        _selectedFileName = null;
      }
    });
    
    if (!_hasFile && uploadController.errorMessage != null) {
      _showError(uploadController.errorMessage!);
    }
  }

  Future<void> _handleCameraPick() async {
    final uploadController = context.read<UploadController>();
    final file = await uploadController.pickFromCamera();
    
    setState(() {
      if (kIsWeb) {
        _selectedFileBytes = uploadController.selectedFileBytes;
        _selectedFileName = uploadController.selectedFileName;
        _selectedFile = null;
      } else {
        _selectedFile = file;
        _selectedFileBytes = null;
        _selectedFileName = null;
      }
    });
    
    if (!_hasFile && uploadController.errorMessage != null) {
      _showError(uploadController.errorMessage!);
    }
  }

  Future<void> _handlePdfPick() async {
    final uploadController = context.read<UploadController>();
    final file = await uploadController.pickFromGallery();
    
    setState(() {
      if (kIsWeb) {
        _selectedFileBytes = uploadController.selectedFileBytes;
        _selectedFileName = uploadController.selectedFileName;
        _selectedFile = null;
      } else {
        _selectedFile = file;
        _selectedFileBytes = null;
        _selectedFileName = null;
      }
    });
    
    if (!_hasFile && uploadController.errorMessage != null) {
      _showError(uploadController.errorMessage!);
    }
  }

  Future<void> _handleAnalyze() async {
    if (!_hasFile) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final reportController = context.read<ReportController>();
      Navigator.of(context).pop();

      String? fileName;
      if (kIsWeb && _selectedFileBytes != null) {
        fileName = _selectedFileName;
        await reportController.analyzeFile(_selectedFileBytes!, context, fileName: fileName);
      } else if (_selectedFile != null) {
        fileName = _selectedFile!.path.split('/').last;
        await reportController.analyzeFile(_selectedFile!, context, fileName: fileName);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to start analysis: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

void showUploadModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const UploadModal(),
  );
}