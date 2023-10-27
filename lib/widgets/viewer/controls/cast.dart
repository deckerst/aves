import 'dart:async';
import 'dart:io';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/dialogs/cast_dialog.dart';
import 'package:collection/collection.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

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

    debugPrint('cast: set entry=$entry');
    try {
      await renderer.setUrl(
        '$_serverBaseUrl/${entry.id}',
        title: entry.bestTitle ?? '',
        type: entry.isVideo ? PlayType.Video : PlayType.Image,
      );
      await renderer.play();
    } catch (error, stack) {
      await reportService.recordError(error, stack);
    }
  }

  String? get _serverBaseUrl {
    final server = _mediaServer;
    return server != null ? 'http://${server.address.host}:${server.port}' : null;
  }
}
