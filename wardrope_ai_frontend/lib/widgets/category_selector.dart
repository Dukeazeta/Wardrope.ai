import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: EdgeInsets.only(right: AppTheme.spacingS),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                onCategorySelected(category);
              },
<<<<<<< HEAD
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              selectedColor: textColor,
              labelStyle: AppTheme.primaryFont.copyWith(
                color: isSelected ? Colors.white : textColor,
=======
              backgroundColor: Colors.black.withValues(alpha: 0.05),
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                fontWeight: FontWeight.w500,
                fontSize: AppTheme.bodyMediumFontSize,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                side: BorderSide(
<<<<<<< HEAD
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.2),
=======
                  color: Colors.black.withValues(alpha: 0.2),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}