import 'dart:async';
import 'dart:io';

import 'package:aves/app_mode.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/collection/loading.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar/notifications.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/pop/double_back.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/behaviour/pop/tv_navigation.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/explorer/app_bar.dart';
import 'package:aves/widgets/navigation/drawer/app_drawer.dart';
import 'package:aves/widgets/navigation/nav_bar/nav_bar.dart';
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
  final Set<StreamSubscription> _subscriptions = {};
  final ValueNotifier<VolumeRelativeDirectory?> _directory = ValueNotifier(null);
  final ValueNotifier<VolumeRelativeDirectory?> _contentsDirectory = ValueNotifier(null);
  final ValueNotifier<List<Directory>> _contents = ValueNotifier([]);
  final StreamController<DraggableScrollbarEvent> _draggableScrollBarEventStreamController = StreamController.broadcast();

  Set<StorageVolume> get _volumes => androidFileUtils.storageVolumes;

  @override
  void initState() {
    super.initState();
    final path = widget.path;
    if (path != null && androidFileUtils.getStorageVolume(path) != null) {
      _goToPath(path);
    } else {
      final primaryVolume = _volumes.firstWhereOrNull((v) => v.isPrimary);
      if (primaryVolume != null) {
        _goToPath(primaryVolume.path);
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
    return ValueListenableBuilder<VolumeRelativeDirectory?>(
      valueListenable: _directory,
      builder: (context, directory, child) {
        final atRoot = directory?.relativeDir.isEmpty ?? true;
        final path = directory?.dirPath;
        final body = AvesPopScope(
          handlers: [
            APopHandler(
              canPop: (context) => atRoot,
              onPopBlocked: (context) {
                if (path != null) {
                  _goToPath(pContext.dirname(path));
                }
              },
            ),
            tvNavigationPopHandler,
            doubleBackPopHandler,
          ],
          child: GestureAreaProtectorStack(
            child: NotificationListener<_ExplorerNotification>(
              onNotification: (notification) {
                switch (notification) {
                  case _GoToCollectionPageNotification _:
                    _goToCollectionPage(context, notification.filter);
                  case _GoToDirectoryNotification _:
                    _goToDir(notification.dir);
                  case _GoToPathNotification _:
                    _goToPath(notification.path);
                }
                return true;
              },
              child: _ExplorerPageContent(
                directoryNotifier: _directory,
                contentsDirectoryNotifier: _contentsDirectory,
                contentsNotifier: _contents,
              ),
            ),
          ),
        );

        return Selector<Settings, bool>(
          selector: (context, s) => s.enableBottomNavigationBar,
          builder: (context, enableBottomNavigationBar, child) {
            final canNavigate = context.select<ValueNotifier<AppMode>, bool>((v) => v.value.canNavigate);
            final showBottomNavigationBar = canNavigate && enableBottomNavigationBar;

            return NotificationListener<DraggableScrollbarNotification>(
              onNotification: (notification) {
                _draggableScrollBarEventStreamController.add(notification.event);
                return false;
              },
              child: AvesScaffold(
                body: body,
                drawer: canNavigate ? AppDrawer(currentExplorerPath: path) : null,
                bottomNavigationBar: showBottomNavigationBar
                    ? AppBottomNavBar(
                        events: _draggableScrollBarEventStreamController.stream,
                      )
                    : null,
                resizeToAvoidBottomInset: false,
                extendBody: true,
              ),
            );
          },
        );
      },
    );
  }

  void _updateContents() {
    final directory = _directory.value;
    final dirPath = directory?.dirPath;
    if (dirPath == null) return;

    final contents = <Directory>[];
    final source = context.read<CollectionSource>();
    final albums = source.rawAlbums.map((v) => v.toLowerCase()).toSet();
    Directory(dirPath).list().listen(
      (event) {
        final entity = event.absolute;
        if (entity is Directory) {
          final dirPath = entity.path.toLowerCase();
          if (albums.any((v) => v.startsWith(dirPath))) {
            contents.add(entity);
          }
        }
      },
      onDone: () {
        _contents.value = contents
          ..sort((a, b) {
            final nameA = pContext.split(a.path).last;
            final nameB = pContext.split(b.path).last;
            return compareAsciiUpperCaseNatural(nameA, nameB);
          });
        _contentsDirectory.value = directory;
      },
    );
  }

  void _goToDir(VolumeRelativeDirectory? dir) {
    if (dir != null) {
      _directory.value = dir;
      _updateContents();
    }
  }

  void _goToPath(String path) => _goToDir(androidFileUtils.relativeDirectoryFromPath(path));

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

class _ExplorerPageContent extends StatelessWidget {
  final ValueNotifier<VolumeRelativeDirectory?> directoryNotifier;
  final ValueNotifier<VolumeRelativeDirectory?> contentsDirectoryNotifier;
  final ValueNotifier<List<Directory>> contentsNotifier;

  const _ExplorerPageContent({
    required this.directoryNotifier,
    required this.contentsDirectoryNotifier,
    required this.contentsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder<List<Directory>>(
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
                    goToDir: (dir) => _GoToDirectoryNotification(dir).dispatch(context),
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
                                    child: _ExplorerContentLine(entity: contents[index]),
                                  ),
                                ),
                              );
                            },
                            itemCount: contents.length,
                          ),
                        ),
                  const NavBarPaddingSliver(),
                  const BottomPaddingSliver(),
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
              onTap: (filter) => _GoToCollectionPageNotification(filter).dispatch(context),
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

class _ExplorerContentLine extends StatelessWidget {
  final FileSystemEntity entity;

  const _ExplorerContentLine({
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    final source = context.read<CollectionSource>();
    final album = _ExplorerPageContent.getAlbumPath(source, entity);
    final baseIconTheme = IconTheme.of(context);

    const leadingDim = AvesFilterChip.minChipWidth;
    return ListTile(
      leading: album != null
          ? IconTheme.merge(
              data: baseIconTheme,
              child: AvesFilterChip(
                filter: StoredAlbumFilter(album, source.getStoredAlbumDisplayName(context, album)),
                showText: false,
                maxWidth: leadingDim,
                onTap: (filter) => _GoToCollectionPageNotification(filter).dispatch(context),
                onLongPress: null,
              ),
            )
          : const SizedBox(
              width: leadingDim,
              height: leadingDim,
              child: Icon(AIcons.folder),
            ),
      title: Text('${Unicode.FSI}${pContext.split(entity.path).last}${Unicode.PDI}'),
      onTap: () => _GoToPathNotification(entity.path).dispatch(context),
    );
  }
}

abstract class _ExplorerNotification extends Notification {
  const _ExplorerNotification();
}

@immutable
class _GoToDirectoryNotification extends _ExplorerNotification {
  final VolumeRelativeDirectory? dir;

  const _GoToDirectoryNotification(this.dir);
}

@immutable
class _GoToPathNotification extends _ExplorerNotification {
  final String path;

  const _GoToPathNotification(this.path);
}

@immutable
class _GoToCollectionPageNotification extends _ExplorerNotification {
  final CollectionFilter filter;

  const _GoToCollectionPageNotification(this.filter);
}
