import 'dart:async';

import 'package:aves/ref/upnp.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';
import 'package:upnp2/upnp.dart';

class CastDialog extends StatefulWidget {
  static const routeName = '/dialog/cast';

  const CastDialog({super.key});

  @override
  State<CastDialog> createState() => _CastDialogState();
}

class _CastDialogState extends State<CastDialog> {
  final DeviceDiscoverer _discoverer = DeviceDiscoverer();
  Timer? _discoverySearchTimer;
  int _queryIndex = 0;
  final Map<String, Device> _seenRenderers = {};

  @override
  void initState() {
    super.initState();
    _discoverClients(
      [
        Upnp.ssdpQueryAll,
        Upnp.upnpServiceTypeAVTransport,
        Upnp.upnpDeviceTypeMediaRenderer,
      ],
    ).listen((client) async {
      try {
        final device = await client.getDevice();
        if (device != null) {
          final uuid = device.uuid;
          if (uuid != null && device.deviceType == Upnp.upnpDeviceTypeMediaRenderer) {
            _seenRenderers[uuid] = device;
            setState(() {});
          }
        }
      } catch (e) {
        debugPrint('TLAD failed to get device e=$e');
      }
    });
  }

  Stream<DiscoveredClient> _discoverClients(List<String> queries) async* {
    await _discoverer.start(
      ipv6: false,
      onError: (e) => debugPrint('cast: failed to start discoverer with error=$e'),
    );
    _search(queries);
    _discoverySearchTimer = Timer.periodic(const Duration(seconds: 5), (_) => _search(queries));
    await for (var client in _discoverer.clients) {
      yield client;
    }
  }

  void _search(List<String> queries) {
    final searchTarget = queries[_queryIndex];
    debugPrint('cast: search target=$searchTarget');
    _discoverer.search(searchTarget);
    _queryIndex = (_queryIndex + 1) % queries.length;
  }

  @override
  void dispose() {
    _discoverySearchTimer?.cancel();
    _discoverySearchTimer = null;
    _discoverer.stop();
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
              title: Text(dev.friendlyName ?? dev.uuid!),
              onTap: () => Navigator.maybeOf(context)?.pop<Device>(dev),
            )),
      ],
      actions: const [
        CancelButton(),
      ],
    );
  }
}
