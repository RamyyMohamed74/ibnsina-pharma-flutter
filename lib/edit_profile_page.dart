import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfilePage({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final ImagePicker _imagePicker = ImagePicker();

  String? _currentImageUrl;

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  bool _isSaving = false;
  bool _isRemovingPhoto = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.profile['fullName']?.toString() ?? '',
    );

    _emailController = TextEditingController(
      text: widget.profile['email']?.toString() ?? '',
    );

    _phoneController = TextEditingController(
      text: widget.profile['phoneNumber']?.toString() ?? '',
    );

    _currentImageUrl =
        widget.profile['profileImageUrl']?.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK PROFILE IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not select image: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await ApiService.updateMyProfile(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profileImage: _selectedImage,
      );

      if (!mounted) return;

      final updatedProfile =
          result['profile'] as Map<String, dynamic>?;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(
        context,
        updatedProfile,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // REMOVE PROFILE PHOTO
  // ============================================================

  Future<void> _removePhoto() async {
    setState(() {
      _isRemovingPhoto = true;
    });

    try {
      await ApiService.deleteProfilePhoto();

      if (!mounted) return;

      setState(() {
        _currentImageUrl = null;
        _selectedImage = null;
        _selectedImageBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile photo removed.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRemovingPhoto = false;
        });
      }
    }
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget _buildProfileImage() {
    // New image selected from gallery
    if (_selectedImageBytes != null) {
      return CircleAvatar(
        radius: 65,
        backgroundImage: MemoryImage(
          _selectedImageBytes!,
        ),
      );
    }

    // Existing image from backend
    if (_currentImageUrl != null &&
        _currentImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 65,
        backgroundImage: NetworkImage(
          _currentImageUrl!,
        ),
        onBackgroundImageError: (_, __) {},
      );
    }

    // No image
    return const CircleAvatar(
      radius: 65,
      child: Icon(
        Icons.person,
        size: 70,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // PROFILE IMAGE
                Center(
                  child: Stack(
                    children: [
                      _buildProfileImage(),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed:
                                _isSaving
                                    ? null
                                    : _pickImage,
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // CHANGE PHOTO
                TextButton.icon(
                  onPressed:
                      _isSaving
                          ? null
                          : _pickImage,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  label: const Text(
                    'Change Profile Photo',
                  ),
                ),

                // REMOVE PHOTO
                if (_currentImageUrl != null ||
                    _selectedImage != null)
                  TextButton.icon(
                    onPressed:
                        (_isSaving ||
                                _isRemovingPhoto)
                            ? null
                            : _removePhoto,
                    icon: _isRemovingPhoto
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                    label: const Text(
                      'Remove Photo',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),

                const SizedBox(height: 25),

                // FULL NAME
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // EMAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your email';
                    }

                    final emailRegex =
                        RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    );

                    if (!emailRegex.hasMatch(
                      value.trim(),
                    )) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // PHONE
                TextFormField(
                  controller:
                      _phoneController,
                  keyboardType:
                      TextInputType.phone,
                  textInputAction:
                      TextInputAction.done,
                  decoration:
                      const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                // SAVE
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _isSaving
                            ? null
                            : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}