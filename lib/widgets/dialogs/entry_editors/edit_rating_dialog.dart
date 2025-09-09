import 'package:aves/model/entry/entry.dart';
import 'package:aves/theme/colors.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class EditEntryRatingDialog extends StatefulWidget {
  static const routeName = '/dialog/edit_entry_rating';

  final AvesEntry entry;

  const EditEntryRatingDialog({
    super.key,
    required this.entry,
  });

  @override
  State<EditEntryRatingDialog> createState() => _EditEntryRatingDialogState();
}

class _EditEntryRatingDialogState extends State<EditEntryRatingDialog> {
  late _RatingAction _action;
  late int _rating;

  @override
  void initState() {
    super.initState();
    final entryRating = widget.entry.rating;
    switch (entryRating) {
      case -1:
        _action = _RatingAction.rejected;
        _rating = 0;
      case 0:
        _action = _RatingAction.unrated;
        _rating = 0;
      default:
        _action = _RatingAction.set;
        _rating = entryRating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: TooltipTheme(
        data: TooltipTheme.of(context).copyWith(
          preferBelow: false,
        ),
        child: Builder(
          builder: (context) {
            final l10n = context.l10n;

            return AvesDialog(
              title: l10n.editEntryRatingDialogTitle,
              scrollableContent: [
                RadioGroup(
                  groupValue: _action,
                  onChanged: (v) {
                    if (v != _RatingAction.set) {
                      _rating = 0;
                    }
                    setState(() => _action = v!);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile<_RatingAction>(
                        value: _RatingAction.set,
                        title: Wrap(
                          children: [
                            ...List.generate(5, (i) {
                              final thisRating = i + 1;
                              final disabled = _rating < thisRating;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _action = _RatingAction.set;
                                  _rating = thisRating;
                                }),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    AIcons.rating,
                                    fill: disabled ? 0 : 1,
                                    color: disabled ? AColors.starDisabled : AColors.starEnabled,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      RadioListTile<_RatingAction>(
                        value: _RatingAction.rejected,
                        title: Text(l10n.filterRatingRejectedLabel),
                      ),
                      RadioListTile<_RatingAction>(
                        value: _RatingAction.unrated,
                        title: Text(l10n.filterNoRatingLabel),
                      ),
                    ],
                  ),
                ),
              ],
              actions: [
                const CancelButton(),
                TextButton(
                  onPressed: isValid ? () => _submit(context) : null,
                  child: Text(l10n.applyButtonLabel),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool get isValid => !(_action == _RatingAction.set && _rating <= 0);

  void _submit(BuildContext context) {
    late int entryRating;
    switch (_action) {
      case _RatingAction.set:
        entryRating = _rating;
      case _RatingAction.rejected:
        entryRating = -1;
      case _RatingAction.unrated:
        entryRating = 0;
    }
    Navigator.maybeOf(context)?.pop(entryRating);
  }
}

enum _RatingAction { set, rejected, unrated }
