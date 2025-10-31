part of 'wardrobe_bloc.dart';

abstract class WardrobeEvent extends Equatable {
  const WardrobeEvent();

  @override
  List<Object> get props => [];
}

class WardrobeLoadItems extends WardrobeEvent {}

class WardrobeAddItem extends WardrobeEvent {
  final ClothingItem item;

  const WardrobeAddItem(this.item);

  @override
  List<Object> get props => [item];
}

class WardrobeRemoveItem extends WardrobeEvent {
  final String itemId;

  const WardrobeRemoveItem(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class WardrobeUpdateItem extends WardrobeEvent {
  final ClothingItem item;

  const WardrobeUpdateItem(this.item);

  @override
  List<Object> get props => [item];
}

class WardrobeFilterByCategory extends WardrobeEvent {
  final String category;

  const WardrobeFilterByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class WardrobeSearchItems extends WardrobeEvent {
  final String query;

  const WardrobeSearchItems(this.query);

  @override
  List<Object> get props => [query];
}

class WardrobeClearSearch extends WardrobeEvent {}

class WardrobeSelectItem extends WardrobeEvent {
  final String itemId;

  const WardrobeSelectItem(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class WardrobeClearSelection extends WardrobeEvent {}