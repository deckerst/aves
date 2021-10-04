import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';

// names should match possible values on platform
enum NameConflictStrategy { rename, replace, skip }

extension ExtraNameConflictStrategy on NameConflictStrategy {
  String toPlatform() => toString().substring('NameConflictStrategy.'.length);

  String getName(BuildContext context) {
    switch (this) {
      case NameConflictStrategy.rename:
        return context.l10n.nameConflictStrategyRename;
      case NameConflictStrategy.replace:
        return context.l10n.nameConflictStrategyReplace;
      case NameConflictStrategy.skip:
        return context.l10n.nameConflictStrategySkip;
    }
  }
}
