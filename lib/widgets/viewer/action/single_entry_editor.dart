import 'dart:async';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/action_mixins/permission_aware.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin SingleEntryEditorMixin on FeedbackMixin, PermissionAwareMixin {
  AvesEntry get entry;

  bool _isMainMode(BuildContext context) => context.read<ValueNotifier<AppMode>>().value == AppMode.main;

  Future<void> edit(BuildContext context, Future<Set<EntryDataType>> Function() apply) async {
    if (!await checkStoragePermission(context, {entry})) return;

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
          Set<String> obsoleteTags = entry.tags;
          String? obsoleteCountryCode = entry.addressDetails?.countryCode;

          await source.refreshEntry(entry, dataTypes);

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
          await entry.refresh(background: false, persist: false, dataTypes: dataTypes, geocoderLocale: settings.appliedLocale);
        }
        showFeedback(context, l10n.genericSuccessFeedback);
      } else {
        showFeedback(context, l10n.genericFailureFeedback);
      }
    } catch (e, stack) {
      await reportService.recordError(e, stack);
    }
    source?.resumeMonitoring();
  }
}
