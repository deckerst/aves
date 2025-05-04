import 'package:aves/model/db/db.dart';
import 'package:aves/model/dynamic_albums.dart';
import 'package:aves/model/filters/covered/album_group.dart';
import 'package:aves/model/filters/covered/dynamic_album.dart';
import 'package:aves/model/filters/covered/stored_album.dart';
import 'package:aves/model/filters/set_or.dart';
import 'package:aves/model/grouping/common.dart';
import 'package:aves/model/grouping/convert.dart';
import 'package:aves/services/common/services.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../fake/db.dart';

void main() {
  const groupName = 'some group name';
  const storedAlbumPath = '/path/to/album';

  setUp(() async {
    // specify Posix style path context for consistent behaviour when running tests on Windows
    getIt.registerLazySingleton<p.Context>(() => p.Context(style: p.Style.posix));
    getIt.registerLazySingleton<LocalMediaDb>(FakeAvesDb.new);
  });

  tearDown(() async {
    albumGrouping.clear();
    await dynamicAlbums.clear();
    await getIt.reset();
  });

  test('Filter URI round trip', () {
    final storedAlbumFilter = StoredAlbumFilter(storedAlbumPath, 'display name');
    final dynamicAlbumFilter = DynamicAlbumFilter('dynamic name', storedAlbumFilter);
    dynamicAlbums.add(dynamicAlbumFilter);
    final groupUri = albumGrouping.buildGroupUri(null, groupName);
    final albumGroupFilter = AlbumGroupFilter(groupUri, SetOrFilter({storedAlbumFilter, dynamicAlbumFilter}));

    expect(albumGrouping.uriToFilter(GroupingConversion.filterToUri(storedAlbumFilter)), storedAlbumFilter);
    expect(albumGrouping.uriToFilter(GroupingConversion.filterToUri(dynamicAlbumFilter)), dynamicAlbumFilter);
    expect(albumGrouping.uriToFilter(GroupingConversion.filterToUri(albumGroupFilter)), albumGroupFilter);
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
}
