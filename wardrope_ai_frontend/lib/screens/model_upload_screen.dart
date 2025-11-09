import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
<<<<<<< HEAD
import '../services/onboarding_service.dart';
import '../services/image_processing_service.dart';
import '../theme/app_theme.dart';
=======
import '../services/image_service.dart';
import '../services/onboarding_service.dart';
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19

class ModelUploadScreen extends StatefulWidget {
  const ModelUploadScreen({super.key});

  @override
  State<ModelUploadScreen> createState() => _ModelUploadScreenState();
}

class _ModelUploadScreenState extends State<ModelUploadScreen> {
  File? _imageFile;
  bool _isProcessing = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

<<<<<<< HEAD
      if (photo != null && mounted) {
=======
      if (photo != null) {
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
        setState(() {
          _imageFile = File(photo.path);
        });
        await _processImage();
      }
    } catch (e) {
<<<<<<< HEAD
      if (mounted) {
        _showErrorDialog('Failed to take photo: $e');
      }
=======
      _showErrorDialog('Failed to take photo: $e');
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

<<<<<<< HEAD
      if (image != null && mounted) {
=======
      if (image != null) {
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
        setState(() {
          _imageFile = File(image.path);
        });
        await _processImage();
      }
    } catch (e) {
<<<<<<< HEAD
      if (mounted) {
        _showErrorDialog('Failed to pick image: $e');
      }
=======
      _showErrorDialog('Failed to pick image: $e');
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    }
  }

  Future<void> _processImage() async {
<<<<<<< HEAD
    if (_imageFile == null || !mounted) return;
=======
    if (_imageFile == null) return;
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19

    setState(() {
      _isProcessing = true;
    });

    try {
<<<<<<< HEAD
      // Process model using hybrid AI service (Google Gemini + local storage)
      await _uploadImageForProcessing(_imageFile!);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to process image: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
=======
      // TODO: Integrate with backend API for image processing
      // This will call the Google Gen AI (nano) model for background removal
      await _uploadImageForProcessing(_imageFile!);
    } catch (e) {
      _showErrorDialog('Failed to process image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    }
  }

  Future<void> _uploadImageForProcessing(File imageFile) async {
    try {
<<<<<<< HEAD
      // Process model using hybrid AI service
      final result = await ImageProcessingService.processModelComplete(
        imageFile: imageFile,
        name: 'User Model',
        modelType: 'user',
        onProgress: (progress) {
          // You could update a progress bar here if needed
        },
        onStatus: (status) {
          // You could update status text here if needed
        },
      );

      if (!result['success']) {
        throw Exception(result['error'] ?? 'Unknown processing error');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Model processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Mark model upload as completed
        await OnboardingService.markModelUploadCompleted();

        // Navigate to wardrobe screen with processed model data
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to process model: $e');
=======
      final result = await ImageService.processImage(imageFile);

      if (result['success'] == true) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image processed successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Mark model upload as completed
          await OnboardingService.markModelUploadCompleted();

          // Navigate to wardrobe screen with processed image data
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      } else {
        throw Exception(result['message'] ?? 'Processing failed');
      }
    } catch (e) {
      _showErrorDialog('Failed to process image: $e');
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    }
  }

  void _showErrorDialog(String message) {
<<<<<<< HEAD
    if (!mounted) return;

=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final appBarColor = theme.appBarTheme.backgroundColor ?? backgroundColor;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor.withValues(alpha: 0.8),
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
=======
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
        leading: IconButton(
          onPressed: () async {
            // Mark model upload as completed (user is skipping)
            await OnboardingService.markModelUploadCompleted();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
<<<<<<< HEAD
          icon: Icon(
            Icons.close,
            color: textColor,
            size: 24,
          ),
        ),
        title: Text(
          'Your Model',
          style: AppTheme.primaryFont.copyWith(
            color: textColor,
=======
          icon: const Icon(
            Icons.close,
            color: Colors.black,
            size: 24,
          ),
        ),
        title: const Text(
          'Your Model',
          style: TextStyle(
            color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
<<<<<<< HEAD
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/debug');
            },
            icon: Icon(
              Icons.bug_report,
              color: textColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
=======
        actions: const [SizedBox(width: 40)], // Balance the back button
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildHeader(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    return Column(
      children: [
        Text(
          'Take a picture of yourself',
          style: AppTheme.primaryFont.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
=======
    return Column(
      children: [
        const Text(
          'Take a picture of yourself',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'A full-body photo would work best for optimal results. Stand in a well-lit area with a plain background.',
<<<<<<< HEAD
          style: AppTheme.primaryFont.copyWith(
            fontSize: 16,
            color: isDark ? Colors.grey.shade400 : Colors.grey,
=======
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildDemoPhoto(),
      ],
    );
  }

<<<<<<< HEAD
  
  Widget _buildDemoPhoto() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

=======
  Widget _buildDemoPhoto() {
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 300),
      height: 200,
      decoration: BoxDecoration(
<<<<<<< HEAD
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
=======
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/Demo Photo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
=======
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 48,
<<<<<<< HEAD
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Demo photo',
                      style: AppTheme.primaryFont.copyWith(
                        color: isDark ? Colors.grey.shade400 : Colors.grey,
=======
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Demo photo',
                      style: TextStyle(
                        color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  
  Widget _buildBottomActions() {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final containerColor = theme.cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);
    final buttonBgColor = isDark ? Colors.white : Colors.black;
    final buttonTextColor = isDark ? Colors.black : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: containerColor.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: borderColor,
=======
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.1),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _takePhoto,
              style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                backgroundColor: buttonBgColor,
                foregroundColor: buttonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24), // Fully rounded
                ),
                elevation: isDark ? 2 : 0,
                shadowColor: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.transparent,
                disabledBackgroundColor: buttonBgColor.withValues(alpha: 0.5),
              ),
              child: _isProcessing
                  ? SizedBox(
=======
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24), // Fully rounded
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.black.withValues(alpha: 0.5),
              ),
              child: _isProcessing
                  ? const SizedBox(
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
<<<<<<< HEAD
                        valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
                      ),
                    )
                  : Text(
                      'Take Photo',
                      style: AppTheme.primaryFont.copyWith(
=======
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Take Photo',
                      style: TextStyle(
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
<<<<<<< HEAD
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: borderColor,
=======
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.2),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
<<<<<<< HEAD
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
=======
                  color: Colors.black.withValues(alpha: 0.05),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _pickFromGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
<<<<<<< HEAD
                foregroundColor: buttonTextColor,
=======
                foregroundColor: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 20,
<<<<<<< HEAD
                    color: Colors.brown,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upload from Gallery',
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.brown,
=======
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Upload from Gallery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy.',
<<<<<<< HEAD
            style: AppTheme.primaryFont.copyWith(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey,
=======
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}