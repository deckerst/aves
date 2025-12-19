import 'package:aves/model/entry/entry.dart';
import 'package:flutter/foundation.dart';

/// Represents a manually created group of photos.
/// Groups allow users to organize related photos together without
/// moving them into separate albums.
class EntryGroup with ChangeNotifier {
  /// Unique identifier for this group (database ID)
  int? id;

  /// User-defined name for the group (e.g., "Island 2023", "Bike Sale")
  String name;

  /// Timestamp when the group was created (milliseconds since epoch)
  final int dateCreatedMillis;

  /// ID of the entry to use as the cover/thumbnail for this group
  /// If null, the first entry in the group is used
  int? coverEntryId;

  /// Sort order for displaying groups (lower numbers appear first)
  int sortOrder;

  /// In-memory cache of group members
  /// Loaded lazily to avoid performance issues with large groups
  List<AvesEntry> _members = [];

  /// IDs of all members in the group
  Set<int> _memberIds = {};

  /// Indicates whether the members list has been loaded from the database
  bool _membersLoaded = false;

  EntryGroup({
    this.id,
    required this.name,
    required this.dateCreatedMillis,
    this.coverEntryId,
    this.sortOrder = 0,
    List<AvesEntry>? members,
    Set<int>? memberIds,
  }) {
    if (members != null) {
      _members = members;
      _memberIds = members.map((e) => e.id).toSet();
      _membersLoaded = true;
    } else if (memberIds != null) {
      _memberIds = memberIds;
    }
  }

  /// Returns IDs of all members
  Set<int> get memberIds => Set.unmodifiable(_memberIds);

  /// Returns an unmodifiable view of the group members
  List<AvesEntry> get members => List.unmodifiable(_members);

  /// Returns the number of photos in this group
  int get memberCount => _membersLoaded ? _members.length : _memberIds.length;

  /// Returns true if the members list has been loaded
  bool get isMembersLoaded => _membersLoaded;

  /// Returns the entry to use as the cover/thumbnail
  /// Falls back to the first entry if coverEntryId is not set or not found
  AvesEntry? get coverEntry {
    if (coverEntryId != null && _members.isNotEmpty) {
      try {
        return _members.firstWhere((e) => e.id == coverEntryId);
      } catch (_) {
        // coverEntryId not found, fall through to default
      }
    }
    return _members.isNotEmpty ? _members.first : null;
  }

  /// Sets the members list (typically called after loading from database)
  void setMembers(List<AvesEntry> entries) {
    _members = entries;
    _memberIds = entries.map((e) => e.id).toSet();
    _membersLoaded = true;
    notifyListeners();
  }

  /// Adds a member to the group
  void addMember(AvesEntry entry) {
    if (!_members.contains(entry)) {
      _members.add(entry);
      _memberIds.add(entry.id);
      notifyListeners();
    }
  }

  /// Adds multiple members to the group
  void addMembers(List<AvesEntry> entries) {
    bool changed = false;
    for (final entry in entries) {
      if (!_members.contains(entry)) {
        _members.add(entry);
        changed = true;
      }
    }
    if (changed) {
      _memberIds.addAll(entries.map((e) => e.id));
      notifyListeners();
    }
  }

  /// Removes a member from the group
  void removeMember(AvesEntry entry) {
    if (_members.remove(entry)) {
      _memberIds.remove(entry.id);
      // If the removed entry was the cover, reset cover to null
      // (will automatically use first entry)
      if (coverEntryId == entry.id) {
        coverEntryId = null;
      }
      notifyListeners();
    }
  }

  /// Removes multiple members from the group
  void removeMembers(List<int> entryIds) {
    final originalLength = _members.length;
    for (final id in entryIds) {
      _members.removeWhere((e) => e.id == id);
      _memberIds.remove(id);
      if (coverEntryId == id) {
        coverEntryId = null;
      }
    }
    if (_members.length != originalLength) {
      notifyListeners();
    }
  }

  /// Updates the cover photo for this group
  void updateCover(AvesEntry entry) {
    if (_members.contains(entry)) {
      coverEntryId = entry.id;
      notifyListeners();
    }
  }

  /// Reorders the members list
  void reorderMembers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final entry = _members.removeAt(oldIndex);
    _members.insert(newIndex, entry);
    notifyListeners();
  }

  /// Converts this group to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      EntryGroupFields.id: id,
      EntryGroupFields.name: name,
      EntryGroupFields.dateCreatedMillis: dateCreatedMillis,
      EntryGroupFields.coverEntryId: coverEntryId,
      EntryGroupFields.sortOrder: sortOrder,
    };
  }

  /// Creates an EntryGroup from a database Map
  factory EntryGroup.fromMap(Map<String, dynamic> map) {
    return EntryGroup(
      id: map[EntryGroupFields.id] as int?,
      name: map[EntryGroupFields.name] as String,
      dateCreatedMillis: map[EntryGroupFields.dateCreatedMillis] as int,
      coverEntryId: map[EntryGroupFields.coverEntryId] as int?,
      sortOrder: map[EntryGroupFields.sortOrder] as int? ?? 0,
    );
  }

  /// Creates a copy of this group with the specified fields updated
  EntryGroup copyWith({
    int? id,
    String? name,
    int? dateCreatedMillis,
    int? coverEntryId,
    int? sortOrder,
    List<AvesEntry>? members,
    Set<int>? memberIds,
  }) {
    return EntryGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      dateCreatedMillis: dateCreatedMillis ?? this.dateCreatedMillis,
      coverEntryId: coverEntryId ?? this.coverEntryId,
      sortOrder: sortOrder ?? this.sortOrder,
      members: members ?? _members,
      memberIds: memberIds ?? members?.map((e) => e.id).toSet() ?? _memberIds,
    );
  }

  @override
  String toString() => 'EntryGroup{id: $id, name: $name, memberCount: $memberCount}';

  @override
  bool operator ==(Object other) => identical(this, other) || other is EntryGroup && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Field names for the entry_groups database table
class EntryGroupFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String dateCreatedMillis = 'dateCreatedMillis';
  static const String coverEntryId = 'coverEntryId';
  static const String sortOrder = 'sortOrder';
}

/// Field names for the entry_group_members database table
class EntryGroupMemberFields {
  static const String groupId = 'groupId';
  static const String entryId = 'entryId';
  static const String position = 'position';
}
