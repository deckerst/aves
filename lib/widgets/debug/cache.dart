import 'package:aves/services/common/services.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:flutter/material.dart';

class DebugCacheSection extends StatefulWidget {
  const DebugCacheSection({Key? key}) : super(key: key);

  @override
  State<DebugCacheSection> createState() => _DebugCacheSectionState();
}

class _DebugCacheSectionState extends State<DebugCacheSection> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AvesExpansionTile(
      title: 'Cache',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Image cache:\n\t${imageCache!.currentSize}/${imageCache!.maximumSize} items\n\t${formatFileSize('en_US', imageCache!.currentSizeBytes)}/${formatFileSize('en_US', imageCache!.maximumSizeBytes)}'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      imageCache!.clear();

                      setState(() {});
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text('Glide disk cache: ?'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: mediaFileService.clearSizedThumbnailDiskCache,
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
