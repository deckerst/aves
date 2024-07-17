import 'dart:async';
import 'dart:io';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/pop/double_back.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/behaviour/pop/tv_navigation.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/explorer/app_bar.dart';
import 'package:aves/widgets/navigation/drawer/app_drawer.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class ExplorerPage extends StatefulWidget {
  static const routeName = '/explorer';

  final String? path;

  const ExplorerPage({super.key, this.path});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  final List<StreamSubscription> _subscriptions = [];
  final ValueNotifier<VolumeRelativeDirectory> _directory = ValueNotifier(const VolumeRelativeDirectory(volumePath: '', relativeDir: ''));
  final ValueNotifier<List<Directory>> _contents = ValueNotifier([]);

  Set<StorageVolume> get _volumes => androidFileUtils.storageVolumes;

  String get _currentDirectoryPath {
    final dir = _directory.value;
    return pContext.join(dir.volumePath, dir.relativeDir);
  }

  @override
  void initState() {
    super.initState();
    final path = widget.path;
    if (path != null) {
      _goTo(path);
    } else {
      final primaryVolume = _volumes.firstWhereOrNull((v) => v.isPrimary);
      if (primaryVolume != null) {
        _goTo(primaryVolume.path);
      }
    }
    _contents.addListener(() => PrimaryScrollController.of(context).jumpTo(0));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final source = context.read<CollectionSource>();
      _subscriptions.add(source.eventBus.on<AlbumsChangedEvent>().listen((event) => _updateContents()));
    });
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _directory.dispose();
    _contents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VolumeRelativeDirectory>(
      valueListenable: _directory,
      builder: (context, directory, child) {
        final atRoot = directory.relativeDir.isEmpty;
        return AvesPopScope(
          handlers: [
            APopHandler(
              canPop: (context) => atRoot,
              onPopBlocked: (context) => _goTo(pContext.dirname(_currentDirectoryPath)),
            ),
            tvNavigationPopHandler,
            doubleBackPopHandler,
          ],
          child: AvesScaffold(
            drawer: const AppDrawer(),
            body: GestureAreaProtectorStack(
              child: Column(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<List<Directory>>(
                      valueListenable: _contents,
                      builder: (context, contents, child) {
                        final durations = context.watch<DurationsData>();
                        return CustomScrollView(
                          // workaround to prevent scrolling the app bar away
                          // when there is no content and we use `SliverFillRemaining`
                          physics: contents.isEmpty ? const NeverScrollableScrollPhysics() : null,
                          slivers: [
                            ExplorerAppBar(
                              key: const Key('appbar'),
                              directoryNotifier: _directory,
                              goTo: _goTo,
                            ),
                            AnimationLimiter(
                              // animation limiter should not be above the app bar
                              // so that the crumb line can automatically scroll
                              key: ValueKey(_currentDirectoryPath),
                              child: SliverList.builder(
                                itemBuilder: (context, index) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: durations.staggeredAnimation,
                                    delay: durations.staggeredAnimationDelay * timeDilation,
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: _buildContentLine(context, contents[index]),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: contents.length,
                              ),
                            ),
                            contents.isEmpty
                                ? SliverFillRemaining(
                                    child: _buildEmptyContent(),
                                  )
                                : const SliverPadding(padding: EdgeInsets.only(bottom: 8)),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(height: 0),
                  SafeArea(
                    top: false,
                    bottom: true,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: AvesFilterChip(
                        filter: PathFilter(_currentDirectoryPath),
                        maxWidth: double.infinity,
                        onTap: (filter) => _goToCollectionPage(context, filter),
                        onLongPress: null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyContent() {
    return Selector<CollectionSource, bool>(
      selector: (context, source) => source.state == SourceState.loading,
      builder: (context, loading, child) {
        Widget? bottom;
        if (loading) {
          bottom = const CircularProgressIndicator();
        } else {
          final source = context.read<CollectionSource>();
          final album = _getAlbumPath(source, Directory(_currentDirectoryPath));
          if (album != null) {
            bottom = AvesFilterChip(
              filter: AlbumFilter(album, source.getAlbumDisplayName(context, album)),
              maxWidth: double.infinity,
              onTap: (filter) => _goToCollectionPage(context, filter),
              onLongPress: null,
            );
          }
        }

        return SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: EmptyContent(
                icon: AIcons.folder,
                text: '',
                bottom: bottom,
              ),
            ),
          ),
        );
      },
    );
  }

  String? _getAlbumPath(CollectionSource source, FileSystemEntity content) {
    final contentPath = content.path.toLowerCase();
    return source.rawAlbums.firstWhereOrNull((v) => v.toLowerCase() == contentPath);
  }

  Widget _buildContentLine(BuildContext context, FileSystemEntity content) {
    final source = context.read<CollectionSource>();
    final album = _getAlbumPath(source, content);
    final baseIconTheme = IconTheme.of(context);

    const leadingDim = AvesFilterChip.minChipWidth;
    return ListTile(
      leading: album != null
          ? IconTheme.merge(
              data: baseIconTheme,
              child: AvesFilterChip(
                filter: AlbumFilter(album, source.getAlbumDisplayName(context, album)),
                showText: false,
                maxWidth: leadingDim,
                onTap: (filter) => _goToCollectionPage(context, filter),
                onLongPress: null,
              ),
            )
          : const SizedBox(
              width: leadingDim,
              height: leadingDim,
              child: Icon(AIcons.folder),
            ),
      title: Text('${Unicode.FSI}${pContext.split(content.path).last}${Unicode.PDI}'),
      onTap: () => _goTo(content.path),
    );
  }

  void _goTo(String path) {
    _directory.value = androidFileUtils.relativeDirectoryFromPath(path)!;
    _updateContents();
  }

  void _updateContents() {
    final contents = <Directory>[];

    final source = context.read<CollectionSource>();
    final albums = source.rawAlbums.map((v) => v.toLowerCase()).toSet();
    Directory(_currentDirectoryPath).list().listen((event) {
      final entity = event.absolute;
      if (entity is Directory) {
        final dirPath = entity.path.toLowerCase();
        if (albums.any((v) => v.startsWith(dirPath))) {
          contents.add(entity);
        }
      }
    }, onDone: () {
      _contents.value = contents
        ..sort((a, b) {
          final nameA = pContext.split(a.path).last;
          final nameB = pContext.split(b.path).last;
          return compareAsciiUpperCaseNatural(nameA, nameB);
        });
    });
  }

  void _goToCollectionPage(BuildContext context, CollectionFilter filter) {
    Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: CollectionPage.routeName),
        builder: (context) => CollectionPage(
          source: context.read<CollectionSource>(),
          filters: {filter},
        ),
      ),
    );
  }
}
