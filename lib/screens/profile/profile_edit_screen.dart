import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/profile_input_field.dart';
import '../../services/storage_service.dart';
import '../../services/user_service.dart';
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
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'kanikalansooriya');
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
    
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      String? photoUrl;
      if (_imageFile != null) {
        photoUrl = await _storageService.uploadProfileImage(user.uid, _imageFile!);
      }

      await _userService.saveUserProfile(user.copyWith(
        displayName: _nameController.text,
        bio: _bioController.text,
        photoURL: photoUrl ?? user.photoURL,
      ));
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
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
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          if (user == null) return const Center(child: Text('Please login'));

          return StreamBuilder<UserModel?>(
            stream: _userService.getUserProfileStream(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final profile = snapshot.data!;
                // Initialize controllers only once
                if (_nameController.text == 'kanikalansooriya') {
                  _nameController.text = profile.displayName;
                  _bioController.text = profile.bio;
                }
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppTheme.bgLight,
                                backgroundImage: _imageFile != null 
                                    ? FileImage(_imageFile!) 
                                    : (snapshot.data?.photoURL != null 
                                        ? NetworkImage(snapshot.data!.photoURL) 
                                        : null) as ImageProvider?,
                                child: (_imageFile == null && snapshot.data?.photoURL == null) 
                                    ? const Icon(Icons.person_rounded, size: 50, color: AppTheme.textSecondary) 
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
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
              );
            },
          );
        },
      ),
    );
  }
}
