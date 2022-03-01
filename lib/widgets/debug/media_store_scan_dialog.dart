import 'dart:io';

import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/dialogs/aves_dialog.dart';
import 'package:flutter/material.dart';

class MediaStoreScanDirDialog extends StatefulWidget {
  const MediaStoreScanDirDialog({Key? key}) : super(key: key);

  @override
  State<MediaStoreScanDirDialog> createState() => _MediaStoreScanDirDialogState();
}

class _MediaStoreScanDirDialogState extends State<MediaStoreScanDirDialog> {
  final TextEditingController _pathController = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesDialog(
      content: _processing ? const CircularProgressIndicator() : TextField(controller: _pathController),
      actions: [
        TextButton(
          onPressed: _processing
              ? null
              : () async {
                  final dir = _pathController.text;
                  if (dir.isNotEmpty) {
                    setState(() => _processing = true);
                    await Future.forEach<FileSystemEntity>(Directory(dir).listSync(recursive: true), (file) async {
                      if (file is File) {
                        final mimeType = MimeTypes.forExtension(pContext.extension(file.path));
                        await mediaStoreService.scanFile(file.path, mimeType!);
                      }
                    });
                  }
                  Navigator.pop(context);
                },
          child: const Text('Scan'),
        )
      ],
    );
  }
}
