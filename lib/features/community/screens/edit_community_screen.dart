import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/services/image_service.dart';
import '../providers/community_provider.dart';
import '../../../core/models/community_model.dart';
import '../../../core/config/theme_config.dart';
import 'dart:io';

class EditCommunityScreen extends StatefulWidget {
  final CommunityModel community;

  const EditCommunityScreen({super.key, required this.community});

  @override
  State<EditCommunityScreen> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends State<EditCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _imageService = ImageService.getInstance();

  late String _selectedCategory;
  late String _communityType;
  late double _radius;
  File? _logoImage;
  File? _coverImage;

  final List<String> _categories = [
    'Sports', 'Technology', 'Music', 'Art', 'Food',
    'Travel', 'Business', 'Education', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.community.name);
    _descriptionController = TextEditingController(text: widget.community.description);
    _selectedCategory = _categories.contains(widget.community.category)
        ? widget.community.category
        : 'Other';
    _communityType = widget.community.type;
    _radius = widget.community.radius;
  }

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
      if (image != null) setState(() => _logoImage = image);
    }
  }

  Future<void> _pickCover() async {
    final source = await _showImageSourceDialog();
    if (source != null) {
      final image = await _imageService.pickImage(source);
      if (image != null) setState(() => _coverImage = image);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final communityProvider = context.read<CommunityProvider>();
      final success = await communityProvider.updateCommunity(
        communityId: widget.community.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        type: _communityType,
        radius: _radius,
        logo: _logoImage,
        cover: _coverImage,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Community updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // return true = refresh needed
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(communityProvider.error ?? 'Failed to update community'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Community'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image Picker
                GestureDetector(
                  onTap: _pickCover,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? NearMeColors.navyCard : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? NearMeColors.navyBorder : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      image: _coverImage != null
                          ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover)
                          : (widget.community.cover != null
                              ? DecorationImage(image: NetworkImage(widget.community.cover!), fit: BoxFit.cover)
                              : null),
                    ),
                    child: (_coverImage == null && widget.community.cover == null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded,
                                  size: 40, color: NearMeColors.gold),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to change cover',
                                style: TextStyle(
                                  color: isDark ? NearMeColors.textSecondary : Colors.grey[600],
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Logo Image Picker
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickLogo,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark ? NearMeColors.navyCard : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? NearMeColors.navyBorder : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          image: _logoImage != null
                              ? DecorationImage(image: FileImage(_logoImage!), fit: BoxFit.cover)
                              : (widget.community.logo != null
                                  ? DecorationImage(image: NetworkImage(widget.community.logo!), fit: BoxFit.cover)
                                  : null),
                        ),
                        child: (_logoImage == null && widget.community.logo == null)
                            ? const Icon(Icons.add_a_photo_rounded, size: 28, color: NearMeColors.gold)
                            : const Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.edit, color: Colors.white, size: 14),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Community Logo',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? NearMeColors.textSecondary : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
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
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? NearMeColors.textPrimary : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(hintText: 'Select category'),
                      items: _categories.map((category) {
                        return DropdownMenuItem(value: category, child: Text(category));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedCategory = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Community Type
                Text(
                  'Community Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? NearMeColors.textPrimary : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Public'),
                        value: 'public',
                        groupValue: _communityType,
                        activeColor: NearMeColors.gold,
                        onChanged: (value) => setState(() => _communityType = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Private'),
                        value: 'private',
                        groupValue: _communityType,
                        activeColor: NearMeColors.gold,
                        onChanged: (value) => setState(() => _communityType = value!),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? NearMeColors.textPrimary : const Color(0xFF111827),
                      ),
                    ),
                    Slider(
                      value: _radius,
                      min: 1.0,
                      max: 10.0,
                      divisions: 18,
                      label: '${_radius.toStringAsFixed(1)} km',
                      activeColor: NearMeColors.gold,
                      inactiveColor: isDark ? NearMeColors.navyBorder : Colors.grey[300],
                      onChanged: (value) => setState(() => _radius = value),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save Button
                Consumer<CommunityProvider>(
                  builder: (context, communityProvider, child) {
                    return CustomButton(
                      text: 'Save Changes',
                      onPressed: _handleUpdate,
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
