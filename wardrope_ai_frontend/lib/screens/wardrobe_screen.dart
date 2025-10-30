import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/clothing_item.dart';
import '../widgets/clothing_item_card.dart';
import '../widgets/category_selector.dart';
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
  List<ClothingItem> clothingItems = [];
  String selectedCategory = 'All';

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
    // If we have image data from model upload, we could process it here
    if (widget.imageData != null) {
      // TODO: Process the image and add to wardrobe
    }
  }

  List<ClothingItem> get filteredItems {
    if (selectedCategory == 'All') {
      return clothingItems;
    }
    return clothingItems.where((item) => item.category == selectedCategory).toList();
  }

  void _navigateToAddClothing() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => const AddClothingScreen(),
      ),
    );

    if (result != null && result['clothingItem'] != null) {
      setState(() {
        clothingItems.add(result['clothingItem'] as ClothingItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          'My Wardrobe',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _navigateToAddClothing,
            icon: const Icon(
              Icons.add,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (clothingItems.isNotEmpty) _buildCategorySelector(),
          Expanded(
            child: clothingItems.isEmpty
                ? _buildEmptyState()
                : _buildClothingGrid(),
          ),
        ],
      ),
      floatingActionButton: clothingItems.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _navigateToAddClothing,
              backgroundColor: Colors.black,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
    );
  }

  Widget _buildCategorySelector() {
    return CategorySelector(
      categories: categories,
      selectedCategory: selectedCategory,
      onCategorySelected: (category) {
        setState(() {
          selectedCategory = category;
        });
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checkroom_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Add clothes image',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          const Text(
            'Your wardrobe is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Start building your digital wardrobe by adding your favorite clothes',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _navigateToAddClothing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Add Clothes',
                style: TextStyle(
                  fontSize: 18,
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

  Widget _buildClothingGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return ClothingItemCard(
            item: item,
            onTap: () {
              // TODO: Show item details or edit
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
                    // TODO: Edit item
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
                    setState(() {
                      clothingItems.remove(item);
                    });
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