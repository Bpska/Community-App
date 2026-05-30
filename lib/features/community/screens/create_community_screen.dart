import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/services/image_service.dart';
import '../../../core/services/location_service.dart';
import '../providers/community_provider.dart';
import '../../../core/config/theme_config.dart';
import 'dart:io';

import '../../auth/providers/auth_provider.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageService = ImageService.getInstance();
  
  String? _selectedCategory;
  String _communityType = 'public';
  double _radius = 2.0;
  File? _logoImage;
  File? _coverImage;

  final List<String> _categories = [
    'Sports',
    'Technology',
    'Music',
    'Art',
    'Food',
    'Travel',
    'Business',
    'Education',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final source = await _showImageSourceDialog();
    if (source != null) {
      final image = await _imageService.pickImage(source);
      if (image != null) {
        setState(() {
          _logoImage = image;
        });
      }
    }
  }

  Future<void> _pickCover() async {
    final source = await _showImageSourceDialog();
    if (source != null) {
      final image = await _imageService.pickImage(source);
      if (image != null) {
        setState(() {
          _coverImage = image;
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showModalBottomSheet<ImageSource>(
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
  }

  Future<void> _handleCreate() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Capture user location for map pin
      final locationService = LocationService.getInstance();
      final position = await locationService.getCurrentPosition();
      final currentUser = context.read<AuthProvider>().currentUser;

      final communityProvider = context.read<CommunityProvider>();
      final success = await communityProvider.createCommunity(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        type: _communityType,
        radius: _radius,
        latitude: position?.latitude ?? currentUser?.latitude,
        longitude: position?.longitude ?? currentUser?.longitude,
        logo: _logoImage,
        cover: _coverImage,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Community created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create community'),
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
        title: const Text('Create Community'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                GestureDetector(
                  onTap: _pickCover,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: NearMeColors.navyCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: NearMeColors.navyBorder, width: 1.5),
                      image: _coverImage != null
                          ? DecorationImage(
                              image: FileImage(_coverImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _coverImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, size: 40, color: NearMeColors.gold),
                              SizedBox(height: 8),
                              Text(
                                'Add Cover Image',
                                style: TextStyle(color: NearMeColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Logo Image
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickLogo,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: NearMeColors.navyCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: NearMeColors.navyBorder, width: 1.5),
                          image: _logoImage != null
                              ? DecorationImage(
                                  image: FileImage(_logoImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _logoImage == null
                            ? const Icon(Icons.add_a_photo_rounded, size: 28, color: NearMeColors.gold)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Add Logo Image',
                        style: TextStyle(fontSize: 14, color: NearMeColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Name Field
                CustomTextField(
                  controller: _nameController,
                  label: 'Community Name',
                  hint: 'Enter community name',
                  validator: (value) => Validators.validateRequired(value, 'Community name'),
                ),
                const SizedBox(height: 20),
                
                // Description Field
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe your community',
                  maxLines: 3,
                  validator: (value) => Validators.validateRequired(value, 'Description'),
                ),
                const SizedBox(height: 20),
                
                // Category Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: NearMeColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        hintText: 'Select category',
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Community Type
                const Text(
                  'Community Type',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: NearMeColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Public'),
                        value: 'public',
                        groupValue: _communityType,
                        onChanged: (value) {
                          setState(() {
                            _communityType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Private'),
                        value: 'private',
                        groupValue: _communityType,
                        onChanged: (value) {
                          setState(() {
                            _communityType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Radius Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Radius: ${_radius.toStringAsFixed(1)} km',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: NearMeColors.textPrimary),
                    ),
                    Slider(
                      value: _radius,
                      min: 1.0,
                      max: 10.0,
                      divisions: 18,
                      label: '${_radius.toStringAsFixed(1)} km',
                      activeColor: NearMeColors.gold,
                      inactiveColor: NearMeColors.navyBorder,
                      onChanged: (value) {
                        setState(() {
                          _radius = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Create Button
                Consumer<CommunityProvider>(
                  builder: (context, communityProvider, child) {
                    return CustomButton(
                      text: 'Create Community',
                      onPressed: _handleCreate,
                      isLoading: communityProvider.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
