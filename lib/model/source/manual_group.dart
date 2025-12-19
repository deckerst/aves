import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/entry_group_service.dart';

mixin ManualGroupMixin on SourceBase {
  void updateManualGroups() {
    final service = EntryGroupService();
    final groups = service.cachedGroups;

    // Clear existing group flags
    for (final entry in allEntries) {
      entry.entryGroup = null;
    }

    for (final group in groups) {
      int? coverId = group.coverEntryId;
      if (coverId == null && group.memberIds.isNotEmpty) {
        coverId = group.memberIds.first; // Or last, depending on preference
      }

      if (coverId != null) {
        final entry = entryById[coverId];
        if (entry != null) {
          entry.entryGroup = group;
        }
      }
    }
  }
}
