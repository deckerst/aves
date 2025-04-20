import 'dart:async';
import 'dart:ui';

import 'package:aves/model/entry/cache.dart';
import 'package:aves/model/entry/dirs.dart';
import 'package:aves/model/entry/extensions/keys.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:leak_tracker/leak_tracker.dart';

enum EntryDataType { basic, aspectRatio, catalog, address, references }

class AvesEntry with AvesEntryBase {
  @override
  int id;

  @override
  String uri;

  @override
  int? pageId;

  @override
  int? sizeBytes;

  String? _path, _filename, _extension, _sourceTitle;
  EntryDir? _directory;
  int? contentId;
  final String sourceMimeType;
  int width, height, sourceRotationDegrees;
  int? dateAddedSecs, _dateModifiedMillis, sourceDateTakenMillis, _durationMillis;
  bool trashed;
  int origin;

  int? _catalogDateMillis;
  CatalogMetadata? _catalogMetadata;
  AddressDetails? _addressDetails;
  TrashDetails? trashDetails;

  // synthetic stack of related entries, e.g. burst shots or raw/developed pairs
  List<AvesEntry>? stackedEntries;

  @override
  final AChangeNotifier visualChangeNotifier = AChangeNotifier();

  final AChangeNotifier metadataChangeNotifier = AChangeNotifier(), addressChangeNotifier = AChangeNotifier();

