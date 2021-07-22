import 'package:flutter/foundation.dart';

class Selection<T> extends ChangeNotifier {
  bool _isSelecting = false;

  bool get isSelecting => _isSelecting;

  final Set<T> _selection = {};

  Set<T> get selection => _selection;

  void browse() {
    clearSelection();
    _isSelecting = false;
    notifyListeners();
  }

  void select() {
    _isSelecting = true;
    notifyListeners();
  }

  bool isSelected(Iterable<T> items) => items.every(selection.contains);

  void addToSelection(Iterable<T> items) {
    _selection.addAll(items);
    notifyListeners();
  }

  void removeFromSelection(Iterable<T> items) {
    _selection.removeAll(items);
    notifyListeners();
  }

  void clearSelection() {
    _selection.clear();
    notifyListeners();
  }

  void toggleSelection(T item) {
    if (_selection.isEmpty) select();
    if (!_selection.remove(item)) _selection.add(item);
    notifyListeners();
  }
}
