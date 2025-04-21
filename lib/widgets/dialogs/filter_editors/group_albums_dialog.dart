import 'package:aves/model/filters/covered/album_group.dart';
import 'package:aves/model/grouping.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/basic/text_dropdown_button.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/transitions.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/pick_dialogs/album_pick_page.dart';
import 'package:aves/widgets/filter_grids/albums_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupAlbumsDialog extends StatefulWidget {
  static const routeName = '/dialog/group_albums';

  final Uri? parentGroupUri;

  const GroupAlbumsDialog({
    super.key,
    this.parentGroupUri,
  });

  @override
  State<GroupAlbumsDialog> createState() => _GroupAlbumsDialogState();
}

enum GroupAction { create, select }

class _GroupAlbumsDialogState extends State<GroupAlbumsDialog> {
  GroupAction _action = GroupAction.create;
  final TextEditingController _nameController = TextEditingController();
  Uri? _selectedGroupUri;
  final ValueNotifier<bool> _existsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _validate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _existsNotifier.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: TooltipTheme(
        data: TooltipTheme.of(context).copyWith(
          preferBelow: false,
        ),
        child: Builder(builder: (context) {
          final l10n = context.l10n;

          return AvesDialog(
            title: l10n.groupAlbumsDialogTitle,
            scrollableContent: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                child: TextDropdownButton<GroupAction>(
                  values: GroupAction.values,
                  valueText: (v) => _actionText(context, v),
                  value: _action,
                  onChanged: (v) {
                    _action = v!;
                    _validate();
                    setState(() {});
                  },
                  isExpanded: true,
                  dropdownColor: Themes.thirdLayerColor(context),
                ),
              ),
              AnimatedSwitcher(
                duration: context.read<DurationsData>().formTransition,
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: AvesTransitions.formTransitionBuilder,
                child: Column(
                  key: ValueKey(_action),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_action == GroupAction.create) _buildCreateContent(context),
                    if (_action == GroupAction.select) _buildSelectContent(context),
                  ],
                ),
              ),
            ],
            actions: [
              const CancelButton(),
              ValueListenableBuilder<bool>(
                valueListenable: _isValidNotifier,
                builder: (context, isValid, child) {
                  return TextButton(
                    onPressed: isValid ? () => _submit(context) : null,
                    child: Text(l10n.applyButtonLabel),
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCreateContent(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ValueListenableBuilder<bool>(
          valueListenable: _existsNotifier,
          builder: (context, exists, child) {
            return TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.groupAlbumsDialogNameLabel,
                helperText: exists ? l10n.groupAlreadyExists : '',
              ),
              autofocus: true,
              onChanged: (_) => _validate(),
              onSubmitted: (_) => _submit(context),
            );
          }),
    );
  }

  Widget _buildSelectContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(child: _groupText(context, _selectedGroupUri)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(AIcons.albumGroup),
            onPressed: () async {
              final filter = await pickAlbum(context: context, moveType: null, albumTypes: {AlbumChipType.group});
              if (filter is AlbumGroupFilter) {
                setState(() => _selectedGroupUri = filter.uri);
              }
            },
            tooltip: context.l10n.changeTooltip,
          ),
        ],
      ),
    );
  }

  String _actionText(BuildContext context, GroupAction action) {
    final l10n = context.l10n;
    return switch (action) {
      GroupAction.create => l10n.groupActionCreate,
      GroupAction.select => l10n.groupActionSelect,
    };
  }

  Text _groupText(BuildContext context, Uri? groupUri) {
    if (groupUri != null) {
      final path = AlbumGrouping.getGroupPath(groupUri) ?? '';
      return Text(path);
    } else {
      return _unknownText(context);
    }
  }

  Text _unknownText(BuildContext context) {
    final l10n = context.l10n;
    return Text(
      l10n.viewerInfoUnknown,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Uri? _getGroupUri() {
    switch (_action) {
      case GroupAction.create:
        final name = _nameController.text;
        if (name.isEmpty) return null;
        return AlbumGrouping.buildGroupUri(widget.parentGroupUri, name);
      case GroupAction.select:
        return _selectedGroupUri;
    }
  }

  void _validate() {
    switch (_action) {
      case GroupAction.create:
        _isValidNotifier.value = _nameController.text.isNotEmpty && !_existsNotifier.value;
      case GroupAction.select:
        _isValidNotifier.value = _selectedGroupUri != null;
    }
  }

  void _submit(BuildContext context) {
    if (_isValidNotifier.value) {
      Navigator.maybeOf(context)?.pop(_getGroupUri());
    }
  }
}
