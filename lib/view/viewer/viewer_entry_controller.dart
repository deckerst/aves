import 'package:flutter/foundation.dart';
import 'package:aves/model/entry/entry.dart';

class ViewerEntryController extends ChangeNotifier {
  List<AvesEntry> _entries;
  AvesEntry? _currentEntry;
  int _currentIndex = 0;

  ViewerEntryController({
    required List<AvesEntry> entries,
    AvesEntry? initialEntry,
  }) : _entries = entries {
    if (initialEntry != null) {
      setCurrentEntry(initialEntry);
    } else if (entries.isNotEmpty) {
      _currentEntry = entries.first;
    }
  }

  List<AvesEntry> get entries => _entries;
  AvesEntry? get currentEntry => _currentEntry;
  int get currentIndex => _currentIndex;

  void setEntries(List<AvesEntry> newEntries) {
    _entries = newEntries;
    if (_currentEntry != null && !newEntries.contains(_currentEntry)) {
      _currentEntry = newEntries.isNotEmpty ? newEntries.first : null;
      _updateCurrentIndex();
    }
    notifyListeners();
  }

  void setCurrentEntry(AvesEntry entry) {
    if (_currentEntry != entry && _entries.contains(entry)) {
      _currentEntry = entry;
      _updateCurrentIndex();
      notifyListeners();
    }
  }

  void jumpToEntry(AvesEntry entry) {
    final index = _entries.indexOf(entry);
    if (index >= 0) {
      _currentEntry = entry;
      _currentIndex = index;
      notifyListeners();
    }
  }

  void nextEntry() {
    if (_currentIndex < _entries.length - 1) {
      _currentIndex++;
      _currentEntry = _entries[_currentIndex];
      notifyListeners();
    }
  }

  void previousEntry() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _currentEntry = _entries[_currentIndex];
      notifyListeners();
    }
  }

  void _updateCurrentIndex() {
    if (_currentEntry != null) {
      _currentIndex = _entries.indexOf(_currentEntry!);
    }
  }
}
