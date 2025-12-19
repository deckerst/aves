import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/entry_group.dart';
import 'package:aves/services/common/services.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';

/// Service for managing photo groups.
/// Handles CRUD operations, persistence, and event notifications.
class EntryGroupService with ChangeNotifier {
  static final EntryGroupService _instance = EntryGroupService._internal();
  factory EntryGroupService() => _instance;
  EntryGroupService._internal();

  final EventBus eventBus = EventBus();

  /// In-memory cache of all groups
  final Map<int, EntryGroup> _groupsById = {};

  /// Flag indicating whether groups have been loaded from database
  bool _isInitialized = false;

  /// Returns cached groups synchronously
  List<EntryGroup> get cachedGroups => _groupsById.values.toList()..sort((a, b) => b.dateCreatedMillis.compareTo(a.dateCreatedMillis));

  bool get isInitialized => _isInitialized;

  /// Returns member IDs for a group synchronously from cache
  Set<int> getGroupMemberIds(int groupId) {
    return _groupsById[groupId]?.memberIds ?? {};
  }

  Future<void>? _initFuture;

  /// Returns all groups, loading from database if necessary
  Future<List<EntryGroup>> getAllGroups() async {
    if (!_isInitialized) {
      _initFuture ??= _loadGroups();
      await _initFuture;
    }
    return _groupsById.values.toList()..sort((a, b) => b.dateCreatedMillis.compareTo(a.dateCreatedMillis));
  }

  /// Returns a specific group by ID
  Future<EntryGroup?> getGroup(int groupId) async {
    if (!_isInitialized) {
      await _loadGroups();
    }
    return _groupsById[groupId];
  }

  /// Creates a new group with the specified entries
  Future<EntryGroup> createGroup({
    required String name,
    required List<AvesEntry> entries,
    int? coverEntryId,
  }) async {
    if (entries.isEmpty) {
      throw ArgumentError('Cannot create group with no entries');
    }

    // Ensure only entries with valid IDs are grouped
    final validEntries = entries.toList();
    if (validEntries.isEmpty) {
      throw ArgumentError('None of the selected entries have a database ID. Please wait for cataloguing to finish.');
    }

    // Ensure we are initialized so we can access the DB
    await getAllGroups();

    final group = EntryGroup(
      name: name,
      dateCreatedMillis: DateTime.now().millisecondsSinceEpoch,
      coverEntryId: coverEntryId,
      members: validEntries,
    );

    // Save to database
    final groupId = await _saveGroupToDb(group, validEntries);
    group.id = groupId;

    // Add to cache
    _groupsById[groupId] = group;

    // Notify listeners
    notifyListeners();
    eventBus.fire(EntryGroupCreatedEvent(group));

    debugPrint('Created group: ${group.name} with ${validEntries.length} entries (ID: ${group.id})');
    return group;
  }

  /// Updates an existing group's metadata
  Future<void> updateGroup(EntryGroup group) async {
    if (group.id == null) {
      throw ArgumentError('Cannot update group without ID');
    }

    // Update in database
    await _updateGroupInDb(group);

    // Update cache
    _groupsById[group.id!] = group;

    // Notify listeners
    notifyListeners();
    eventBus.fire(EntryGroupUpdatedEvent(group));

    debugPrint('Updated group: ${group.name}');
  }

  /// Renames a group
  Future<void> renameGroup(int groupId, String newName) async {
    final group = await getGroup(groupId);
    if (group == null) {
      throw ArgumentError('Group not found: $groupId');
    }

    final updatedGroup = group.copyWith(name: newName);
    await updateGroup(updatedGroup);
  }

  /// Deletes a group (photos remain in the gallery)
  Future<void> deleteGroup(int groupId) async {
    final group = _groupsById[groupId];
    if (group == null) return;

    // Delete from database
    await _deleteGroupFromDb(groupId);

    // Remove from cache
    _groupsById.remove(groupId);

    // Notify listeners
    notifyListeners();
    eventBus.fire(EntryGroupDeletedEvent(group));

    debugPrint('Deleted group: ${group.name}');
  }

  /// Adds entries to an existing group
  Future<void> addEntriesToGroup({
    required int groupId,
    required List<AvesEntry> entries,
  }) async {
    final group = await getGroup(groupId);
    if (group == null) {
      throw ArgumentError('Group not found: $groupId');
    }

    // Add entries to group
    group.addMembers(entries);

    // Save to database
    await _addMembersToDb(groupId, entries);

    // Notify listeners
    notifyListeners();
    eventBus.fire(EntryGroupMembersAddedEvent(group, entries));

    debugPrint('Added ${entries.length} entries to group: ${group.name}');
  }

  /// Removes entries from a group
  Future<void> removeEntriesFromGroup({
    required int groupId,
    required List<int> entryIds,
  }) async {
    final group = await getGroup(groupId);
    if (group == null) return;

    // Remove entries from group
    group.removeMembers(entryIds);

    // Update database
    await _removeMembersFromDb(groupId, entryIds);

    // If group is now empty, delete it
    if (group.memberCount == 0) {
      await deleteGroup(groupId);
    } else {
      // Notify listeners
      notifyListeners();
      eventBus.fire(EntryGroupMembersRemovedEvent(group, entryIds));
    }

    debugPrint('Removed ${entryIds.length} entries from group: ${group.name}');
  }

