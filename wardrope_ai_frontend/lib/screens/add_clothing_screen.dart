import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
<<<<<<< HEAD
import '../theme/app_theme.dart';
import '../utils/theme_aware_image.dart';
import '../services/image_processing_service.dart';
=======
import '../models/clothing_item.dart';
import '../services/image_service.dart';
import '../theme/app_theme.dart';
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  File? _imageFile;
  bool _isProcessing = false;
  String _selectedCategory = 'T-Shirts';
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> categories = [
    'T-Shirts',
    'Shirts',
    'Pants',
    'Shorts',
    'Dresses',
    'Skirts',
    'Jackets',
    'Coats',
    'Sweaters',
    'Hoodies',
    'Shoes',
    'Sneakers',
    'Boots',
    'Bags',
    'Hats',
    'Accessories',
    'Jewelry',
    'Underwear',
    'Socks',
    'Swimwear',
    'Sportswear',
    'Traditional',
    'Others'
  ];

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

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
          _isProcessing = true;
        });
        await _processImage();
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
        setState(() {
          _imageFile = File(image.path);
          _isProcessing = true;
        });
        await _processImage();
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    try {
<<<<<<< HEAD
      final result = await ImageProcessingService.processClothingItemComplete(
        imageFile: _imageFile!,
        name: 'New Item',
        category: _selectedCategory,
        style: 'casual',
        onProgress: (progress) {
          // You could update a progress indicator here
        },
        onStatus: (status) {
          // You could update a status text here
        },
      );

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clothing item processed and saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return to previous screen
        }
      } else {
        _showErrorDialog('Failed to process clothing item: ${result['error']}');
=======
      final result = await ImageService.processImage(_imageFile!);

      if (result['success'] == true) {
        // Image processed successfully, URL would be available if needed
        // final processedImageUrl = result['processedImageUrl'] as String?;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image processed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result['message'] ?? 'Processing failed');
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
      }
    } catch (e) {
      _showErrorDialog('Failed to process image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
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

<<<<<<< HEAD
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final appBarColor = theme.appBarTheme.backgroundColor ?? backgroundColor;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
=======
  void _saveClothingItem() {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add an image for your clothing item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final clothingItem = ClothingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _selectedCategory, // Use category as name since we removed name input
      category: _selectedCategory,
      imageUrl: 'processed_image_url', // This would come from the backend
      originalImagePath: _imageFile!.path,
      createdAt: DateTime.now(),
    );

    Navigator.of(context).pop({
      'clothingItem': clothingItem,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close,
<<<<<<< HEAD
            color: textColor,
=======
            color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            size: AppTheme.iconM,
          ),
        ),
        title: Text(
          'Add Clothing',
<<<<<<< HEAD
          style: AppTheme.primaryFont.copyWith(
            color: textColor,
            fontSize: AppTheme.titleLargeFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
=======
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTheme.titleLargeFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveClothingItem,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.black,
                fontSize: AppTheme.titleMediumFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  SizedBox(height: AppTheme.spacingL),
                  _buildCategorySection(),
                ],
              ),
            ),
          ),
          if (_imageFile == null) _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    return Container(
      width: double.infinity,
      height: 250.h,
      constraints: BoxConstraints(maxWidth: 320.w),
      decoration: BoxDecoration(
<<<<<<< HEAD
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
=======
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                fit: BoxFit.cover,
              )
            else
<<<<<<< HEAD
              ThemeAwareImage.build(
                context: context,
                assetPath: 'assets/Add clothes 02.png',
=======
              Image.asset(
                'assets/Add clothes 02.png',
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
<<<<<<< HEAD
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
=======
                      color: Colors.black.withValues(alpha: 0.05),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: AppTheme.iconXL,
<<<<<<< HEAD
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
=======
                            color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                          ),
                          SizedBox(height: AppTheme.spacingS),
                          Text(
                            'Add clothes placeholder',
                            style: TextStyle(
                              fontSize: AppTheme.bodyLargeFontSize,
                              fontWeight: FontWeight.w500,
<<<<<<< HEAD
                              color: isDark ? Colors.grey.shade400 : Colors.grey,
=======
                              color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            if (_isProcessing && _imageFile != null)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Processing your image...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTheme.bodyLargeFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_imageFile != null && !_isProcessing)
              Positioned(
                top: AppTheme.spacingS,
                right: AppTheme.spacingS,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _imageFile = null;
                    });
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: AppTheme.iconS,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildCategorySection() {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final containerColor = theme.cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);

=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
<<<<<<< HEAD
          style: AppTheme.primaryFont.copyWith(
            fontSize: AppTheme.titleMediumFontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
=======
          style: TextStyle(
            fontSize: AppTheme.bodyLargeFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
          ),
        ),
        SizedBox(height: AppTheme.spacingS),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          decoration: BoxDecoration(
            border: Border.all(
<<<<<<< HEAD
              color: borderColor,
=======
              color: Colors.black.withValues(alpha: 0.2),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
<<<<<<< HEAD
              dropdownColor: containerColor,
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    style: AppTheme.primaryFont.copyWith(color: textColor),
                  ),
=======
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
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
    final buttonTextColor = isDark ? Colors.black : Colors.white;
    final buttonBgColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        border: Border(
          top: BorderSide(
            color: borderColor,
=======
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.1),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: AppTheme.buttonHeightM,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _takePhoto,
              style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                backgroundColor: buttonBgColor,
                foregroundColor: buttonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                ),
                elevation: isDark ? 2 : 0,
                shadowColor: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.transparent,
                disabledBackgroundColor: buttonBgColor.withValues(alpha: 0.5),
=======
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.black.withValues(alpha: 0.5),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
              child: _isProcessing
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
<<<<<<< HEAD
                        valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
=======
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                      ),
                    )
                  : Text(
                      'Take Photo',
                      style: TextStyle(
                        fontSize: AppTheme.bodyLargeFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          SizedBox(height: AppTheme.spacingM),
          Container(
            width: double.infinity,
            height: AppTheme.buttonHeightM,
            decoration: BoxDecoration(
<<<<<<< HEAD
              color: isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
=======
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.2),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
<<<<<<< HEAD
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
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
                foregroundColor: isDark ? Colors.white : Colors.black,
=======
                foregroundColor: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: AppTheme.iconS,
<<<<<<< HEAD
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
=======
                    color: Colors.black.withValues(alpha: 0.7),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Upload from Gallery',
                    style: TextStyle(
                      fontSize: AppTheme.bodyLargeFontSize,
                      fontWeight: FontWeight.w500,
<<<<<<< HEAD
                      color: isDark ? Colors.white : Colors.black,
=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}