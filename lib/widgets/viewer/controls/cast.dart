import 'dart:async';
import 'dart:io';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/ref/upnp.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/dialogs/cast_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:upnp2/upnp.dart';

mixin CastMixin {
  Device? _renderer;
  HttpServer? _mediaServer;

  bool get isCasting => _renderer != null && _mediaServer != null;

  Future<void> initCast(BuildContext context, List<AvesEntry> entries) async {
    await stopCast();

    final renderer = await _selectRenderer(context);
    _renderer = renderer;
    if (renderer == null) return;
    debugPrint('cast: select renderer `${renderer.friendlyName}` at ${renderer.urlBase}');

    final ip = await NetworkInfo().getWifiIP();
    if (ip == null) return;

    final handler = const Pipeline().addHandler((request) async {
      final id = int.tryParse(request.url.path);
      if (id != null) {
        final entry = entries.firstWhereOrNull((v) => v.id == id);
        if (entry != null) {
          final bytes = await mediaFetchService.getImage(
            entry.uri,
            entry.mimeType,
            rotationDegrees: entry.rotationDegrees,
            isFlipped: entry.isFlipped,
            pageId: entry.pageId,
            sizeBytes: entry.sizeBytes,
          );
          debugPrint('cast: send ${bytes.length} bytes for entry=$entry');
          return Response.ok(
            bytes,
            headers: {
              'Content-Type': entry.mimeType,
            },
          );
        }
      }
      return Response.notFound('no resource for url=${request.url}');
    });
    _mediaServer = await shelf_io.serve(handler, ip, 8080);
    debugPrint('cast: serving media on $_serverBaseUrl}');
  }

  Future<void> stopCast() async {
    if (isCasting) {
      debugPrint('cast: stop');
    }

    await _mediaServer?.close();
    _mediaServer = null;

    // await _renderer?.stop();
    _renderer = null;
  }

  Future<Device?> _selectRenderer(BuildContext context) async {
    return await showDialog<Device?>(
      context: context,
      builder: (context) => const CastDialog(),
      routeSettings: const RouteSettings(name: CastDialog.routeName),
    );
  }

  Future<void> castEntry(AvesEntry entry) async {
    final server = _mediaServer;
    final renderer = _renderer;
    if (server == null || renderer == null) return;

    debugPrint('cast: set entry=$entry');
    try {
      await _setAVTransportURI(
        '$_serverBaseUrl/${entry.id}',
        entry.bestTitle ?? '${entry.id}',
        entry.mimeType,
      );
      await _play();
    } catch (error, stack) {
      await reportService.recordError(error, stack);
    }
  }

  String? get _serverBaseUrl {
    final server = _mediaServer;
    return server != null ? 'http://${server.address.host}:${server.port}' : null;
  }

  Future<Service?> get _avTransportService async {
    return _renderer!.getService(Upnp.upnpServiceTypeAVTransport);
  }

  Future<Map<String, String>> _setAVTransportURI(String url, String title, String mimeType) async {
    final service = await _avTransportService;
    if (service == null) return {};

    var meta = '';
    if (MimeTypes.isVideo(mimeType)) {
      meta = '''<DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:sec="http://www.sec.co.kr/"><item id="false" parentID="1" restricted="0"><dc:title>$title</dc:title><dc:creator>unkown</dc:creator><upnp:class>object.item.videoItem</upnp:class><res resolution="4"></res></item></DIDL-Lite>''';
    } else if (MimeTypes.isImage(mimeType)) {
      meta = '''<DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:sec="http://www.sec.co.kr/"><item id="false" parentID="1" restricted="0"><dc:title>$title</dc:title><dc:creator>unkown</dc:creator><upnp:class>object.item.imageItem</upnp:class><res resolution="4"></res></item></DIDL-Lite>''';
    }
    var args = {
      'InstanceID': 0,
      'CurrentURI': url,
      'CurrentURIMetaData': meta,
    };
    return service.invokeAction('SetAVTransportURI', args);
  }

  Future<Map<String, String>> _play() async {
    final service = await _avTransportService;
    if (service == null) return {};

    return service.invokeAction('Play', {
      'InstanceID': 0,
      'Speed': 1,
    });
  }
}