  /// Returns all group members for a specific group
  Future<List<AvesEntry>> getGroupMembers(int groupId) async {
    final group = await getGroup(groupId);
    if (group == null) return [];

    // Load members if not already loaded
    if (!group.isMembersLoaded) {
      final members = await _loadGroupMembersFromDb(groupId);
      group.setMembers(members);
    }

    return group.members;
  }

  /// Returns all groups that contain a specific entry
  Future<List<EntryGroup>> getGroupsContainingEntry(int entryId) async {
    await getAllGroups(); // Ensure groups are loaded

    final containingGroups = <EntryGroup>[];
    for (final group in _groupsById.values) {
      // Load members if necessary
      if (!group.isMembersLoaded) {
        await getGroupMembers(group.id!);
      }

      if (group.members.any((e) => e.id == entryId)) {
        containingGroups.add(group);
      }
    }

    return containingGroups;
  }

  /// Returns true if an entry is in any group
  Future<bool> isEntryInAnyGroup(int entryId) async {
    final groups = await getGroupsContainingEntry(entryId);
    return groups.isNotEmpty;
  }

  /// Handles when an entry is deleted from the device
  /// Removes it from all groups and deletes empty groups
  Future<void> onEntryDeleted(AvesEntry entry) async {
    final groups = await getGroupsContainingEntry(entry.id);

    for (final group in groups) {
      await removeEntriesFromGroup(
        groupId: group.id!,
        entryIds: [entry.id],
      );
    }
  }

  /// Handles when multiple entries are deleted
  Future<void> onEntriesDeleted(List<AvesEntry> entries) async {
    for (final entry in entries) {
      await onEntryDeleted(entry);
    }
  }

  // Private database methods (to be implemented)

  Future<void> _loadGroups() async {
    debugPrint('Loading groups from database...');
    await localMediaDb.init();

    final maps = await localMediaDb.loadAllEntryGroups();
    final memberIdsRows = await localMediaDb.loadAllEntryGroupMemberIds();

    // Process member IDs
    final groupMembers = <int, Set<int>>{};
    for (final row in memberIdsRows) {
      final groupId = row['groupId'] as int;
      final entryId = row['entryId'] as int;
      groupMembers.putIfAbsent(groupId, () => {}).add(entryId);
    }

    _groupsById.clear();
    for (final map in maps) {
      final tempGroup = EntryGroup.fromMap(map);
      // Hydrate with member IDs
      final memberIds = groupMembers[tempGroup.id] ?? {};
      final group = tempGroup.copyWith(memberIds: memberIds);
      _groupsById[group.id!] = group;
    }

    _isInitialized = true;
  }

  Future<int> _saveGroupToDb(EntryGroup group, List<AvesEntry> members) async {
    // Insert group
    final groupId = await localMediaDb.insertEntryGroup(group.toMap());

    // Insert members
    for (int i = 0; i < members.length; i++) {
      await localMediaDb.insertEntryGroupMember(groupId, members[i].id, i);
    }

    return groupId;
  }

  Future<void> _updateGroupInDb(EntryGroup group) async {
    await localMediaDb.updateEntryGroup(group.toMap());
  }

  Future<void> _deleteGroupFromDb(int groupId) async {
    await localMediaDb.deleteEntryGroup(groupId);
  }

  Future<void> _addMembersToDb(int groupId, List<AvesEntry> entries) async {
    final currentCount = await localMediaDb.getEntryGroupMemberCount(groupId);
    for (int i = 0; i < entries.length; i++) {
      await localMediaDb.insertEntryGroupMember(groupId, entries[i].id, currentCount + i);
    }
  }

  Future<void> _removeMembersFromDb(int groupId, List<int> entryIds) async {
    await localMediaDb.deleteEntryGroupMembers(groupId, entryIds);
  }

  Future<List<AvesEntry>> _loadGroupMembersFromDb(int groupId) async {
    final maps = await localMediaDb.loadEntryGroupMembers(groupId);
    return maps.map((map) => AvesEntry.fromMap(map)).toList();
  }
}

// Events

class EntryGroupCreatedEvent {
  final EntryGroup group;
  EntryGroupCreatedEvent(this.group);
}

class EntryGroupUpdatedEvent {
  final EntryGroup group;
  EntryGroupUpdatedEvent(this.group);
}

class EntryGroupDeletedEvent {
  final EntryGroup group;
  EntryGroupDeletedEvent(this.group);
}

class EntryGroupMembersAddedEvent {
  final EntryGroup group;
  final List<AvesEntry> addedEntries;
  EntryGroupMembersAddedEvent(this.group, this.addedEntries);
}

class EntryGroupMembersRemovedEvent {
  final EntryGroup group;
  final List<int> removedEntryIds;
  EntryGroupMembersRemovedEvent(this.group, this.removedEntryIds);
}

/// Global instance of the entry group service
final entryGroupService = EntryGroupService();
