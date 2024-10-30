import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';

class VideoControlButtonsPage extends StatefulWidget {
  static const routeName = '/settings/video/control_buttons';

  const VideoControlButtonsPage({super.key});

  @override
  State<VideoControlButtonsPage> createState() => _VideoControlButtonsPageState();
}

class _VideoControlButtonsPageState extends State<VideoControlButtonsPage> {
  late final Set<EntryAction> _selectedActions;

  static const _availableActions = [...EntryActions.videoPlayback, EntryAction.openVideo];

  @override
  void initState() {
    super.initState();
    _selectedActions = settings.videoControlActions.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !settings.useTvLayout,
        title: Text(context.l10n.settingsViewerOverlayPageTitle),
      ),
      body: SafeArea(
        child: PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) => settings.videoControlActions = _availableActions.where(_selectedActions.contains).toList(),
          child: ListView(
            children: _availableActions.map((action) {
              return SwitchListTile(
                value: _selectedActions.contains(action),
                onChanged: (v) => setState(() {
                  if (v) {
                    _selectedActions.add(action);
                  } else {
                    _selectedActions.remove(action);
                  }
                }),
                title: Text(action.getText(context)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
