import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/clothing_item.dart';
import '../widgets/clothing_item_card.dart';
import '../widgets/category_selector.dart';
import '../theme/app_theme.dart';
import '../bloc/wardrobe/wardrobe_bloc.dart';
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
    return BlocBuilder<WardrobeBloc, WardrobeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
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
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: AppTheme.headlineLargeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _navigateToAddClothing,
                        icon: Icon(
                          Icons.add,
                          color: Colors.black,
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
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.black,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/Add clothes.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checkroom_outlined,
                        size: AppTheme.iconXXL,
                        color: Colors.grey,
                      ),
                      SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Add clothes image',
                        style: TextStyle(
                          color: Colors.grey,
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
            style: TextStyle(
              fontSize: AppTheme.displaySmallFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'Start building your digital wardrobe by adding your favorite clothes',
            style: TextStyle(
              fontSize: AppTheme.bodyLargeFontSize,
              color: Colors.grey.shade600,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.category,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
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
                  icon: const Icon(Icons.edit, color: Colors.black),
                  label: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<WardrobeBloc>().add(WardrobeRemoveItem(item.id));
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
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
}