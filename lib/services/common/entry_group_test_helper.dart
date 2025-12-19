import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/entry_group_service.dart';
import 'package:flutter/foundation.dart';

/// Test helper for manual photo grouping feature.
/// Use this to verify database integration is working.
class EntryGroupTestHelper {
  static final entryGroupService = EntryGroupService();

  /// Creates a test group with the given entries
  static Future<void> createTestGroup(List<AvesEntry> entries) async {
    if (entries.length < 2) {
      debugPrint('❌ Need at least 2 entries to create a group');
      return;
    }

    try {
      final group = await entryGroupService.createGroup(
        name: 'Test Group ${DateTime.now().millisecondsSinceEpoch}',
        entries: entries,
      );

      debugPrint('✅ Created group: ${group.name} (ID: ${group.id}) with ${group.memberCount} photos');
    } catch (e) {
      debugPrint('❌ Error creating group: $e');
    }
  }

  /// Lists all existing groups
  static Future<void> listAllGroups() async {
    try {
      final groups = await entryGroupService.getAllGroups();
      debugPrint('📚 Total groups: ${groups.length}');

      for (final group in groups) {
        debugPrint('  - ${group.name} (ID: ${group.id}, Members: ${group.memberCount})');
      }
    } catch (e) {
      debugPrint('❌ Error listing groups: $e');
    }
  }

  /// Loads members for a specific group
  static Future<void> loadGroupMembers(int groupId) async {
    try {
      final members = await entryGroupService.getGroupMembers(groupId);
      debugPrint('👥 Group $groupId has ${members.length} members:');

      for (final member in members) {
        debugPrint('  - ${member.bestTitle} (ID: ${member.id})');
      }
    } catch (e) {
      debugPrint('❌ Error loading members: $e');
    }
  }

  /// Adds entries to an existing group
  static Future<void> addToGroup(int groupId, List<AvesEntry> entries) async {
    try {
      await entryGroupService.addEntriesToGroup(
        groupId: groupId,
        entries: entries,
      );
      debugPrint('✅ Added ${entries.length} entries to group $groupId');
    } catch (e) {
      debugPrint('❌ Error adding to group: $e');
    }
  }

  /// Removes entries from a group
  static Future<void> removeFromGroup(int groupId, List<int> entryIds) async {
    try {
      await entryGroupService.removeEntriesFromGroup(
        groupId: groupId,
        entryIds: entryIds,
      );
      debugPrint('✅ Removed ${entryIds.length} entries from group $groupId');
    } catch (e) {
      debugPrint('❌ Error removing from group: $e');
    }
  }

  /// Renames a group
  static Future<void> renameGroup(int groupId, String newName) async {
    try {
      await entryGroupService.renameGroup(groupId, newName);
      debugPrint('✅ Renamed group $groupId to "$newName"');
    } catch (e) {
      debugPrint('❌ Error renaming group: $e');
    }
  }

  /// Deletes a group
  static Future<void> deleteGroup(int groupId) async {
    try {
      await entryGroupService.deleteGroup(groupId);
      debugPrint('✅ Deleted group $groupId');
    } catch (e) {
      debugPrint('❌ Error deleting group: $e');
    }
  }

  /// Complete test flow
  static Future<void> runFullTest(List<AvesEntry> testEntries) async {
    debugPrint('\n🧪 Starting Entry Group Test...\n');

    // Step 1: List existing groups
    debugPrint('Step 1: List existing groups');
    await listAllGroups();
    debugPrint('');

    // Step 2: Create a test group
    if (testEntries.length >= 3) {
      debugPrint('Step 2: Create test group with 3 photos');
      await createTestGroup(testEntries.take(3).toList());
      debugPrint('');

      // Step 3: List groups again
      debugPrint('Step 3: Verify group was created');
      final groups = await entryGroupService.getAllGroups();
      if (groups.isNotEmpty) {
        final latestGroup = groups.first;
        debugPrint('✅ Latest group: ${latestGroup.name} (ID: ${latestGroup.id})');
        debugPrint('');

        // Step 4: Load members
        debugPrint('Step 4: Load group members');
        await loadGroupMembers(latestGroup.id!);
        debugPrint('');

        // Step 5: Add more members (if available)
        if (testEntries.length >= 5) {
          debugPrint('Step 5: Add 2 more photos to group');
          await addToGroup(latestGroup.id!, testEntries.skip(3).take(2).toList());
          await loadGroupMembers(latestGroup.id!);
          debugPrint('');
        }

        // Step 6: Rename
        debugPrint('Step 6: Rename group');
        await renameGroup(latestGroup.id!, 'My Renamed Test Group');
        await listAllGroups();
        debugPrint('');

        // Step 7: Remove a member
        if (testEntries.isNotEmpty) {
          debugPrint('Step 7: Remove one photo from group');
          await removeFromGroup(latestGroup.id!, [testEntries.first.id]);
          await loadGroupMembers(latestGroup.id!);
          debugPrint('');
        }

        // Step 8: Clean up (optional - comment out to keep test group)
        // debugPrint('Step 8: Delete test group');
        // await deleteGroup(latestGroup.id!);
        // await listAllGroups();
        // debugPrint('');

        debugPrint('✅ Test completed successfully!\n');
      }
    } else {
      debugPrint('❌ Need at least 5 entries to run full test\n');
    }
  }
}

/// Example usage in a widget:
///
/// ```dart
/// FloatingActionButton(
///   onPressed: () async {
///     final entries = collection.sortedEntries.take(5).toList();
///     await EntryGroupTestHelper.runFullTest(entries);
///   },
///   child: Icon(Icons.science),
///   tooltip: 'Test Entry Groups',
/// )
/// ```
