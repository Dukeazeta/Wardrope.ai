import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  @override
  State<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends State<ModelScreen> {
  // This would typically come from your state management (Bloc/Provider/etc.)
  bool hasModel = false; // TODO: Get actual model state from your BLoC
  String? modelImagePath; // TODO: Get actual model image path from your BLoC

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomNavHeight = 92.h; // Height of bottom navbar from your design
    final availableHeight = screenHeight - bottomNavHeight;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasModel)
                    IconButton(
                      onPressed: () {
                        // TODO: Edit model functionality
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.black,
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
                  color: Colors.black.withValues(alpha: 0.02),
                ),
                child: hasModel && modelImagePath != null
                    ? _buildUserModelDisplay()
                    : _buildPlaceholderDisplay(),
              ),
            ),

            // CTA Button Area
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: _buildCTAButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderDisplay() {
    return Stack(
      children: [
        // Main content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Model.png placeholder image
              Container(
                width: 200.w,
                height: 300.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    'assets/Model.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if Model.png doesn't exist
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.08),
                            width: 1,
                          ),
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
              ),

              SizedBox(height: 32.h),

              // Text content
              Text(
                'No model photo yet',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                'Add your photo to try on outfits virtually',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              Text(
                'Full body photos work best',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        // Floating upload hint
        Positioned(
          bottom: 40.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Tap below to add your model',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserModelDisplay() {
    return Container(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Image.asset(
          modelImagePath!,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
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
                    'Failed to load model image',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/model-upload');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: 0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasModel ? Icons.camera_alt : Icons.add_photo_alternate,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              hasModel ? 'Update Model Photo' : 'Add Your Model',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}