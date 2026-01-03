import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/upload_controller.dart';
import '../../controllers/report_controller.dart';
import '../../utils/constants.dart';

class UploadModal extends StatefulWidget {
  const UploadModal({super.key});

  @override
  State<UploadModal> createState() => _UploadModalState();
}

class _UploadModalState extends State<UploadModal> {
  File? _selectedFile;
  bool _isProcessing = false;

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
          _selectedFile != null
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
    return InkWell(
      onTap: _isProcessing ? null : onTap,
      borderRadius: BorderRadius.circular(12),
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
    final fileSize = uploadController.getFileSizeString(_selectedFile!);
    final fileName = _selectedFile!.path.split('/').last;
    final isImage = fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png');

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
                    child: Image.file(
                      _selectedFile!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
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
          // Analyze button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
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
    
    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
    } else if (uploadController.errorMessage != null) {
      _showError(uploadController.errorMessage!);
    }
  }

  Future<void> _handleCameraPick() async {
    final uploadController = context.read<UploadController>();
    final file = await uploadController.pickFromCamera();
    
    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
    } else if (uploadController.errorMessage != null) {
      _showError(uploadController.errorMessage!);
    }
  }

  Future<void> _handlePdfPick() async {
    final uploadController = context.read<UploadController>();
    final file = await uploadController.pickFromGallery(); // Same as gallery for now
    
    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
    } else if (uploadController.errorMessage != null) {
      _showError(uploadController.errorMessage!);
    }
  }

  Future<void> _handleAnalyze() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final uploadController = context.read<UploadController>();
      final reportController = context.read<ReportController>();

      // Create mock report with processing status
      final mockReport = uploadController.createMockReport(_selectedFile!);

      // Add to report controller
      reportController.addReport(mockReport);

      // Simulate processing delay (in real app, this would be AI analysis)
      await Future.delayed(const Duration(milliseconds: 500));

      // Close modal
      if (mounted) {
        Navigator.of(context).pop();

        // Navigate to Reports screen (index 1 in bottom nav)
        // This will be handled by the parent scaffold
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Report uploaded successfully! AI analysis in progress...',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to process report: ${e.toString()}');
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