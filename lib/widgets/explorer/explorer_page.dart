import 'dart:io';

import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/android_file_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/app_bar/app_bar_title.dart';
import 'package:aves/widgets/common/basic/font_size_icon_theme.dart';
import 'package:aves/widgets/common/basic/popup/menu_row.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/behaviour/pop/double_back.dart';
import 'package:aves/widgets/common/behaviour/pop/scope.dart';
import 'package:aves/widgets/common/behaviour/pop/tv_navigation.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/aves_filter_chip.dart';
import 'package:aves/widgets/common/identity/empty.dart';
import 'package:aves/widgets/common/search/route.dart';
import 'package:aves/widgets/navigation/drawer/app_drawer.dart';
import 'package:aves/widgets/search/search_delegate.dart';
import 'package:aves/widgets/settings/privacy/file_picker/crumb_line.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class ExplorerPage extends StatefulWidget {
  static const routeName = '/explorer';

  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  final ValueNotifier<VolumeRelativeDirectory> _directory = ValueNotifier(const VolumeRelativeDirectory(volumePath: '', relativeDir: ''));
  final ValueNotifier<List<Directory>> _contents = ValueNotifier([]);
  final DoubleBackPopHandler _doubleBackPopHandler = DoubleBackPopHandler();

  Set<StorageVolume> get _volumes => androidFileUtils.storageVolumes;

  String get _currentDirectoryPath {
    final dir = _directory.value;
    return pContext.join(dir.volumePath, dir.relativeDir);
  }

  static const double _crumblineHeight = kMinInteractiveDimension;

  @override
  void initState() {
    super.initState();
    final primaryVolume = _volumes.firstWhereOrNull((v) => v.isPrimary);
    if (primaryVolume != null) {
      _goTo(primaryVolume.path);
    }
  }

  @override
  void dispose() {
    _doubleBackPopHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesPopScope(
      handlers: [
        (context) {
          if (_directory.value.relativeDir.isNotEmpty) {
            final parent = pContext.dirname(_currentDirectoryPath);
            _goTo(parent);
            return false;
          }
          return true;
        },
        TvNavigationPopHandler.pop,
        _doubleBackPopHandler.pop,
      ],
      child: AvesScaffold(
        appBar: _buildAppBar(context),
        drawer: const AppDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<List<Directory>>(
                  valueListenable: _contents,
                  builder: (context, contents, child) {
                    if (contents.isEmpty) {
                      final source = context.read<CollectionSource>();
                      final album = _getAlbumPath(source, Directory(_currentDirectoryPath));
                      return Center(
                        child: EmptyContent(
                          icon: AIcons.folder,
                          text: '',
                          bottom: album != null
                              ? AvesFilterChip(
                                  filter: AlbumFilter(album, source.getAlbumDisplayName(context, album)),
                                  maxWidth: double.infinity,
                                  onTap: (filter) => _goToCollectionPage(context, filter),
                                  onLongPress: null,
                                )
                              : null,
                        ),
                      );
                    }
                    final durations = context.watch<DurationsData>();
                    return AnimationLimiter(
                      key: ValueKey(_currentDirectoryPath),
                      child: ListView(
                        children: AnimationConfiguration.toStaggeredList(
                          duration: durations.staggeredAnimation,
                          delay: durations.staggeredAnimationDelay * timeDilation,
                          childAnimationBuilder: (child) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: child,
                            ),
                          ),
                          children: contents.map((v) => _buildContentLine(context, v)).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 0),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ValueListenableBuilder<VolumeRelativeDirectory>(
                  valueListenable: _directory,
                  builder: (context, directory, child) {
                    return AvesFilterChip(
                      filter: PathFilter(_currentDirectoryPath),
                      maxWidth: double.infinity,
                      onTap: (filter) => _goToCollectionPage(context, filter),
                      onLongPress: null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final animations = context.select<Settings, AccessibilityAnimations>((s) => s.accessibilityAnimations);

    return AppBar(
      title: InteractiveAppBarTitle(
        onTap: _goToSearch,
        child: Text(
          context.l10n.explorerPageTitle,
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
        ),
      ),
      actions: [
        if (_volumes.length > 1)
          FontSizeIconTheme(
            child: PopupMenuButton<StorageVolume>(
              itemBuilder: (context) {
                return _volumes.map((v) {
                  final selected = _directory.value.volumePath == v.path;
                  final icon = v.isRemovable ? AIcons.storageCard : AIcons.storageMain;
                  return PopupMenuItem(
                    value: v,
                    enabled: !selected,
                    child: MenuRow(
                      text: v.getDescription(context),
                      icon: Icon(icon),
                    ),
                  );
                }).toList();
              },
              onSelected: (volume) async {
                // wait for the popup menu to hide before proceeding with the action
                await Future.delayed(animations.popUpAnimationDelay * timeDilation);

                Navigator.maybeOf(context)?.pop();
                await Future.delayed(ADurations.drawerTransitionAnimation);
                _goTo(volume.path);
              },
              popUpAnimationStyle: animations.popUpAnimationStyle,
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_crumblineHeight),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _crumblineHeight),
          child: ValueListenableBuilder<VolumeRelativeDirectory>(
            valueListenable: _directory,
            builder: (context, directory, child) {
              return CrumbLine(
                directory: directory,
                onTap: _goTo,
              );
            },
          ),
        ),
      ),
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

    return ListTile(
      leading: const Icon(AIcons.folder),
      title: Text('${Unicode.FSI}${pContext.split(content.path).last}${Unicode.PDI}'),
      trailing: album != null
          ? IconTheme.merge(
              data: baseIconTheme,
              child: AvesFilterChip(
                filter: AlbumFilter(album, source.getAlbumDisplayName(context, album)),
                showText: false,
                maxWidth: AvesFilterChip.minChipWidth,
                onTap: (filter) => _goToCollectionPage(context, filter),
                onLongPress: null,
              ),
            )
          : null,
      onTap: () => _goTo(content.path),
    );
  }

  void _goTo(String path) {
    _directory.value = androidFileUtils.relativeDirectoryFromPath(path)!;
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

  void _goToSearch() {
    Navigator.maybeOf(context)?.push(
      SearchPageRoute(
        delegate: CollectionSearchDelegate(
          searchFieldLabel: context.l10n.searchCollectionFieldHint,
          searchFieldStyle: Themes.searchFieldStyle(context),
          source: context.read<CollectionSource>(),
        ),
      ),
    );
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
