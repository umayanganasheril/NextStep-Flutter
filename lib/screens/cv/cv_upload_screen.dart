import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../services/storage_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../services/ai_service.dart';
import 'evaluation_result_screen.dart';

class CvUploadScreen extends StatefulWidget {
  const CvUploadScreen({super.key});

  @override
  State<CvUploadScreen> createState() => _CvUploadScreenState();
}

class _CvUploadScreenState extends State<CvUploadScreen>
    with SingleTickerProviderStateMixin {
  bool _isUploading = false;
  String _loadingText = 'Uploading...';
  late AnimationController _animController;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // For text extraction, restrict to PDF
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);
        
        final file = File(result.files.single.path!);
        if (!mounted) return;
        final auth = context.read<AuthProvider>();
        final user = auth.user;
        
        if (user != null) {
          // Mock upload for both authenticated users and guests (to bypass Firebase Storage billing requirement)
          setState(() {
            _isUploading = true;
            _loadingText = 'Extracting text...';
          });
          
          String extractedText = '';
          try {
            // Extract text from the PDF locally!
            final bytes = await file.readAsBytes();
            final PdfDocument document = PdfDocument(inputBytes: bytes);
            final PdfTextExtractor extractor = PdfTextExtractor(document);
            extractedText = extractor.extractText();
            document.dispose();
            print("Extracted ${extractedText.length} characters from PDF");
          } catch (e) {
            print("Error extracting PDF text: $e");
          }

          // Save the file permanently to local storage so we can preview it later
          final appDocDir = await getApplicationDocumentsDirectory();
          final fileName = result.files.single.name;
          final localPath = '${appDocDir.path}/$fileName';
          await file.copy(localPath);

          setState(() {
            _loadingText = 'Analyzing CV with AI...';
          });
          
          final insights = await AIService.generateCareerInsights(extractedText);
          final fileSize = await file.length();
          
          await auth.updateUser(user.copyWith(
            cvUrl: localPath, // Save the actual local path
            cvText: extractedText,
            cvFileName: fileName,
            cvUploadDate: DateTime.now(),
            cvFileSize: fileSize,
            aiEvaluationScore: insights?['evaluationScore']?.toDouble(),
            aiEvaluationSummary: insights?['evaluationSummary'],
            aiSuggestions: insights?['suggestions'],
            aiCareerPaths: insights?['careerPaths'],
            technicalSkills: insights?['extractedSkills'] != null 
                ? List<String>.from(insights!['extractedSkills']) 
                : user.technicalSkills,
            aiRecommendedInternships: insights?['recommendedInternships'],
          ));
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resume uploaded and analyzed successfully!', style: GoogleFonts.inter()),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('Error selecting file: $e', style: GoogleFonts.inter()), 
           backgroundColor: AppTheme.error,
           behavior: SnackBarBehavior.floating,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
         ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final hasCv = user != null && user.cvUrl != null && user.cvUrl!.isNotEmpty;

        return Scaffold(
          backgroundColor: AppTheme.bgLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Upload Resume',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: FadeTransition(
            opacity: _animController,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keep your resume up to date',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Current file info
                  if (hasCv)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.picture_as_pdf,
                                    color: AppTheme.error, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.cvFileName ?? 'Resume.pdf',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatDate(user.cvUploadDate)} • ${_formatSize(user.cvFileSize)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Active',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                if (user.cvUrl != null && user.cvUrl!.isNotEmpty) {
                                  // Open the PDF file directly
                                  final result = await OpenFilex.open(user.cvUrl!);
                                  if (result.type != ResultType.done && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Could not open PDF. Please upload it again.',
                                            style: GoogleFonts.inter()),
                                        backgroundColor: AppTheme.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No PDF file available to preview.',
                                          style: GoogleFonts.inter()),
                                      backgroundColor: AppTheme.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.visibility_outlined,
                                  size: 18),
                              label: Text('Preview Current CV',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                                side: const BorderSide(
                                    color: AppTheme.primaryBlue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Upload area
                  GestureDetector(
                    onTap: _isUploading ? null : _handleUpload,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isUploading
                              ? AppTheme.primaryBlue
                              : const Color(0xFFE5E7EB),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          if (_isUploading)
                            const SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: AppTheme.primaryBlue,
                              ),
                            )
                          else
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primaryBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                size: 36,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            _isUploading
                                ? _loadingText
                                : 'Tap to upload new version',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Supports PDF, DOC, DOCX • Max 5MB',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _handleUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor:
                            AppTheme.primaryBlue.withValues(alpha: 0.4),
                      ),
                      child: Text(
                        hasCv ? 'Update Resume' : 'Upload Resume',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (user != null && user.aiEvaluationScore != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EvaluationResultScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'View ATS Results',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Tips
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.info.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tips_and_updates_outlined,
                                size: 18, color: AppTheme.info),
                            const SizedBox(width: 8),
                            Text(
                              'Resume Tips',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _tipItem('Keep it to 1-2 pages'),
                        _tipItem('Use action verbs (Developed, Led, Designed)'),
                        _tipItem('Include relevant projects and skills'),
                        _tipItem('Proofread for typos and errors'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 16, color: AppTheme.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return 'Unknown';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(0)}KB';
    return '${(bytes / 1048576).toStringAsFixed(1)}MB';
  }
}
