import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:provider/provider.dart';

class PatternDialog extends StatefulWidget {
  static const routeName = '/dialog/pattern';

  final bool needConfirmation;

  const PatternDialog({
    super.key,
    required this.needConfirmation,
  });

  @override
  State<PatternDialog> createState() => _PatternDialogState();
}

class _PatternDialogState extends State<PatternDialog> {
  bool _confirming = false;
  String? _firstPattern;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AvesDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_confirming ? context.l10n.patternDialogConfirm : context.l10n.patternDialogEnter),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox.square(
              dimension: context.select<MediaQueryData, double>((mq) => mq.size.shortestSide / 2),
              child: PatternLock(
                relativePadding: .4,
                selectedColor: colorScheme.secondary,
                notSelectedColor: colorScheme.onBackground,
                pointRadius: 8,
                fillPoints: true,
                onInputComplete: (input) => _submit(input.join()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(String pattern) {
    if (widget.needConfirmation) {
      if (_confirming) {
        final match = _firstPattern == pattern;
        Navigator.maybeOf(context)?.pop<String>(match ? pattern : null);
        if (!match) {
          showDialog(
            context: context,
            builder: (context) => AvesDialog(
              content: Text(context.l10n.genericFailureFeedback),
              actions: const [OkButton()],
            ),
            routeSettings: const RouteSettings(name: AvesDialog.warningRouteName),
          );
        }
      } else {
        _firstPattern = pattern;
        setState(() => _confirming = true);
      }
    } else {
      Navigator.maybeOf(context)?.pop<String>(pattern);
    }
  }
}
