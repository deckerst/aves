import 'dart:io';

import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/collection/loading.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/explorer/app_bar.dart';
import 'package:aves/widgets/explorer/notifications.dart';
import 'package:aves/widgets/navigation/nav_bar/nav_bar.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const ExplorerContentItem({
  required final Directory directory,
  required final bool hasChildren,
}) implements Comparable<ExplorerContentItem> {
  @override
  int compareTo(ExplorerContentItem other) {
    final nameA = pContext.split(directory.path).last;
    final nameB = pContext.split(other.directory.path).last;
    return compareAsciiUpperCaseNatural(nameA, nameB);
  }
}

class const ExplorerPageBody({
  super.key,
  required final ValueNotifier<VolumeRelativeDirectory?> directoryNotifier,
  required final ValueNotifier<VolumeRelativeDirectory?> contentsDirectoryNotifier,
  required final ValueNotifier<List<ExplorerContentItem>> contentsNotifier,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder<List<ExplorerContentItem>>(
            valueListenable: contentsNotifier,
            builder: (context, contents, child) {
              final durations = context.watch<DurationsData>();
              return CustomScrollView(
                primary: true,
                // workaround to prevent scrolling the app bar away
                // when there is no content and we use `SliverFillRemaining`
                physics: contents.isEmpty ? const NeverScrollableScrollPhysics() : null,
                slivers: [
                  ExplorerAppBar(
                    key: const Key('appbar'),
                    directoryNotifier: directoryNotifier,
                    goToDir: (dir) => GoToDirectoryNotification(dir).dispatch(context),
                  ),
                  contents.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyContent(context),
                        )
                      : AnimationLimiter(
                          // animation limiter should not be above the app bar
                          // so that the crumb line can automatically scroll
                          key: ValueKey(contents),
                          child: SliverList.builder(
                            itemBuilder: (context, index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: durations.staggeredAnimation,
                                delay: durations.staggeredAnimationDelay * timeDilation,
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: _ExplorerContentLine(item: contents[index]),
                                  ),
                                ),
                              );
                            },
                            itemCount: contents.length,
                          ),
                        ),
                  const NavBarPaddingSliver(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static String? getAlbumPath(CollectionSource source, FileSystemEntity content) {
    final contentPath = content.path.toLowerCase();
    return source.rawAlbums.firstWhereOrNull((v) => v.toLowerCase() == contentPath);
  }

  Widget _buildEmptyContent(BuildContext context) {
    final source = context.read<CollectionSource>();
    return ValueListenableBuilder<SourceState>(
      valueListenable: source.stateNotifier,
      builder: (context, sourceState, child) {
        if (sourceState == SourceState.loading) {
          return LoadingEmptyContent(source: source);
        }

        Widget? bottom;
        final dirPath = contentsDirectoryNotifier.value?.dirPath;
        if (dirPath != null) {
          final album = getAlbumPath(source, Directory(dirPath));
          if (album != null) {
            bottom = AvesFilterChip(
              filter: StoredAlbumFilter(album, source.getStoredAlbumDisplayName(context, album)),
              maxWidth: double.infinity,
              onTap: (filter) => GoToCollectionPageNotification(filter).dispatch(context),
              onLongPress: null,
            );
          }
        }

        return EmptyContent(
          icon: AIcons.folder,
          text: '',
          bottom: bottom,
        );
      },
    );
  }
}

class const _ExplorerContentLine({required final ExplorerContentItem item}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entity = item.directory;
    final entityPath = entity.path;

    final source = context.read<CollectionSource>();
    final albumPath = ExplorerPageBody.getAlbumPath(source, entity);
    final baseIconTheme = IconTheme.of(context);

    const leadingDim = AvesFilterChip.minChipWidth;
    return ListTile(
      leading: albumPath != null
          ? IconTheme.merge(
              data: baseIconTheme,
              child: AvesFilterChip(
                filter: StoredAlbumFilter(albumPath, source.getStoredAlbumDisplayName(context, albumPath)),
                showText: false,
                maxWidth: leadingDim,
                onTap: (filter) {
                  if (!context.mounted) return;
                  GoToCollectionPageNotification(filter).dispatch(context);
                },
                onLongPress: null,
              ),
            )
          : const SizedBox(
              width: leadingDim,
              height: leadingDim,
              child: Icon(AIcons.folder),
            ),
      title: Text('${Unicode.FSI}${pContext.split(entityPath).last}${Unicode.PDI}'),
      trailing: item.hasChildren ? const Icon(AIcons.next) : null,
      onTap: () => GoToPathNotification(entityPath).dispatch(context),
    );
  }
}
