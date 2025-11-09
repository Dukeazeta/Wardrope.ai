import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/clothing_item.dart';
import '../theme/app_theme.dart';

class ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ClothingItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);
    final imageBgColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
=======
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              blurRadius: 10,
              offset: Offset(0, 4.h),
            ),
          ],
          border: Border.all(
<<<<<<< HEAD
            color: borderColor,
=======
            color: Colors.black.withValues(alpha: 0.1),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
<<<<<<< HEAD
                  color: imageBgColor,
=======
                  color: Colors.black.withValues(alpha: 0.05),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusM),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusM),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
<<<<<<< HEAD
                        color: imageBgColor,
=======
                        color: Colors.black.withValues(alpha: 0.05),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: AppTheme.iconXL,
<<<<<<< HEAD
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
=======
                            color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: AlwaysStoppedAnimation<Color>(
<<<<<<< HEAD
                            theme.colorScheme.primary,
=======
                            Colors.black.withValues(alpha: 0.3),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: AppTheme.titleMediumFontSize,
                        fontWeight: FontWeight.w600,
<<<<<<< HEAD
                        color: theme.textTheme.bodyLarge?.color ?? Colors.black,
=======
                        color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.category,
                      style: TextStyle(
                        fontSize: AppTheme.bodySmallFontSize,
<<<<<<< HEAD
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
=======
                        color: Colors.grey.shade600,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}