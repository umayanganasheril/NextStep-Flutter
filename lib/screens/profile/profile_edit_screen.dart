import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/profile_input_field.dart';
import '../../services/storage_service.dart';
import '../../services/profile_service.dart';
import '../../providers/auth_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isSaving = false;
  File? _imageFile;
  final _picker = ImagePicker();
  final _storageService = StorageService();
  final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Kanikalansooriya');
    _bioController = TextEditingController(text: 'CS Student | Flutter Enthusiast');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await _storageService.uploadProfilePicture(_imageFile!, user.uid);
    }

    final updatedUser = user.copyWith(
      name: _nameController.text,
      bio: _bioController.text,
      profilePictureUrl: imageUrl ?? user.profilePictureUrl,
    );

    try {
      await _profileService.updateProfile(updatedUser);
      auth.updateUser(updatedUser);
      
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile synced with cloud successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sync profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            IconButton(onPressed: _saveProfile, icon: const Icon(Icons.check_rounded)),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null ? const Icon(Icons.person, size: 50, color: AppTheme.primaryBlue) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ProfileInputField(
                  label: 'Full Name',
                  controller: _nameController,
                  hintText: 'Enter your name',
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 20),
                ProfileInputField(
                  label: 'Bio',
                  controller: _bioController,
                  maxLines: 3,
                  hintText: 'Tell us about yourself',
                  validator: (val) => val != null && val.length > 100 ? 'Bio is too long' : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
