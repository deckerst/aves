import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/catalog.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin SingleEntryEditorMixin on FeedbackMixin, PermissionAwareMixin {
  bool _isMainMode(BuildContext context) => context.read<ValueNotifier<AppMode>>().value == AppMode.main;

  Future<void> edit(BuildContext context, AvesEntry targetEntry, Future<Set<EntryDataType>> Function() apply) async {
    if (!await checkStoragePermission(context, {targetEntry})) return;

    // check before applying, because it relies on provider
    // but the widget tree may be disposed if the user navigated away
    final isMainMode = _isMainMode(context);

    final l10n = context.l10n;
    final source = context.read<CollectionSource?>();
    source?.pauseMonitoring();

    final dataTypes = await apply();
    final success = dataTypes.isNotEmpty;
    try {
      if (success) {
        if (isMainMode && source != null) {
          Set<String> obsoleteTags = targetEntry.tags;
          String? obsoleteCountryCode = targetEntry.addressDetails?.countryCode;

          await source.refreshEntries({targetEntry}, dataTypes);

          // invalidate filters derived from values before edition
          // this invalidation must happen after the source is refreshed,
          // otherwise filter chips may eagerly rebuild in between with the old state
          if (obsoleteCountryCode != null) {
            source.invalidateCountryFilterSummary(countryCodes: {obsoleteCountryCode});
          }
          if (obsoleteTags.isNotEmpty) {
            source.invalidateTagFilterSummary(tags: obsoleteTags);
          }
        } else {
          const background = false;
          const persist = false;
          await targetEntry.refresh(background: background, persist: persist, dataTypes: dataTypes);
          await targetEntry.catalog(background: background, force: dataTypes.contains(EntryDataType.catalog), persist: persist);
          await targetEntry.locate(background: background, force: dataTypes.contains(EntryDataType.address), geocoderLocale: settings.appliedLocale);
        }
        showFeedback(context, l10n.genericSuccessFeedback);
      } else {
        showFeedback(context, l10n.genericFailureFeedback);
      }
    } catch (error, stack) {
      await reportService.recordError(error, stack);
    }
    source?.resumeMonitoring();
  }
}
