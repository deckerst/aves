import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/item_pick_dialog.dart';
import 'package:aves/widgets/filter_grids/common/covered_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CoverSelectionDialog extends StatefulWidget {
  final CollectionFilter filter;
  final AvesEntry? customEntry;

  const CoverSelectionDialog({
    Key? key,
    required this.filter,
    required this.customEntry,
  }) : super(key: key);

  @override
  _CoverSelectionDialogState createState() => _CoverSelectionDialogState();
}

class _CoverSelectionDialogState extends State<CoverSelectionDialog> {
  late bool _isCustom;
  AvesEntry? _customEntry, _recentEntry;

  CollectionFilter get filter => widget.filter;

  @override
  void initState() {
    super.initState();
    _recentEntry = context.read<CollectionSource>().recentEntry(filter);
    _customEntry = widget.customEntry;
    _isCustom = _customEntry != null;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Builder(
        builder: (context) {
          final l10n = context.l10n;
          final shortestSide = context.select<MediaQueryData, double>((mq) => mq.size.shortestSide);
          final extent = (shortestSide / 3.0).clamp(60.0, 160.0);
          return AvesDialog(
            context: context,
            title: l10n.setCoverDialogTitle,
            scrollableContent: [
              ...[false, true].map(
                (isCustom) {
                  final title = Text(
                    isCustom ? l10n.setCoverDialogCustom : l10n.setCoverDialogLatest,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  );
                  return RadioListTile<bool>(
                    value: isCustom,
                    groupValue: _isCustom,
                    onChanged: (v) {
                      if (v == null) return;
                      if (v && _customEntry == null) {
                        _pickEntry();
                        return;
                      }
                      _isCustom = v;
                      setState(() {});
                    },
                    title: isCustom
                        ? Row(
                            children: [
                              title,
                              const Spacer(),
                              IconButton(
                                icon: const Icon(AIcons.setCover),
                                onPressed: _isCustom ? _pickEntry : null,
                                tooltip: context.l10n.changeTooltip,
                              ),
                            ],
                          )
                        : title,
                  );
                },
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 16),
                child: CoveredFilterChip(
                  filter: filter,
                  extent: extent,
                  coverEntry: _isCustom ? _customEntry : _recentEntry,
                  onTap: (filter) => _pickEntry(),
                  heroType: HeroType.never,
                ),
              ),
            ],
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, Tuple2<bool, AvesEntry?>(_isCustom, _customEntry)),
                child: Text(l10n.applyButtonLabel),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickEntry() async {
    final entry = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: ItemPickDialog.routeName),
        builder: (context) => ItemPickDialog(
          collection: CollectionLens(
            source: context.read<CollectionSource>(),
            filters: {filter},
          ),
        ),
        fullscreenDialog: true,
      ),
    );
    if (entry != null) {
      _customEntry = entry;
      _isCustom = true;
      setState(() {});
    }
  }
}
