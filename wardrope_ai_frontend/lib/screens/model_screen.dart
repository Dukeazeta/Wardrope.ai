import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../bloc/model/model_bloc.dart';
import '../services/model_service.dart';
import '../theme/app_theme.dart';
import '../utils/theme_aware_image.dart';

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  @override
  State<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends State<ModelScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _currentUserId; // This would come from your auth system

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  void _initializeModel() {
    // Check model service status first
    context.read<ModelBloc>().add(ModelStatusCheckRequested());

    // Load user models (using a placeholder user ID for now)
    // In a real app, this would come from your authentication system
    _currentUserId = 'user_placeholder_123';
    context.read<ModelBloc>().add(ModelLoadRequested(_currentUserId!));
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (photo != null) {
        final File imageFile = File(photo.path);

        // Upload model via BLoC
        if (mounted) {
          context.read<ModelBloc>().add(ModelUploadFromCamera(
            imageFile: imageFile,
            userId: _currentUserId,
          ));
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to take photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);

        // Upload model via BLoC
        if (mounted) {
          context.read<ModelBloc>().add(ModelUploadFromGallery(
            imageFile: imageFile,
            userId: _currentUserId,
          ));
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _showErrorDialog(String message) {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomNavHeight = 92.h; // Height of bottom navbar from your design
    final availableHeight = screenHeight - bottomNavHeight;

    return BlocListener<ModelBloc, ModelState>(
      listener: (context, state) {
        // Handle errors
        if (state.hasError) {
          _showErrorDialog(state.errorMessage ?? 'An error occurred');
        }

              },
      child: BlocBuilder<ModelBloc, ModelState>(
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Model',
                          style: AppTheme.primaryFont.copyWith(
                            color: textColor,
                            fontSize: AppTheme.headlineLargeFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (state.hasModel)
                          IconButton(
                            onPressed: () {
                              // TODO: Edit model functionality
                            },
                            icon: Icon(
                              Icons.edit_outlined,
                              color: textColor,
                              size: 24.sp,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Full Screen Model Display Area
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: availableHeight - 80.h, // Account for header and CTA button
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.02)
                            : Colors.black.withValues(alpha: 0.02),
                      ),
                      child: _buildModelDisplay(state),
                    ),
                  ),

                  // CTA Button Area
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.95)
                          : Colors.white.withValues(alpha: 0.95),
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: _buildActionButtons(state),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModelDisplay(ModelState state) {
    final theme = Theme.of(context);

    // Show loading indicator
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 2,
            ),
            SizedBox(height: 16.h),
            Text(
              'Processing your model...',
              style: AppTheme.primaryFont.copyWith(
                fontSize: AppTheme.bodyLargeFontSize,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    // Show outfit on model if available
    if (state.hasOutfit && state.currentOutfitImage != null) {
      return _buildImageDisplay(state.currentOutfitImage!);
    }

    // Show processed model if available
    if (state.hasModel && state.currentModel?.processedImageUrl != null) {
      return _buildImageDisplay(state.currentModel!.processedImageUrl!);
    }

    // Show placeholder if no model
    return _buildPlaceholderDisplay();
  }

  Widget _buildImageDisplay(String imageUrl) {
    // Check if it's a data URL (base64) or file path
    if (imageUrl.startsWith('data:')) {
      return _buildBase64Image(imageUrl);
    } else if (imageUrl.startsWith('/')) {
      return _buildFileImage(imageUrl);
    } else {
      return _buildAssetImage(imageUrl);
    }
  }

  Widget _buildBase64Image(String base64Url) {
    try {
      final pureBase64 = ModelService.extractBase64FromDataUrl(base64Url);

      return Image.memory(
        const Base64Decoder().convert(pureBase64),
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorDisplay('Failed to load model image');
        },
      );
    } catch (e) {
      return _buildErrorDisplay('Invalid image data');
    }
  }

  Widget _buildFileImage(String filePath) {
    return Image.file(
      File(filePath),
      fit: BoxFit.contain,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorDisplay('Failed to load model image');
      },
    );
  }

  Widget _buildAssetImage(String assetPath) {
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorDisplay('Failed to load model image');
      },
    );
  }

  Widget _buildPlaceholderDisplay() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: ThemeAwareImage.build(
          context: context,
          assetPath: 'assets/Model.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if Model.png doesn't exist
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
              ),
              child: Icon(
                Icons.person_outline,
                size: 80.sp,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorDisplay(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: AppTheme.primaryFont.copyWith(
              fontSize: 16.sp,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ModelState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.2);
    final containerColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Don't show upload buttons if user has a model and is viewing an outfit
    if (state.hasOutfit) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                // Clear the outfit to go back to the base model
                context.read<ModelBloc>().add(OutfitClearRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                elevation: isDark ? 2 : 0,
                shadowColor: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.transparent,
              ),
              child: Text(
                'Remove Outfit',
                style: AppTheme.primaryFont.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Show upload buttons if no model or base model is showing
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: (state.isLoading) ? null : _takePhoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              elevation: isDark ? 2 : 0,
              shadowColor: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.transparent,
              disabledBackgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
            ),
            child: state.isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.black : Colors.white),
                    ),
                  )
                : Text(
                    state.hasModel ? 'Retake Photo' : 'Take Photo',
                    style: AppTheme.primaryFont.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          height: 48.h,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: (state.isLoading) ? null : _pickFromGallery,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: textColor,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 20.sp,
                  color: textColor.withValues(alpha: 0.7),
                ),
                SizedBox(width: 8.w),
                Text(
                  state.hasModel ? 'Change Model' : 'Upload from Gallery',
                  style: AppTheme.primaryFont.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}