  AvesEntry({
    required int? id,
    required this.uri,
    required String? path,
    required this.contentId,
    required this.pageId,
    required this.sourceMimeType,
    required this.width,
    required this.height,
    required this.sourceRotationDegrees,
    required this.sizeBytes,
    required String? sourceTitle,
    required this.dateAddedSecs,
    required int? dateModifiedMillis,
    required this.sourceDateTakenMillis,
    required int? durationMillis,
    required this.trashed,
    required this.origin,
    this.stackedEntries,
  }) : id = id ?? 0 {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectCreated(
        library: 'aves',
        className: '$AvesEntry',
        object: this,
      );
    }
    this.path = path;
    this.sourceTitle = sourceTitle;
    this.dateModifiedMillis = dateModifiedMillis;
    this.durationMillis = durationMillis;
  }

  AvesEntry copyWith({
    int? id,
    String? uri,
    String? path,
    int? contentId,
    String? title,
    int? dateAddedSecs,
    int? dateModifiedMillis,
    int? origin,
    List<AvesEntry>? stackedEntries,
  }) {
    final copyEntryId = id ?? this.id;
    final copied = AvesEntry(
      id: copyEntryId,
      uri: uri ?? this.uri,
      path: path ?? this.path,
      contentId: contentId ?? this.contentId,
      pageId: null,
      sourceMimeType: sourceMimeType,
      width: width,
      height: height,
      sourceRotationDegrees: sourceRotationDegrees,
      sizeBytes: sizeBytes,
      sourceTitle: title ?? sourceTitle,
      dateAddedSecs: dateAddedSecs ?? this.dateAddedSecs,
      dateModifiedMillis: dateModifiedMillis ?? this.dateModifiedMillis,
      sourceDateTakenMillis: sourceDateTakenMillis,
      durationMillis: durationMillis,
      trashed: trashed,
      origin: origin ?? this.origin,
      stackedEntries: stackedEntries ?? this.stackedEntries,
    )
      ..catalogMetadata = _catalogMetadata?.copyWith(id: copyEntryId)
      ..addressDetails = _addressDetails?.copyWith(id: copyEntryId)
      ..trashDetails = trashDetails?.copyWith(id: copyEntryId);

    return copied;
  }

  // from DB or platform source entry
  factory AvesEntry.fromMap(Map map) {
    return AvesEntry(
      id: map[EntryFields.id] as int?,
      uri: map[EntryFields.uri] as String,
      path: map[EntryFields.path] as String?,
      pageId: null,
      contentId: map[EntryFields.contentId] as int?,
      sourceMimeType: map[EntryFields.sourceMimeType] as String,
      width: map[EntryFields.width] as int? ?? 0,
      height: map[EntryFields.height] as int? ?? 0,
      sourceRotationDegrees: map[EntryFields.sourceRotationDegrees] as int? ?? 0,
      sizeBytes: map[EntryFields.sizeBytes] as int?,
      sourceTitle: map[EntryFields.title] as String?,
      dateAddedSecs: map[EntryFields.dateAddedSecs] as int?,
      dateModifiedMillis: map[EntryFields.dateModifiedMillis] as int?,
      sourceDateTakenMillis: map[EntryFields.sourceDateTakenMillis] as int?,
      durationMillis: map[EntryFields.durationMillis] as int?,
      trashed: (map[EntryFields.trashed] as int? ?? 0) != 0,
      origin: map[EntryFields.origin] as int,
    );
  }

  // for DB only
  Map<String, dynamic> toDatabaseMap() {
    return {
      EntryFields.id: id,
      EntryFields.uri: uri,
      EntryFields.path: path,
      EntryFields.contentId: contentId,
      EntryFields.sourceMimeType: sourceMimeType,
      EntryFields.width: width,
      EntryFields.height: height,
      EntryFields.sourceRotationDegrees: sourceRotationDegrees,
      EntryFields.sizeBytes: sizeBytes,
      EntryFields.title: sourceTitle,
      EntryFields.dateAddedSecs: dateAddedSecs,
      EntryFields.dateModifiedMillis: dateModifiedMillis,
      EntryFields.sourceDateTakenMillis: sourceDateTakenMillis,
      EntryFields.durationMillis: durationMillis,
      EntryFields.trashed: trashed ? 1 : 0,
      EntryFields.origin: origin,
    };
  }

  Map<String, dynamic> toPlatformEntryMap() {
    return {
      EntryFields.uri: uri,
      EntryFields.path: path,
      EntryFields.pageId: pageId,
      EntryFields.mimeType: mimeType,
      EntryFields.width: width,
      EntryFields.height: height,
      EntryFields.rotationDegrees: rotationDegrees,
      EntryFields.isFlipped: isFlipped,
      EntryFields.dateModifiedMillis: dateModifiedMillis,
      EntryFields.sizeBytes: sizeBytes,
      EntryFields.trashed: trashed,
      EntryFields.trashPath: trashDetails?.path,
      EntryFields.origin: origin,
    };
  }

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      LeakTracking.dispatchObjectDisposed(object: this);
    }
    visualChangeNotifier.dispose();
    metadataChangeNotifier.dispose();
    addressChangeNotifier.dispose();
  }

  // do not implement [Object.==] and [Object.hashCode] using mutable attributes (e.g. `uri`)
  // so that we can reliably use instances in a `Set`, which requires consistent hash codes over time

  @override
  String toString() => '$runtimeType#${shortHash(this)}{id=$id, uri=$uri, path=$path, pageId=$pageId}';

  set path(String? path) {
    _path = path;
    _directory = null;
    _filename = null;
    _extension = null;
    _bestTitle = null;
  }

  @override
  String? get path => _path;

  // directory path, without the trailing separator
  String? get directory {
    _directory ??= entryDirRepo.getOrCreate(path != null ? pContext.dirname(path!) : null);
    return _directory!.resolved;
  }

  String? get filenameWithoutExtension {
    _filename ??= path != null ? pContext.basenameWithoutExtension(path!) : null;
    return _filename;
  }

  // file extension, including the `.`
  String? get extension {
    _extension ??= path != null ? pContext.extension(path!) : null;
    return _extension;
  }

  // the MIME type reported by the Media Store is unreliable
  // so we use the one found during cataloguing if possible
  @override
  String get mimeType => _catalogMetadata?.mimeType ?? sourceMimeType;

  bool get isCatalogued => _catalogMetadata != null;

  DateTime? _bestDate;

  DateTime? get bestDate {
    _bestDate ??= dateTimeFromMillis(_catalogDateMillis) ?? dateTimeFromMillis(sourceDateTakenMillis) ?? dateTimeFromMillis(dateModifiedMillis ?? 0);
    return _bestDate;
  }

  @override
  bool get isAnimated => catalogMetadata?.isAnimated ?? false;

  bool get isHdr => _catalogMetadata?.isHdr ?? false;

  int get rating => _catalogMetadata?.rating ?? 0;

  @override
  int get rotationDegrees => _catalogMetadata?.rotationDegrees ?? sourceRotationDegrees;

  set rotationDegrees(int rotationDegrees) {
    sourceRotationDegrees = rotationDegrees;
    _catalogMetadata?.rotationDegrees = rotationDegrees;
  }

  bool get isFlipped => _catalogMetadata?.isFlipped ?? false;

  set isFlipped(bool isFlipped) => _catalogMetadata?.isFlipped = isFlipped;

  // Media Store size/rotation is inaccurate, e.g. a portrait FHD video is rotated according to its metadata,
  // so it should be registered as width=1920, height=1080, orientation=90,
  // but is incorrectly registered as width=1080, height=1920, orientation=0.
  // Double-checking the width/height during loading or cataloguing is the proper solution, but it would take space and time.
  // Comparing width and height can help with the portrait FHD video example,
  // but it fails for a portrait screenshot rotated, which is landscape with width=1080, height=1920, orientation=90
  bool get isRotated => rotationDegrees % 180 == 90;

  @override
  double get displayAspectRatio {
    if (width == 0 || height == 0) return 1;
    return isRotated ? height / width : width / height;
  }

  @override
  Size get displaySize {
    final w = width.toDouble();
    final h = height.toDouble();
    return isRotated ? Size(h, w) : Size(w, h);
  }

  String? get sourceTitle => _sourceTitle;

  set sourceTitle(String? sourceTitle) {
    _sourceTitle = sourceTitle;
    _bestTitle = null;
  }

  int? get dateModifiedMillis => _dateModifiedMillis;

  set dateModifiedMillis(int? dateModifiedMillis) {
    _dateModifiedMillis = dateModifiedMillis;
    _bestDate = null;
  }

  // TODO TLAD cache _monthTaken
  DateTime? get monthTaken {
    final d = bestDate;
    return d == null ? null : DateTime(d.year, d.month);
  }

  // TODO TLAD cache _dayTaken
  DateTime? get dayTaken {
    final d = bestDate;
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  @override
  int? get durationMillis => _durationMillis;

  set durationMillis(int? durationMillis) {
    _durationMillis = durationMillis;
    _durationText = null;
  }

  String? _durationText;

  String get durationText {
    _durationText ??= formatFriendlyDuration(Duration(milliseconds: durationMillis ?? 0));
    return _durationText!;
  }

  // returns whether this entry has GPS coordinates
  // (0, 0) coordinates are considered invalid, as it is likely a default value
  bool get hasGps => (_catalogMetadata?.latitude ?? 0) != 0 || (_catalogMetadata?.longitude ?? 0) != 0;

  bool get hasAddress => _addressDetails != null;

  // has a place, or at least the full country name
  // derived from Google reverse geocoding addresses
  bool get hasFineAddress => _addressDetails?.place?.isNotEmpty == true || (_addressDetails?.countryName?.length ?? 0) > 3;

  Set<String>? _tags;

  Set<String> get tags {
    _tags ??= _catalogMetadata?.xmpSubjects?.split(';').where((tag) => tag.isNotEmpty).toSet() ?? {};
    return _tags!;
  }

  String? _bestTitle;

  @override
  String? get bestTitle {
    _bestTitle ??= _catalogMetadata?.xmpTitle?.isNotEmpty == true ? _catalogMetadata!.xmpTitle : (filenameWithoutExtension ?? sourceTitle);
    return _bestTitle;
  }

  int? get catalogDateMillis => _catalogDateMillis;

  set catalogDateMillis(int? dateMillis) {
    _catalogDateMillis = dateMillis;
    _bestDate = null;
  }

  CatalogMetadata? get catalogMetadata => _catalogMetadata;

  set catalogMetadata(CatalogMetadata? newMetadata) {
    final oldMimeType = mimeType;
    final oldDateModifiedMillis = dateModifiedMillis;
    final oldRotationDegrees = rotationDegrees;
    final oldIsFlipped = isFlipped;

    catalogDateMillis = newMetadata?.dateMillis;
    _catalogMetadata = newMetadata;
    _bestTitle = null;
    _tags = null;
    metadataChangeNotifier.notify();

    _onVisualFieldChanged(oldMimeType, oldDateModifiedMillis, oldRotationDegrees, oldIsFlipped);
  }

  void clearMetadata() {
    catalogMetadata = null;
    addressDetails = null;
  }

  AddressDetails? get addressDetails => _addressDetails;

  set addressDetails(AddressDetails? newAddress) {
    _addressDetails = newAddress;
    addressChangeNotifier.notify();
  }

  String get shortAddress {
    // `admin area` examples: Seoul, Geneva, null
    // `locality` examples: Mapo-gu, Geneva, Annecy
    return {
      _addressDetails?.countryName,
      _addressDetails?.adminArea,
      _addressDetails?.locality,
    }.nonNulls.where((v) => v.isNotEmpty).join(', ');
  }

  static void normalizeMimeTypeFields(Map fields) {
    final mimeType = fields[EntryFields.mimeType] as String?;
    if (mimeType != null) {
      fields[EntryFields.mimeType] = MimeTypes.normalize(mimeType);
    }
    final sourceMimeType = fields[EntryFields.sourceMimeType] as String?;
    if (sourceMimeType != null) {
      fields[EntryFields.sourceMimeType] = MimeTypes.normalize(sourceMimeType);
    }
  }

  Future<void> applyNewFields(Map newFields, {required bool persist}) async {
    final oldMimeType = mimeType;
    final oldDateModifiedMillis = this.dateModifiedMillis;
    final oldRotationDegrees = this.rotationDegrees;
    final oldIsFlipped = this.isFlipped;

    final uri = newFields[EntryFields.uri];
    if (uri is String) this.uri = uri;
    final path = newFields[EntryFields.path];
    if (path is String) this.path = path;
    final contentId = newFields[EntryFields.contentId];
    if (contentId is int) this.contentId = contentId;

    final sourceTitle = newFields[EntryFields.title];
    if (sourceTitle is String) this.sourceTitle = sourceTitle;
    final sourceRotationDegrees = newFields[EntryFields.sourceRotationDegrees];
    if (sourceRotationDegrees is int) this.sourceRotationDegrees = sourceRotationDegrees;
    final sourceDateTakenMillis = newFields[EntryFields.sourceDateTakenMillis];
    if (sourceDateTakenMillis is int) this.sourceDateTakenMillis = sourceDateTakenMillis;

    final width = newFields[EntryFields.width];
    if (width is int) this.width = width;
    final height = newFields[EntryFields.height];
    if (height is int) this.height = height;
    final durationMillis = newFields[EntryFields.durationMillis];
    if (durationMillis is int) this.durationMillis = durationMillis;

    final sizeBytes = newFields[EntryFields.sizeBytes];
    if (sizeBytes is int) this.sizeBytes = sizeBytes;
    final dateModifiedMillis = newFields[EntryFields.dateModifiedMillis];
    if (dateModifiedMillis is int) this.dateModifiedMillis = dateModifiedMillis;
    final rotationDegrees = newFields[EntryFields.rotationDegrees];
    if (rotationDegrees is int) this.rotationDegrees = rotationDegrees;
    final isFlipped = newFields[EntryFields.isFlipped];
    if (isFlipped is bool) this.isFlipped = isFlipped;

    if (persist) {
      await localMediaDb.updateEntry(id, this);
      if (catalogMetadata != null) await localMediaDb.saveCatalogMetadata({catalogMetadata!});
    }

    await _onVisualFieldChanged(oldMimeType, oldDateModifiedMillis, oldRotationDegrees, oldIsFlipped);
    metadataChangeNotifier.notify();
  }

  Future<void> refresh({
    required bool background,
    required bool persist,
    required Set<EntryDataType> dataTypes,
  }) async {
    // clear derived fields
    _bestDate = null;
    _bestTitle = null;
    _tags = null;

    if (persist) {
      await localMediaDb.removeIds({id}, dataTypes: dataTypes);
    }

    final updatedEntry = await mediaFetchService.getEntry(uri, mimeType);
    if (updatedEntry != null) {
      await applyNewFields(updatedEntry.toDatabaseMap(), persist: persist);
    }
  }

  Future<bool> delete() {
    final opCompleter = Completer<bool>();
    mediaEditService.delete(entries: {this}).listen(
      (event) => opCompleter.complete(event.success && !event.skipped),
      onError: opCompleter.completeError,
      onDone: () {
        if (!opCompleter.isCompleted) {
          opCompleter.complete(false);
        }
      },
    );
    return opCompleter.future;
  }

  // when the MIME type or the image itself changed (e.g. after rotation)
  Future<void> _onVisualFieldChanged(
    String oldMimeType,
    int? oldDateModifiedMillis,
    int oldRotationDegrees,
    bool oldIsFlipped,
  ) async {
    if ((!MimeTypes.refersToSameType(oldMimeType, mimeType) && !MimeTypes.isVideo(oldMimeType)) || oldDateModifiedMillis != dateModifiedMillis || oldRotationDegrees != rotationDegrees || oldIsFlipped != isFlipped) {
      await EntryCache.evict(uri, oldMimeType, oldDateModifiedMillis, oldRotationDegrees, oldIsFlipped, isAnimated);
      visualChangeNotifier.notify();
    }
  }
}
