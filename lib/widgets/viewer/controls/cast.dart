import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/ref/upnp.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:aves/widgets/dialogs/cast_dialog.dart';
import 'package:collection/collection.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:material_ui/material_ui.dart';
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
    return await showAvesDialog<DLNADevice?>(
      context: context,
      builder: (context) => const CastDialog(),
      routeSettings: const RouteSettings(name: CastDialog.routeName),
    );
  }

  PlayType _toPlayType(String mimeType) {
    if (MimeTypes.isVideo(mimeType)) {
      switch (mimeType) {
        case MimeTypes.mpeg:
          return VideoMime.mpeg;
        case MimeTypes.mp4:
          return VideoMime.mp4;
        case MimeTypes.mkvX:
          return VideoMime.xMatroska;
        case MimeTypes.mov:
          return VideoMime.quicktime;
        case MimeTypes.wmv:
          return VideoMime.xMsWmv;
        case MimeTypes.avi:
          return VideoMime.avi;
        case MimeTypes.flv:
          return VideoMime.flv;
        case MimeTypes.mp2t:
          return VideoMime.ts;
        default:
          return VideoMime.any;
      }
    } else {
      switch (mimeType) {
        case MimeTypes.jpeg:
          return ImageMime.jpeg;
        case MimeTypes.png:
          return ImageMime.png;
        case MimeTypes.tiff:
          return ImageMime.tiff;
        case MimeTypes.gif:
          return ImageMime.gif;
        default:
          return ImageMime.any;
      }
    }
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
        type: _toPlayType(entry.mimeType),
      );
      debugPrint('cast: play entry=$entry');
      unawaited(renderer.play());
    } catch (error, stack) {
      await reportService.recordError(error, stack);
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
  Future<String?> requestCustom({
    required String serviceId,
    required String serviceType,
    required String action,
    required String data,
  }) async {
    try {
      return await DLNAHttp.post(
        Uri.parse(controlURL(serviceId)),
        Map.from({
          'SOAPAction': '"$serviceType#$action"',
          'Content-Type': 'text/xml',
        }),
        const Utf8Encoder().convert(data),
      );
    } catch (error, stack) {
      await reportService.recordError(error, stack);
    }
    return null;
  }

  Future<Map<String, UpnpProtocolInfo>?> getProtocolInfo() async {
    final result = await requestCustom(
      serviceId: 'ConnectionManager',
      serviceType: Upnp.upnpServiceTypeConnectionManager,
      action: 'GetProtocolInfo',
      data: Upnp.getProtocolInfoActionXml(),
    );

    if (result != null) {
      final doc = XmlDocument.parse(result);
      final sink = UpnpProtocolInfo(doc.findAllElements('Sink').first.innerText);
      final source = UpnpProtocolInfo(doc.findAllElements('Source').first.innerText);
      return {
        'sink': sink,
        'source': source,
      };
    }

    return null;
  }

  Future<Set<String>?> getSinkSupportedMimeTypes() async {
    final protocolInfo = await getProtocolInfo();
    final sinkProtocolInfo = protocolInfo?['sink'];
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
