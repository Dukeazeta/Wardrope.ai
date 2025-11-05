import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/clothing_item.dart';
import '../widgets/clothing_item_card.dart';
import '../widgets/category_selector.dart';
import '../theme/app_theme.dart';
import '../utils/theme_aware_image.dart';
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
    final theme = Theme.of(context);
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        return Scaffold(
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
                        style: AppTheme.primaryFont.copyWith(
                          color: textColor,
                          fontSize: AppTheme.headlineLargeFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _navigateToAddClothing,
                        icon: Icon(
                          Icons.add,
                          color: textColor,
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Center(
      child: CircularProgressIndicator(
        color: primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.displaySmall?.color ?? Colors.black;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey;
    final containerColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThemeAwareImage.build(
            context: context,
            assetPath: 'assets/Add clothes.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checkroom_outlined,
                        size: AppTheme.iconXXL,
                        color: iconColor,
                      ),
                      SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Add clothes image',
                        style: TextStyle(
                          color: iconColor,
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
            style: AppTheme.primaryFont.copyWith(
              fontSize: AppTheme.displaySmallFontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'Start building your digital wardrobe by adding your favorite clothes',
            style: AppTheme.primaryFont.copyWith(
              fontSize: AppTheme.bodyLargeFontSize,
              color: subtitleColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.headlineLarge?.color ?? Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
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
              style: AppTheme.primaryFont.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.category,
              style: AppTheme.primaryFont.copyWith(
                fontSize: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                  icon: Icon(Icons.edit, color: textColor),
                  label: Text(
                    'Edit',
                    style: AppTheme.primaryFont.copyWith(color: textColor),
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
                  label: Text(
                    'Delete',
                    style: AppTheme.primaryFont.copyWith(color: Colors.red),
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