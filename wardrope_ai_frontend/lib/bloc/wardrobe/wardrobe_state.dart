part of 'wardrobe_bloc.dart';

enum WardrobeStatus { initial, loading, loaded, error }

class WardrobeState extends Equatable {
  final WardrobeStatus status;
  final List<ClothingItem> items;
  final List<ClothingItem> filteredItems;
  final String selectedCategory;
  final String searchQuery;
  final String? selectedItem;
  final String? errorMessage;

  const WardrobeState({
    this.status = WardrobeStatus.initial,
    this.items = const [],
    this.filteredItems = const [],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.selectedItem,
    this.errorMessage,
  });

  WardrobeState copyWith({
    WardrobeStatus? status,
    List<ClothingItem>? items,
    List<ClothingItem>? filteredItems,
    String? selectedCategory,
    String? searchQuery,
    String? selectedItem,
    String? errorMessage,
    bool clearSelectedItem = false,
  }) {
    return WardrobeState(
      status: status ?? this.status,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedItem: clearSelectedItem ? null : (selectedItem ?? this.selectedItem),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<ClothingItem> get displayItems {
    if (searchQuery.isNotEmpty) {
      return filteredItems.where((item) {
        return item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               item.category.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    return filteredItems;
  }

  bool get isEmpty => items.isEmpty;
  bool get hasItems => items.isNotEmpty;
  bool get isFiltered => selectedCategory != 'All' || searchQuery.isNotEmpty;

  @override
  List<Object?> get props => [
        status,
        items,
        filteredItems,
        selectedCategory,
        searchQuery,
        selectedItem,
        errorMessage,
      ];
}