import 'package:aves/ref/locales.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:flutter/material.dart';

class DebugCacheSection extends StatefulWidget {
  const DebugCacheSection({super.key});

  @override
  State<DebugCacheSection> createState() => _DebugCacheSectionState();
}

class _DebugCacheSectionState extends State<DebugCacheSection> with AutomaticKeepAliveClientMixin {
  final TextEditingController _imageCacheCountTextController = TextEditingController();
  final TextEditingController _imageCacheSizeTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imageCacheCountTextController.text = '${imageCache.maximumSize}';
    _imageCacheSizeTextController.text = '${imageCache.maximumSizeBytes}';
  }

  @override
  void dispose() {
    _imageCacheCountTextController.dispose();
    _imageCacheSizeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentSizeBytes = formatFileSize(kAsciiLocale, imageCache.currentSizeBytes);
    final maxSizeBytes = formatFileSize(kAsciiLocale, imageCache.maximumSizeBytes);
    return AvesExpansionTile(
      title: 'Cache',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Image cache')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      imageCache.clear();
                      setState(() {});
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('${imageCache.currentSize}\n/${imageCache.maximumSize} items')),
                  Expanded(
                    child: TextField(
                      controller: _imageCacheCountTextController,
                      decoration: const InputDecoration(labelText: 'max (items)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final size = int.tryParse(_imageCacheCountTextController.text);
                      if (size != null) {
                        imageCache.maximumSize = size;
                      } else {
                        _imageCacheCountTextController.text = '${imageCache.maximumSize}';
                      }
                      setState(() {});
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('$currentSizeBytes\n/$maxSizeBytes')),
                  Expanded(
                    child: TextField(
                      controller: _imageCacheSizeTextController,
                      decoration: const InputDecoration(labelText: 'max (bytes)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final size = int.tryParse(_imageCacheSizeTextController.text);
                      if (size != null) {
                        imageCache.maximumSizeBytes = size;
                      } else {
                        _imageCacheSizeTextController.text = '${imageCache.maximumSizeBytes}';
                      }
                      setState(() {});
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  const Expanded(
                    child: Text('Glide disk cache: ?'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: mediaFetchService.clearImageDiskCache,
                    child: const Text('Clear'),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text('Glide memory cache: ?'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: mediaFetchService.clearImageMemoryCache,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
