import 'package:aves/ref/upnp.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:flutter/material.dart';

class CastDialog extends StatefulWidget {
  static const routeName = '/dialog/cast';

  const CastDialog({super.key});

  @override
  State<CastDialog> createState() => _CastDialogState();
}

class _CastDialogState extends State<CastDialog> {
  final DLNAManager _dlnaManager = DLNAManager();
  final Map<String, DLNADevice> _seenRenderers = {};

  @override
  void initState() {
    super.initState();

    _dlnaManager.start().then((deviceManager) {
      deviceManager.devices.stream.listen((devices) {
        _seenRenderers.addAll(Map.fromEntries(devices.entries.where((kv) => kv.value.info.deviceType == Upnp.upnpDeviceTypeMediaRenderer).map((kv) {
          final device = kv.value;
          return MapEntry(device.info.friendlyName, device);
        })));
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _dlnaManager.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      title: context.l10n.castDialogTitle,
      scrollableContent: [
        if (_seenRenderers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ..._seenRenderers.values.map((dev) => ListTile(
              title: Text(dev.info.friendlyName),
              onTap: () => Navigator.maybeOf(context)?.pop<DLNADevice>(dev),
            )),
      ],
      actions: const [
        CancelButton(),
      ],
    );
  }
}
