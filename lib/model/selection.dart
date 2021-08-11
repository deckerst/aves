import 'package:flutter/foundation.dart';

class Selection<T> extends ChangeNotifier {
  bool _isSelecting = false;

  bool get isSelecting => _isSelecting;

  final Set<T> _selectedItems = {};

  Set<T> get selectedItems => _selectedItems;

  void browse() {
    if (!_isSelecting) return;
    clearSelection();
    _isSelecting = false;
    notifyListeners();
  }

  void select() {
    if (_isSelecting) return;
    _isSelecting = true;
    notifyListeners();
  }

  bool isSelected(Iterable<T> items) => items.every(selectedItems.contains);

  void addToSelection(Iterable<T> items) {
    if (items.isEmpty) return;
    _selectedItems.addAll(items);
    notifyListeners();
  }

  void removeFromSelection(Iterable<T> items) {
    if (items.isEmpty) return;
    _selectedItems.removeAll(items);
    notifyListeners();
  }

  void clearSelection() {
    _selectedItems.clear();
    notifyListeners();
  }

  void toggleSelection(T item) {
    if (_selectedItems.isEmpty) select();
    if (!_selectedItems.remove(item)) _selectedItems.add(item);
    notifyListeners();
  }
}
