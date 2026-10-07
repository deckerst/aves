import 'package:aves/locale/intl.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/about/bug_report.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:aves/widgets/common/identity/buttons/outlined_button.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class const HomeError({
  super.key,
  required final Object error,
  required final StackTrace stack,
}) extends StatefulWidget {
  @override
  State<HomeError> createState() => _HomeErrorState();
}

class _HomeErrorState extends State<HomeError> with FeedbackMixin {
  final ValueNotifier<String?> _expandedNotifier = ValueNotifier(null);

  @override
  void dispose() {
    _expandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  AvesExpansionTile(
                    title: 'Error',
                    expandedNotifier: _expandedNotifier,
                    showHighlight: false,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SelectableText(
                          '${widget.error}:\n${widget.stack}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  AvesExpansionTile(
                    title: l10n.aboutBugSectionTitle,
                    expandedNotifier: _expandedNotifier,
                    showHighlight: false,
                    children: const [BugReportContent()],
                  ),
                  AvesExpansionTile(
                    title: l10n.aboutDataUsageDatabase,
                    expandedNotifier: _expandedNotifier,
                    showHighlight: false,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: AvesOutlinedButton(
                              label: l10n.settingsActionExport,
                              onPressed: () async {
                                final sourcePath = await localMediaDb.path;
                                final date = DateFormat('yyyyMMdd_HHmmss', IntlUtils.rootLocaleName).format(DateTime.now());
                                final success = await storageService.copyFile(
                                  basename: 'aves-database-$date',
                                  mimeType: MimeTypes.sqlite3,
                                  sourceUri: Uri.file(sourcePath).toString(),
                                );
                                if (success != null) {
                                  if (success) {
                                    showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
                                  } else {
                                    showFeedback(context, FeedbackType.warn, context.l10n.genericFailureFeedback);
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
