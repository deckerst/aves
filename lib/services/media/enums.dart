import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

// names should match possible values on platform
enum NameConflictStrategy { rename, replace, skip }

extension ExtraNameConflictStrategy on NameConflictStrategy {
  String toPlatform() => name;

  String getName(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      NameConflictStrategy.rename => l10n.nameConflictStrategyRename,
      NameConflictStrategy.replace => l10n.nameConflictStrategyReplace,
      NameConflictStrategy.skip => l10n.nameConflictStrategySkip,
    };
  }
}
