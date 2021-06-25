import 'package:aves/services/services.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/common/identity/aves_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DebugCacheSection extends StatefulWidget {
  const DebugCacheSection({Key? key}) : super(key: key);

  @override
  _DebugCacheSectionState createState() => _DebugCacheSectionState();
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
                    child: Text('Image cache:\n\t${imageCache!.currentSize}/${imageCache!.maximumSize} items\n\t${formatFilesize(imageCache!.currentSizeBytes)}/${formatFilesize(imageCache!.maximumSizeBytes)}'),
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
                  Expanded(
                    child: Text('SVG cache: ${PictureProvider.cache.count} items'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      PictureProvider.cache.clear();

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
                    onPressed: imageFileService.clearSizedThumbnailDiskCache,
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
