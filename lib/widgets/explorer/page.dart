import 'dart:async';
import 'dart:io';

import 'package:aves/app_mode.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/album.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/basic/draggable_scrollbar/notifications.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/pop/double_back.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/behaviour/pop/tv_navigation.dart';
import 'package:aves/widgets/explorer/body.dart';
import 'package:aves/widgets/explorer/notifications.dart';
import 'package:aves/widgets/navigation/drawer/app_drawer.dart';
import 'package:aves/widgets/navigation/nav_bar/nav_bar.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const ExplorerPage({
  super.key,
  final String? path,
}) extends StatefulWidget {
  static const routeName = '/explorer';

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  final Set<StreamSubscription> _subscriptions = {};
  final ValueNotifier<VolumeRelativeDirectory?> _directoryNotifier = ValueNotifier(null);
  final ValueNotifier<VolumeRelativeDirectory?> _contentsDirectoryNotifier = ValueNotifier(null);
  final ValueNotifier<List<ExplorerContentItem>> _contentsNotifier = ValueNotifier([]);
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
    _contentsNotifier.addListener(() {
      final scrollController = PrimaryScrollController.of(context);
      if (scrollController.hasClients) {
        scrollController.positions.where((v) => v.hasContentDimensions).forEach(((v) => v.jumpTo(0)));
      }
    });
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
    _directoryNotifier.dispose();
    _contentsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VolumeRelativeDirectory?>(
      valueListenable: _directoryNotifier,
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
            child: NotificationListener<ExplorerNotification>(
              onNotification: (notification) {
                switch (notification) {
                  case GoToCollectionPageNotification _:
                    _goToCollectionPage(context, notification.filter);
                  case GoToDirectoryNotification _:
                    _goToDir(notification.dir);
                  case GoToPathNotification _:
                    _goToPath(notification.path);
                }
                return true;
              },
              child: ExplorerPageBody(
                directoryNotifier: _directoryNotifier,
                contentsDirectoryNotifier: _contentsDirectoryNotifier,
                contentsNotifier: _contentsNotifier,
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
    final directory = _directoryNotifier.value;
    final dirPath = directory?.dirPath;
    if (dirPath == null) return;

    final contents = <ExplorerContentItem>[];
    final source = context.read<CollectionSource>();
    final albums = source.rawAlbums.map((v) => androidFileUtils.ensureTrailingSeparator(v.toLowerCase())).toSet();
    Directory(dirPath).list().listen(
      (event) {
        final entity = event.absolute;
        if (entity is Directory) {
          final dirPath = androidFileUtils.ensureTrailingSeparator(entity.path.toLowerCase());
          final isAlbum = albums.contains(dirPath);
          final hasChildren = albums.any((v) => v.startsWith(dirPath) && v != dirPath);
          if (isAlbum || hasChildren) {
            contents.add(
              ExplorerContentItem(
                directory: entity,
                hasChildren: hasChildren,
              ),
            );
          }
        }
      },
      onDone: () {
        _contentsNotifier.value = contents..sort();
        _contentsDirectoryNotifier.value = directory;
      },
    );
  }

  void _goToDir(VolumeRelativeDirectory? dir) {
    if (dir != null) {
      _directoryNotifier.value = dir;
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
