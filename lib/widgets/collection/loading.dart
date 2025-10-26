import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/events.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoadingEmptyContent extends StatelessWidget {
  final CollectionSource source;

  const LoadingEmptyContent({
    super.key,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final countFormatter = NumberFormat.decimalPattern(context.locale);
    final progressTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .5),
      fontSize: 18,
    );

    return EmptyContent(
      text: context.l10n.sourceStateLoading,
      bottom: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const ReportProgressIndicator(),
            ValueListenableBuilder<ProgressEvent>(
              valueListenable: source.progressNotifier,
              builder: (context, progress, snapshot) {
                final done = progress.done;
                return done > 0
                    ? Text(
                        countFormatter.format(done),
                        style: progressTextStyle,
                      )
                    : const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
