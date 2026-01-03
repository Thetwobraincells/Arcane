import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/upload_controller.dart';
import '../../controllers/report_controller.dart';
import '../../utils/constants.dart';
import 'hover_button.dart';

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
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(AppConstants.hextechBlue).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
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
              color: Colors.white.withOpacity(0.3),
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
                    color: const Color(AppConstants.hextechBlue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    color: Color(AppConstants.hextechBlue),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Medical Report',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select a clear, well-lit document',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
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
              color: const Color(AppConstants.hextechBlue).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(AppConstants.hextechBlue).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: const Color(AppConstants.hextechBlue),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ensure report is clear and well-lit for best AI analysis results',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // File preview or upload options
          _hasFile
              ? _buildFilePreview()
              : _buildUploadOptions(),

          // File requirements
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Supported: JPG, PNG, PDF • Max size: 10MB',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
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
            subtitle: 'Select existing photo or PDF',
            onTap: () => _handleGalleryPick(),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.camera_alt_outlined,
            title: 'Take Photo',
            subtitle: 'Capture report with camera',
            onTap: () => _handleCameraPick(),
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Upload PDF',
            subtitle: 'Select PDF document',
            onTap: () => _handlePdfPick(),
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
    return _HoverableOptionButton(
      onTap: _isProcessing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(AppConstants.hextechBlue).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(AppConstants.hextechBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(AppConstants.hextechBlue),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    final uploadController = context.read<UploadController>();
    
    // Get file info - handle both web (bytes) and non-web (File)
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
          // File preview card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(AppConstants.hextechBlue).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                // Image preview or file icon
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb && _selectedFileBytes != null
                        ? Image.memory(
                            _selectedFileBytes!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : _selectedFile != null
                            ? Image.file(
                                _selectedFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox.shrink(),
                  )
                else
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.hextechBlue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 60,
                        color: Color(AppConstants.hextechBlue),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            fileSize,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
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
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Analyze button with hover effect
          SizedBox(
            width: double.infinity,
            height: 50,
            child: HoverButton(
              onPressed: _isProcessing ? null : _handleAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.hextechBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.psychology, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Analyze Report',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
        // On web, use bytes instead of File
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
        // On web, use bytes instead of File
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
    final file = await uploadController.pickFromGallery(); // Same as gallery for now
    
    setState(() {
      if (kIsWeb) {
        // On web, use bytes instead of File
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
      // 1. Get the Controller
      final reportController = context.read<ReportController>();

      // 2. Close the Modal FIRST (so the loading spinner appears on the main screen/button)
      Navigator.of(context).pop();

      // 3. Call the REAL AI Logic
      // Pass the selected file/bytes and context with file name for mime type detection
      String? fileName;
      if (kIsWeb && _selectedFileBytes != null) {
        fileName = _selectedFileName;
        await reportController.analyzeFile(_selectedFileBytes!, context, fileName: fileName);
      } else if (_selectedFile != null) {
        fileName = _selectedFile!.path.split('/').last;
        await reportController.analyzeFile(_selectedFile!, context, fileName: fileName);
      }

    } catch (e) {
      // Error handling is done inside the controller now, 
      // but strictly for the modal closing logic:
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// Hoverable wrapper for option buttons
class _HoverableOptionButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _HoverableOptionButton({
    required this.onTap,
    required this.child,
  });

  @override
  State<_HoverableOptionButton> createState() => _HoverableOptionButtonState();
}

class _HoverableOptionButtonState extends State<_HoverableOptionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Helper function to show upload modal
void showUploadModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const UploadModal(),
  );
}
