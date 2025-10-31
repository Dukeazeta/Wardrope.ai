import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/clothing_item.dart';

part 'wardrobe_event.dart';
part 'wardrobe_state.dart';

class WardrobeBloc extends Bloc<WardrobeEvent, WardrobeState> {
  WardrobeBloc() : super(const WardrobeState()) {
    on<WardrobeLoadItems>(_onLoadItems);
    on<WardrobeAddItem>(_onAddItem);
    on<WardrobeRemoveItem>(_onRemoveItem);
    on<WardrobeUpdateItem>(_onUpdateItem);
    on<WardrobeFilterByCategory>(_onFilterByCategory);
    on<WardrobeSearchItems>(_onSearchItems);
    on<WardrobeClearSearch>(_onClearSearch);
    on<WardrobeSelectItem>(_onSelectItem);
    on<WardrobeClearSelection>(_onClearSelection);
  }

  void _onLoadItems(WardrobeLoadItems event, Emitter<WardrobeState> emit) {
    emit(state.copyWith(status: WardrobeStatus.loading));

    // TODO: Load items from local storage or API
    // For now, we'll simulate loading with empty list
    emit(state.copyWith(
      status: WardrobeStatus.loaded,
      items: [],
      filteredItems: [],
    ));
  }

  void _onAddItem(WardrobeAddItem event, Emitter<WardrobeState> emit) {
    final updatedItems = [...state.items, event.item];
    final updatedFilteredItems = _filterItems(updatedItems, state.selectedCategory);

    emit(state.copyWith(
      items: updatedItems,
      filteredItems: updatedFilteredItems,
    ));
  }

  void _onRemoveItem(WardrobeRemoveItem event, Emitter<WardrobeState> emit) {
    final updatedItems = state.items.where((item) => item.id != event.itemId).toList();
    final updatedFilteredItems = _filterItems(updatedItems, state.selectedCategory);

    emit(state.copyWith(
      items: updatedItems,
      filteredItems: updatedFilteredItems,
      clearSelectedItem: state.selectedItem == event.itemId,
    ));
  }

  void _onUpdateItem(WardrobeUpdateItem event, Emitter<WardrobeState> emit) {
    final updatedItems = state.items.map((item) {
      return item.id == event.item.id ? event.item : item;
    }).toList();
    final updatedFilteredItems = _filterItems(updatedItems, state.selectedCategory);

    emit(state.copyWith(
      items: updatedItems,
      filteredItems: updatedFilteredItems,
    ));
  }

  void _onFilterByCategory(WardrobeFilterByCategory event, Emitter<WardrobeState> emit) {
    final filteredItems = _filterItems(state.items, event.category);
    emit(state.copyWith(
      selectedCategory: event.category,
      filteredItems: filteredItems,
    ));
  }

  void _onSearchItems(WardrobeSearchItems event, Emitter<WardrobeState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onClearSearch(WardrobeClearSearch event, Emitter<WardrobeState> emit) {
    emit(state.copyWith(searchQuery: ''));
  }

  void _onSelectItem(WardrobeSelectItem event, Emitter<WardrobeState> emit) {
    emit(state.copyWith(selectedItem: event.itemId));
  }

  void _onClearSelection(WardrobeClearSelection event, Emitter<WardrobeState> emit) {
    emit(state.copyWith(clearSelectedItem: true));
  }

  List<ClothingItem> _filterItems(List<ClothingItem> items, String category) {
    if (category == 'All') {
      return items;
    }
    return items.where((item) => item.category == category).toList();
  }
}