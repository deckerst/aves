import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/ref/upnp.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/dialogs/cast_dialog.dart';
import 'package:collection/collection.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:xml/xml.dart';

mixin CastMixin {
  DLNADevice? _renderer;
  HttpServer? _mediaServer;

  bool get isCasting => _renderer != null && _mediaServer != null;

  Future<void> initCast(BuildContext context, List<AvesEntry> entries) async {
    await stopCast();

    final renderer = await _selectRenderer(context);
    _renderer = renderer;
    if (renderer == null) return;
    debugPrint('cast: select renderer `${renderer.info.friendlyName}` at ${renderer.info.URLBase}');

    final ip = await NetworkInfo().getWifiIP();
    if (ip == null) return;

    Set<String>? supportedMimeTypes;

    final handler = const Pipeline().addHandler((request) async {
      debugPrint('cast: received request for id=${request.url}');
      final id = int.tryParse(request.url.path);
      if (id == null) {
        return Response.notFound('invalid url=${request.url}');
      }

      final entry = entries.firstWhereOrNull((v) => v.id == id);
      if (entry == null) {
        return Response.notFound('no resource for url=${request.url}');
      }

      if (supportedMimeTypes == null) {
        // do not call `GetProtocolInfo` before serving files,
        // as it somehow makes `Play` time out (but not `SetAVTransportURI`)
        supportedMimeTypes = await renderer.getSinkSupportedMimeTypes();
        debugPrint('cast: supported MIME types=$supportedMimeTypes');
      }

      // TODO TLAD [cast] transcode when MIME type is not supported by renderer

      return await _sendEntry(entry);
    });
    _mediaServer = await shelf_io.serve(handler, ip, 8080);
    debugPrint('cast: serving media on $_serverBaseUrl');
  }

  Future<void> stopCast() async {
    if (isCasting) {
      debugPrint('cast: stop');
    }

    await _mediaServer?.close();
    _mediaServer = null;

    await _renderer?.stop();
    _renderer = null;
  }

  Future<DLNADevice?> _selectRenderer(BuildContext context) async {
    return await showDialog<DLNADevice?>(
      context: context,
      builder: (context) => const CastDialog(),
      routeSettings: const RouteSettings(name: CastDialog.routeName),
    );
  }

  Future<void> castEntry(AvesEntry entry) async {
    final server = _mediaServer;
    final renderer = _renderer;
    if (server == null || renderer == null) return;

    try {
      debugPrint('cast: set entry=$entry');
      await renderer.setUrl(
        '$_serverBaseUrl/${entry.id}',
        title: entry.bestTitle ?? '',
        type: entry.isVideo ? PlayType.Video : PlayType.Image,
      );
      debugPrint('cast: play entry=$entry');
      unawaited(renderer.play());
    } catch (e, stack) {
      await reportService.recordError(e, stack);
    }
  }

  String? get _serverBaseUrl {
    final server = _mediaServer;
    return server != null ? 'http://${server.address.host}:${server.port}' : null;
  }

  Future<Response> _sendEntry(AvesEntry entry) async {
    // TODO TLAD [cast] providing downscaled versions is suitable when properly serving with `MediaServer`, as the renderer can pick what is best
    final bytes = await mediaFetchService.getOriginalBytes(entry);

    debugPrint('cast: send ${bytes.length} bytes for entry=$entry');
    return Response.ok(
      bytes,
      headers: {
        'Content-Type': entry.mimeType,
      },
    );
  }
}

extension ExtraDLNADevice on DLNADevice {
  Future<String> requestCustom({
    required String serviceId,
    required String serviceType,
    required String action,
    required String data,
  }) async {
    return DLNAHttp.post(
      Uri.parse(controlURL(serviceId)),
      Map.from({
        'SOAPAction': '"$serviceType#$action"',
        'Content-Type': 'text/xml',
      }),
      const Utf8Encoder().convert(data),
    );
  }

  Future<Map<String, UpnpProtocolInfo>> getProtocolInfo() async {
    final result = await requestCustom(
      serviceId: 'ConnectionManager',
      serviceType: Upnp.upnpServiceTypeConnectionManager,
      action: 'GetProtocolInfo',
      data: Upnp.getProtocolInfoActionXml(),
    );
    final doc = XmlDocument.parse(result);
    final sink = UpnpProtocolInfo(doc.findAllElements('Sink').first.innerText);
    final source = UpnpProtocolInfo(doc.findAllElements('Source').first.innerText);
    return {
      'sink': sink,
      'source': source,
    };
  }

  Future<Set<String>?> getSinkSupportedMimeTypes() async {
    final sinkProtocolInfo = (await getProtocolInfo())['sink'];
    if (sinkProtocolInfo != null) {
      final byProtocol = groupBy<UpnpProtocolInfoEntry, String>(sinkProtocolInfo.entries, (v) => v.protocol);
      final httpGet = byProtocol['http-get'];
      if (httpGet != null) {
        return httpGet.map((v) => v.contentFormat).toSet();
      }
    }
    return null;
  }
}
