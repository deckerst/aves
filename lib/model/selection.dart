import 'package:flutter/foundation.dart';

typedef ToSelectableItems<T> = Set<T> Function(T item);

class Selection<T> extends ChangeNotifier {
  late final Iterable<T> Function(Iterable<T> items) _expandToSelectableItems;

  bool _isSelecting = false;

  bool get isSelecting => _isSelecting;

  final Set<T> _selectedItems = {};

  int get selectedItemCount => _selectedItems.length;

  Set<T> get selectedItems => Set.unmodifiable(_selectedItems);

  Selection({required ToSelectableItems<T>? toSelectableItems}) {
    if (kFlutterMemoryAllocationsEnabled) ChangeNotifier.maybeDispatchObjectCreation(this);

    if (toSelectableItems != null) {
      _expandToSelectableItems = (items) => items.expand(toSelectableItems);
    } else {
      _expandToSelectableItems = (items) => items;
    }
  }

  void browse() {
    if (!_isSelecting) return;
    _isSelecting = false;
    _selectedItems.clear();
    notifyListeners();
  }

  void select() {
    if (_isSelecting) return;
    // clear selection on `select`, not on `browse`, so that
    // the selection count is stable when transitioning to browse
    clearSelection();
    _isSelecting = true;
    notifyListeners();
  }

  bool isSelected(Iterable<T> items) => _expandToSelectableItems(items).every(_selectedItems.contains);

  int countSelectable(Iterable<T> items) => _expandToSelectableItems(items).length;

  int countSelected(Iterable<T> items) => _expandToSelectableItems(items).where(_selectedItems.contains).length;

  void addToSelection(Iterable<T> items) {
    if (items.isEmpty) return;

    select();
    _selectedItems.addAll(_expandToSelectableItems(items));
    notifyListeners();
  }

  void removeFromSelection(Iterable<T> items) {
    if (items.isEmpty) return;

    _selectedItems.removeAll(_expandToSelectableItems(items));
    notifyListeners();
  }

  void clearSelection() {
    _selectedItems.clear();
    notifyListeners();
  }

  void toggleSelection(T item) {
    if (!_isSelecting) select();

    final selectableItems = _expandToSelectableItems({item});
    final selected = isSelected(selectableItems);
    if (selected) {
      _selectedItems.removeAll(selectableItems);
    } else {
      _selectedItems.addAll(selectableItems);
    }
    notifyListeners();
  }
}
