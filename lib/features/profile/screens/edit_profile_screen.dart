import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../../core/services/image_service.dart';
import '../providers/profile_provider.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _ageController = TextEditingController();
  final _imageService = ImageService.getInstance();
  
  String? _selectedGender;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Load current user data
    final user = context.read<ProfileProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
      _ageController.text = user.age?.toString() ?? '';
      _selectedGender = user.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await _imageService.pickImage(source);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final profileProvider = context.read<ProfileProvider>();

      // Upload photo if selected
      if (_selectedImage != null) {
        final photoSuccess = await profileProvider.uploadProfilePhoto(_selectedImage!);
        if (!photoSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload photo'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Update profile
      final success = await profileProvider.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        gender: _selectedGender,
        age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileProvider.error ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final user = profileProvider.user;
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Photo
                    Stack(
                      children: [
                        _selectedImage != null
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage: FileImage(_selectedImage!),
                              )
                            : ProfileAvatar(
                                imageUrl: user?.profilePhoto,
                                size: 120,
                              ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Name Field
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      prefixIcon: Icons.person_outline,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 20),
                    
                    // Bio Field
                    CustomTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Tell us about yourself',
                      maxLines: 3,
                      prefixIcon: Icons.info_outline,
                    ),
                    const SizedBox(height: 20),
                    
                    // Gender Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gender (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            hintText: 'Select gender',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Age Field
                    CustomTextField(
                      controller: _ageController,
                      label: 'Age (Optional)',
                      hint: 'Enter your age',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.cake_outlined,
                      validator: Validators.validateAge,
                    ),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _handleSave,
                      isLoading: profileProvider.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
