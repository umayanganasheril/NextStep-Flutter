import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'evaluation_result_screen.dart';

class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  int _currentQuestionIndex = 0;
  int _secondsRemaining = 1800; // 30 minutes
  Timer? _timer;
  bool _isInterviewActive = false;
  final _aiService = AIService();

  final List<String> _questions = [
    'Tell us about yourself and your background in software development.',
    'What is your experience with Flutter and state management?',
    'How do you handle difficult technical challenges in a team environment?',
    'Where do you see yourself in the next five years of your career?',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startInterview() {
    setState(() {
      _isInterviewActive = true;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _finishInterview();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _finishInterview();
    }
  }

  void _finishInterview() async {
    _timer?.cancel();
    
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await _aiService.saveInterviewSession(user.uid, {
        'score': 85,
        'durationSeconds': 1800 - _secondsRemaining,
        'completedQuestions': _currentQuestionIndex + 1,
      });
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EvaluationResultScreen()),
      );
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Mock Interview', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        actions: [
          if (_isInterviewActive)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  _formatTime(_secondsRemaining),
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining < 300 ? Colors.red : AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isInterviewActive ? _buildInterviewBody() : _buildStartBody(),
    );
  }

  Widget _buildStartBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded, size: 80, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 32),
            Text(
              'Ready for your Interview?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'This session will last 30 minutes and cover 4 core technical and behavioral questions.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _startInterview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Start Interview Session', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewBody() {
    double progress = (_currentQuestionIndex + 1) / _questions.length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _questions[_currentQuestionIndex],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 32),
                const Icon(Icons.mic_none_rounded, size: 40, color: AppTheme.primaryBlue),
                const SizedBox(height: 12),
                Text('AI is listening...', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                _currentQuestionIndex < _questions.length - 1 ? 'Next Question' : 'Finish Interview',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
