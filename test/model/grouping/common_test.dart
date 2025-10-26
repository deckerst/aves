import 'dart:async';

import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/filters/container/album_group.dart';
import 'package:aves/model/filters/container/dynamic_album.dart';
import 'package:aves/model/filters/container/set_or.dart';
import 'package:aves/model/filters/container/tag_group.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/covered/tag.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/grouping/convert.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/model/source/media_store_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:test/test.dart';

import '../../common.dart';
import '../../fake/media_store_service.dart';
import '../../fake/storage_service.dart';

void main() {
  const groupName = 'some group name';
  const storedAlbumPath = '/path/to/album';

  setUpAll(() async {
    await setUpAllServices();
  });

  setUp(() async {
    await setUpServices();
  });

  tearDownAll(() async {
    await tearDownAllServices();
  });

  test('Filter URI round trip', () {
    final storedAlbumFilter = StoredAlbumFilter(storedAlbumPath, 'display name');
    final dynamicAlbumFilter = DynamicAlbumFilter('dynamic name', storedAlbumFilter);
    dynamicAlbums.add(dynamicAlbumFilter);
    final albumGroupUri = albumGrouping.buildGroupUri(null, groupName);
    final albumGroupFilter = AlbumGroupFilter(albumGroupUri, SetOrFilter({storedAlbumFilter, dynamicAlbumFilter}));

    expect(albumGrouping.uriToFilter(GroupingConversion.filterToUri(storedAlbumFilter)), storedAlbumFilter);
    expect(albumGrouping.uriToFilter(GroupingConversion.filterToUri(dynamicAlbumFilter)), dynamicAlbumFilter);
    expect(albumGrouping.uriToFilter(GroupingConversion.filterToUri(albumGroupFilter)), albumGroupFilter);

    final tagFilter = TagFilter('some tag');
    final tagGroupUri = tagGrouping.buildGroupUri(null, groupName);
    final tagGroupFilter = TagGroupFilter(tagGroupUri, SetOrFilter({tagFilter}));

    expect(tagGrouping.uriToFilter(GroupingConversion.filterToUri(tagFilter)), tagFilter);
    expect(tagGrouping.uriToFilter(GroupingConversion.filterToUri(tagGroupFilter)), tagGroupFilter);
  });

  test('Empty group', () {
    final groupUri = albumGrouping.buildGroupUri(null, groupName);
    expect(FilterGrouping.getGroupName(groupUri), groupName);

    expect(albumGrouping.exists(groupUri), false);
    expect(albumGrouping.getDirectChildren(null).length, 0);
    expect(albumGrouping.getDirectChildren(groupUri).length, 0);
    expect(albumGrouping.countLeaves(groupUri), 0);
  });

  test('Adding album to group', () {
    final groupUri = albumGrouping.buildGroupUri(null, groupName);
    final childUri = GroupingConversion.filterToUri(StoredAlbumFilter(storedAlbumPath, null));
    albumGrouping.addToGroup({childUri}.nonNulls.toSet(), groupUri);

    expect(albumGrouping.exists(groupUri), true);
    expect(albumGrouping.getDirectChildren(null).length, 1);
    expect(albumGrouping.getDirectChildren(groupUri).length, 1);
    expect(albumGrouping.countLeaves(groupUri), 1);
  });

  test('Adding subgroup to group', () {
    final rootGroupUri = albumGrouping.buildGroupUri(null, 'root');
    final subGroupUri = albumGrouping.buildGroupUri(rootGroupUri, 'sub');
    final childUri = GroupingConversion.filterToUri(StoredAlbumFilter(storedAlbumPath, null));
    albumGrouping.addToGroup({childUri}.nonNulls.toSet(), subGroupUri);
    albumGrouping.addToGroup({subGroupUri}, rootGroupUri);

    expect(albumGrouping.exists(rootGroupUri), true);
    expect(albumGrouping.exists(subGroupUri), true);
    expect(albumGrouping.getDirectChildren(null).length, 1);
    expect(albumGrouping.getDirectChildren(rootGroupUri).length, 1);
    expect(albumGrouping.getDirectChildren(subGroupUri).length, 1);
    expect(albumGrouping.countLeaves(rootGroupUri), 1);
    expect(albumGrouping.countLeaves(subGroupUri), 1);
  });

  test('Removing from group', () {
    final groupUri = albumGrouping.buildGroupUri(null, groupName);
    final childUri = GroupingConversion.filterToUri(StoredAlbumFilter(storedAlbumPath, null));
    albumGrouping.addToGroup({childUri}.nonNulls.toSet(), groupUri);
    albumGrouping.addToGroup({childUri}.nonNulls.toSet(), null);

    expect(albumGrouping.exists(groupUri), false);
    expect(albumGrouping.getDirectChildren(null).length, 0);
    expect(albumGrouping.getDirectChildren(groupUri).length, 0);
    expect(albumGrouping.countLeaves(groupUri), 0);
  });

  test('Reparent group', () {
    const subgroupName = 'sub';

    final rootGroupUri = albumGrouping.buildGroupUri(null, 'old root');
    final subGroupUri = albumGrouping.buildGroupUri(rootGroupUri, subgroupName);
    final childUri = GroupingConversion.filterToUri(StoredAlbumFilter(storedAlbumPath, null));
    albumGrouping.addToGroup({childUri}.nonNulls.toSet(), subGroupUri);
    albumGrouping.addToGroup({subGroupUri}, rootGroupUri);

    final newRootGroupUri = albumGrouping.buildGroupUri(null, 'new root');
    final newSubGroupUri = albumGrouping.buildGroupUri(newRootGroupUri, subgroupName);
    albumGrouping.addToGroup({subGroupUri}, newRootGroupUri);
    expect(albumGrouping.exists(rootGroupUri), false);
    expect(albumGrouping.exists(subGroupUri), false);
    expect(albumGrouping.exists(newRootGroupUri), true);
    expect(albumGrouping.exists(newSubGroupUri), true);
    expect(albumGrouping.getDirectChildren(newRootGroupUri).length, 1);
    expect(albumGrouping.getDirectChildren(newSubGroupUri).length, 1);
  });

  test('Reparent content', () {
    final rootGroupUri = albumGrouping.buildGroupUri(null, 'root');
    final childUriToKeep = GroupingConversion.filterToUri(StoredAlbumFilter('$storedAlbumPath 1', null));
    final childUriToMove = GroupingConversion.filterToUri(StoredAlbumFilter('$storedAlbumPath 2', null));
    albumGrouping.addToGroup({childUriToKeep, childUriToMove}.nonNulls.toSet(), rootGroupUri);

    final subGroupUri = albumGrouping.buildGroupUri(rootGroupUri, 'sub');
    albumGrouping.addToGroup({childUriToMove}.nonNulls.toSet(), subGroupUri);

    expect(albumGrouping.exists(rootGroupUri), true);
    expect(albumGrouping.exists(subGroupUri), true);
    expect(albumGrouping.getDirectChildren(rootGroupUri).length, 2);
    expect(albumGrouping.getDirectChildren(subGroupUri).length, 1);
  });

  test('Reparent group deeper', () {
    final rootGroupUri = albumGrouping.buildGroupUri(null, 'root');
    const movingGroupName = 'moving';
    final movingGroupUri = albumGrouping.buildGroupUri(null, movingGroupName);
    final childUri = GroupingConversion.filterToUri(StoredAlbumFilter(storedAlbumPath, null));
    // > moving group > stored album
    albumGrouping.addToGroup({childUri}.nonNulls.toSet(), movingGroupUri);
    // > root group > moving group > stored album
    albumGrouping.addToGroup({movingGroupUri}, rootGroupUri);

    final movedGroupUri = albumGrouping.buildGroupUri(rootGroupUri, movingGroupName);
    expect(albumGrouping.exists(rootGroupUri), true);
    expect(albumGrouping.exists(movingGroupUri), false);
    expect(albumGrouping.exists(movedGroupUri), true);
    expect(albumGrouping.getDirectChildren(rootGroupUri).length, 1);
    expect(albumGrouping.getDirectChildren(movedGroupUri).length, 1);
    expect(GroupingConversion.filterToUri(albumGrouping.getDirectChildren(rootGroupUri).first), movedGroupUri);
  });

  Future<MediaStoreSource> _initSource() async {
    final source = MediaStoreSource();
    final readyCompleter = Completer();
    source.stateNotifier.addListener(() {
      if (source.isReady) {
        readyCompleter.complete();
      }
    });
    await source.init(scope: CollectionSource.fullScope);
    await readyCompleter.future;
    return source;
  }

  test('Keep group when renaming album', () async {
    const sourceAlbum = '${FakeStorageService.primaryPath}Pictures/source';
    const destinationAlbum = '${FakeStorageService.primaryPath}Pictures/destination';

    final image1 = FakeMediaStoreService.newImage(sourceAlbum, 'image1');
    (mediaStoreService as FakeMediaStoreService).entries = {
      image1,
    };

    final oldFilter = StoredAlbumFilter(sourceAlbum, 'whatever');
    final newFilter = StoredAlbumFilter(destinationAlbum, 'whatever');

    final groupUri = albumGrouping.buildGroupUri(null, groupName);
    final childUri = GroupingConversion.filterToUri(oldFilter);
    albumGrouping.addToGroup({childUri}.nonNulls.toSet(), groupUri);

    expect(albumGrouping.getFilterParent(oldFilter), groupUri);
    expect(albumGrouping.getFilterParent(newFilter), null);

    final source = await _initSource();
    await source.renameStoredAlbum(sourceAlbum, destinationAlbum, {
      image1
    }, {
      FakeMediaStoreService.moveOpEventForMove(image1, sourceAlbum, destinationAlbum),
    });

    expect(albumGrouping.getFilterParent(oldFilter), null);
    expect(albumGrouping.getFilterParent(newFilter), groupUri);
  });
}
