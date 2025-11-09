import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/clothing_item.dart';
import '../widgets/clothing_item_card.dart';
import '../widgets/category_selector.dart';
import '../theme/app_theme.dart';
<<<<<<< HEAD
import '../utils/theme_aware_image.dart';
=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
import '../bloc/wardrobe/wardrobe_bloc.dart';
import '../bloc/model/model_bloc.dart';
import '../bloc/navigation/navigation_bloc.dart';
import 'add_clothing_screen.dart';

class WardrobeScreen extends StatefulWidget {
  final Map<String, dynamic>? imageData;

  const WardrobeScreen({
    super.key,
    this.imageData,
  });

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final List<String> categories = [
    'All',
    'Shirts',
    'Pants',
    'Shoes',
    'Necklaces',
    'Others'
  ];

  @override
  void initState() {
    super.initState();

    // WardrobeBloc initialization is handled by MainContainer
    // to prevent race conditions and double initialization

    // If we have image data from model upload, we could process it here
    if (widget.imageData != null) {
      // TODO: Process the image and add to wardrobe using BLoC
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Double-check wardrobe data loading when dependencies change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final wardrobeState = context.read<WardrobeBloc>().state;
        if (wardrobeState.items.isEmpty && wardrobeState.status != WardrobeStatus.loading) {
          context.read<WardrobeBloc>().add(WardrobeLoadItems());
        }
      }
    });
  }

  void _navigateToAddClothing() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => const AddClothingScreen(),
      ),
    );

    if (mounted && result != null && result['clothingItem'] != null) {
      context.read<WardrobeBloc>().add(
        WardrobeAddItem(result['clothingItem'] as ClothingItem),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        return Scaffold(
=======
    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
          body: SafeArea(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.spacingM,
                    AppTheme.spacingM,
                    AppTheme.spacingM,
                    AppTheme.spacingS,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'My Wardrobe',
<<<<<<< HEAD
                        style: AppTheme.primaryFont.copyWith(
                          color: textColor,
                          fontSize: AppTheme.headlineLargeFontSize,
                          fontWeight: FontWeight.w600,
=======
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: AppTheme.headlineLargeFontSize,
                          fontWeight: FontWeight.bold,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _navigateToAddClothing,
                        icon: Icon(
                          Icons.add,
<<<<<<< HEAD
                          color: textColor,
=======
                          color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                          size: AppTheme.iconM,
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.hasItems) _buildCategorySelector(state),
                Expanded(
                  child: state.status == WardrobeStatus.loading
                      ? _buildLoadingState()
                      : state.isEmpty
                          ? _buildEmptyState()
                          : _buildClothingGrid(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector(WardrobeState state) {
    return CategorySelector(
      categories: categories,
      selectedCategory: state.selectedCategory,
      onCategorySelected: (category) {
        context.read<WardrobeBloc>().add(WardrobeFilterByCategory(category));
      },
    );
  }

  Widget _buildLoadingState() {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Center(
      child: CircularProgressIndicator(
        color: primaryColor,
=======
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
      ),
    );
  }

  Widget _buildEmptyState() {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.displaySmall?.color ?? Colors.black;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final containerColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
<<<<<<< HEAD
          ThemeAwareImage.build(
            context: context,
            assetPath: 'assets/Add clothes.png',
=======
          Image.asset(
            'assets/Add clothes.png',
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
<<<<<<< HEAD
                  color: containerColor,
=======
                  color: Colors.black.withValues(alpha: 0.05),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checkroom_outlined,
                        size: AppTheme.iconXXL,
<<<<<<< HEAD
                        color: iconColor,
=======
                        color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                      ),
                      SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Add clothes image',
                        style: TextStyle(
<<<<<<< HEAD
                          color: iconColor,
=======
                          color: Colors.grey,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                          fontSize: AppTheme.bodyMediumFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: AppTheme.spacingXL),
          Text(
            'Your wardrobe is empty',
<<<<<<< HEAD
            style: AppTheme.primaryFont.copyWith(
              fontSize: AppTheme.displaySmallFontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
=======
            style: TextStyle(
              fontSize: AppTheme.displaySmallFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'Start building your digital wardrobe by adding your favorite clothes',
<<<<<<< HEAD
            style: AppTheme.primaryFont.copyWith(
              fontSize: AppTheme.bodyLargeFontSize,
              color: subtitleColor,
=======
            style: TextStyle(
              fontSize: AppTheme.bodyLargeFontSize,
              color: Colors.grey.shade600,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacingL),
          SizedBox(
            width: double.infinity,
            height: AppTheme.buttonHeightL,
            child: ElevatedButton(
              onPressed: _navigateToAddClothing,
              style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                ),
                elevation: isDark ? 2 : 0,
                shadowColor: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.transparent,
              ),
              child: Text(
                'Add Clothes',
                style: AppTheme.primaryFont.copyWith(
=======
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                'Add Clothes',
                style: TextStyle(
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  fontSize: AppTheme.titleLargeFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClothingGrid(WardrobeState state) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingM),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
        ),
        itemCount: state.displayItems.length,
        itemBuilder: (context, index) {
          final item = state.displayItems[index];
          return ClothingItemCard(
            item: item,
            onTap: () {
              context.read<WardrobeBloc>().add(WardrobeSelectItem(item.id));
            },
            onLongPress: () {
              _showItemOptions(item);
            },
          );
        },
      ),
    );
  }

  void _showItemOptions(ClothingItem item) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
=======
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.name,
<<<<<<< HEAD
              style: AppTheme.primaryFont.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
=======
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.category,
<<<<<<< HEAD
              style: AppTheme.primaryFont.copyWith(
                fontSize: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
=======
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Edit item using BLoC
                  },
<<<<<<< HEAD
                  icon: Icon(Icons.edit, color: textColor),
                  label: Text(
                    'Edit',
                    style: AppTheme.primaryFont.copyWith(color: textColor),
=======
                  icon: const Icon(Icons.edit, color: Colors.black),
                  label: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.black),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  ),
                ),
                BlocBuilder<ModelBloc, ModelState>(
                  builder: (context, modelState) {
                    return TextButton.icon(
                      onPressed: modelState.hasModel && !modelState.isProcessingOutfit
                          ? () {
                              Navigator.of(context).pop();
                              _applyOutfitToModel(item, modelState);
                            }
                          : null,
                      icon: Icon(
                        Icons.person_outline,
                        color: modelState.hasModel && !modelState.isProcessingOutfit
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      label: Text(
                        'Add to Model',
                        style: TextStyle(
                          color: modelState.hasModel && !modelState.isProcessingOutfit
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<WardrobeBloc>().add(WardrobeRemoveItem(item.id));
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
<<<<<<< HEAD
                  label: Text(
                    'Delete',
                    style: AppTheme.primaryFont.copyWith(color: Colors.red),
=======
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _applyOutfitToModel(ClothingItem item, ModelState modelState) {
    if (modelState.currentModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No model available. Please upload a model first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Apply outfit to model
    context.read<ModelBloc>().add(OutfitApplicationRequested(
      modelId: modelState.currentModel!.id,
      clothingItemId: item.id,
      outfitData: {
        'category': item.category,
        'name': item.name,
        'imageUrl': item.imageUrl,
      },
    ));

    // Show loading message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Applying outfit to model...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to model screen after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<NavigationBloc>().add(const NavigationTabChanged(1)); // Navigate to model screen
      }
    });
  }
}