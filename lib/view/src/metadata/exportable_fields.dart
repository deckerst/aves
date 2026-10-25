import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/widgets.dart';

extension ExtraExportableEntryFields on ExportableEntryField {
  String getText(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      .uri => l10n.viewerInfoLabelUri,
      .path => l10n.viewerInfoLabelPath,
      .title => l10n.viewerInfoLabelTitle,
      .date => l10n.viewerInfoLabelDate,
      .size => l10n.viewerInfoLabelSize,
      .resolution => l10n.viewerInfoLabelResolution,
      .width => l10n.exportEntryDialogWidth,
      .height => l10n.exportEntryDialogHeight,
      .duration => l10n.viewerInfoLabelDuration,
      .coordinates => l10n.viewerInfoLabelCoordinates,
      .address => l10n.viewerInfoLabelAddress,
      .tags => l10n.searchTagsSectionTitle,
    };
  }
}
