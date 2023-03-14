import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:aves/model/entry/cache.dart';
import 'package:aves/model/entry/dirs.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/model/metadata/catalog.dart';
import 'package:aves/model/metadata/trash.dart';
import 'package:aves/model/source/trash.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves_model/aves_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

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
  int? dateAddedSecs, _dateModifiedSecs, sourceDateTakenMillis, _durationMillis;
  bool trashed;
  int origin;

  int? _catalogDateMillis;
  CatalogMetadata? _catalogMetadata;
  AddressDetails? _addressDetails;
  TrashDetails? trashDetails;

  List<AvesEntry>? burstEntries;

  @override
  final AChangeNotifier visualChangeNotifier = AChangeNotifier();

  final AChangeNotifier metadataChangeNotifier = AChangeNotifier();
  final AChangeNotifier addressChangeNotifier = AChangeNotifier();

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
    required int? dateModifiedSecs,
    required this.sourceDateTakenMillis,
    required int? durationMillis,
    required this.trashed,
    required this.origin,
    this.burstEntries,
  }) : id = id ?? 0 {
    this.path = path;
    this.sourceTitle = sourceTitle;
    this.dateModifiedSecs = dateModifiedSecs;
    this.durationMillis = durationMillis;
  }

  bool get canDecode => !MimeTypes.undecodableImages.contains(mimeType);

  bool get canHaveAlpha => MimeTypes.alphaImages.contains(mimeType);

  AvesEntry copyWith({
    int? id,
    String? uri,
    String? path,
    int? contentId,
    String? title,
    int? dateAddedSecs,
    int? dateModifiedSecs,
    int? origin,
    List<AvesEntry>? burstEntries,
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
      dateModifiedSecs: dateModifiedSecs ?? this.dateModifiedSecs,
      sourceDateTakenMillis: sourceDateTakenMillis,
      durationMillis: durationMillis,
      trashed: trashed,
      origin: origin ?? this.origin,
      burstEntries: burstEntries ?? this.burstEntries,
    )
      ..catalogMetadata = _catalogMetadata?.copyWith(id: copyEntryId)
      ..addressDetails = _addressDetails?.copyWith(id: copyEntryId)
      ..trashDetails = trashDetails?.copyWith(id: copyEntryId);

    return copied;
  }

  // from DB or platform source entry
  factory AvesEntry.fromMap(Map map) {
    return AvesEntry(
      id: map['id'] as int?,
      uri: map['uri'] as String,
      path: map['path'] as String?,
      pageId: null,
      contentId: map['contentId'] as int?,
      sourceMimeType: map['sourceMimeType'] as String,
      width: map['width'] as int? ?? 0,
      height: map['height'] as int? ?? 0,
      sourceRotationDegrees: map['sourceRotationDegrees'] as int? ?? 0,
      sizeBytes: map['sizeBytes'] as int?,
      sourceTitle: map['title'] as String?,
      dateAddedSecs: map['dateAddedSecs'] as int?,
      dateModifiedSecs: map['dateModifiedSecs'] as int?,
      sourceDateTakenMillis: map['sourceDateTakenMillis'] as int?,
      durationMillis: map['durationMillis'] as int?,
      trashed: (map['trashed'] as int? ?? 0) != 0,
      origin: map['origin'] as int,
    );
  }

  // for DB only
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uri': uri,
      'path': path,
      'contentId': contentId,
      'sourceMimeType': sourceMimeType,
      'width': width,
      'height': height,
      'sourceRotationDegrees': sourceRotationDegrees,
      'sizeBytes': sizeBytes,
      'title': sourceTitle,
      'dateAddedSecs': dateAddedSecs,
      'dateModifiedSecs': dateModifiedSecs,
      'sourceDateTakenMillis': sourceDateTakenMillis,
      'durationMillis': durationMillis,
      'trashed': trashed ? 1 : 0,
      'origin': origin,
    };
  }

  Map<String, dynamic> toPlatformEntryMap() {
    return {
      'uri': uri,
      'path': path,
      'pageId': pageId,
      'mimeType': mimeType,
      'width': width,
      'height': height,
      'rotationDegrees': rotationDegrees,
      'isFlipped': isFlipped,
      'dateModifiedSecs': dateModifiedSecs,
      'sizeBytes': sizeBytes,
      'trashed': trashed,
      'trashPath': trashDetails?.path,
      'origin': origin,
    };
  }

  void dispose() {
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

  String? get storagePath => trashed ? trashDetails?.path : path;

  String? get storageDirectory => trashed ? pContext.dirname(trashDetails!.path) : directory;

  bool get isMissingAtPath {
    final _storagePath = storagePath;
    return _storagePath != null && !File(_storagePath).existsSync();
  }

  // the MIME type reported by the Media Store is unreliable
  // so we use the one found during cataloguing if possible
  String get mimeType => _catalogMetadata?.mimeType ?? sourceMimeType;

  bool get isCatalogued => _catalogMetadata != null;

  DateTime? _bestDate;

  DateTime? get bestDate {
    _bestDate ??= dateTimeFromMillis(_catalogDateMillis) ?? dateTimeFromMillis(sourceDateTakenMillis) ?? dateTimeFromMillis((dateModifiedSecs ?? 0) * 1000);
    return _bestDate;
  }

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

  int? get dateModifiedSecs => _dateModifiedSecs;

  set dateModifiedSecs(int? dateModifiedSecs) {
    _dateModifiedSecs = dateModifiedSecs;
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

  bool get isExpiredTrash {
    final dateMillis = trashDetails?.dateMillis;
    if (dateMillis == null) return false;
    return DateTime.fromMillisecondsSinceEpoch(dateMillis).add(TrashMixin.binKeepDuration).isBefore(DateTime.now());
  }

  int? get trashDaysLeft {
    final dateMillis = trashDetails?.dateMillis;
    if (dateMillis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(dateMillis).add(TrashMixin.binKeepDuration).difference(DateTime.now()).inDays;
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
    final oldDateModifiedSecs = dateModifiedSecs;
    final oldRotationDegrees = rotationDegrees;
    final oldIsFlipped = isFlipped;

    catalogDateMillis = newMetadata?.dateMillis;
    _catalogMetadata = newMetadata;
    _bestTitle = null;
    _tags = null;
    metadataChangeNotifier.notify();

    _onVisualFieldChanged(oldMimeType, oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
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
    }.whereNotNull().where((v) => v.isNotEmpty).join(', ');
  }

  Future<void> applyNewFields(Map newFields, {required bool persist}) async {
    final oldMimeType = mimeType;
    final oldDateModifiedSecs = this.dateModifiedSecs;
    final oldRotationDegrees = this.rotationDegrees;
    final oldIsFlipped = this.isFlipped;

    final uri = newFields['uri'];
    if (uri is String) this.uri = uri;
    final path = newFields['path'];
    if (path is String) this.path = path;
    final contentId = newFields['contentId'];
    if (contentId is int) this.contentId = contentId;

    final sourceTitle = newFields['title'];
    if (sourceTitle is String) this.sourceTitle = sourceTitle;
    final sourceRotationDegrees = newFields['sourceRotationDegrees'];
    if (sourceRotationDegrees is int) this.sourceRotationDegrees = sourceRotationDegrees;
    final sourceDateTakenMillis = newFields['sourceDateTakenMillis'];
    if (sourceDateTakenMillis is int) this.sourceDateTakenMillis = sourceDateTakenMillis;

    final width = newFields['width'];
    if (width is int) this.width = width;
    final height = newFields['height'];
    if (height is int) this.height = height;
    final durationMillis = newFields['durationMillis'];
    if (durationMillis is int) this.durationMillis = durationMillis;

    final sizeBytes = newFields['sizeBytes'];
    if (sizeBytes is int) this.sizeBytes = sizeBytes;
    final dateModifiedSecs = newFields['dateModifiedSecs'];
    if (dateModifiedSecs is int) this.dateModifiedSecs = dateModifiedSecs;
    final rotationDegrees = newFields['rotationDegrees'];
    if (rotationDegrees is int) this.rotationDegrees = rotationDegrees;
    final isFlipped = newFields['isFlipped'];
    if (isFlipped is bool) this.isFlipped = isFlipped;

    if (persist) {
      await metadataDb.saveEntries({this});
      if (catalogMetadata != null) await metadataDb.saveCatalogMetadata({catalogMetadata!});
    }

    await _onVisualFieldChanged(oldMimeType, oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
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
      await metadataDb.removeIds({id}, dataTypes: dataTypes);
    }

    final updatedEntry = await mediaFetchService.getEntry(uri, mimeType);
    if (updatedEntry != null) {
      await applyNewFields(updatedEntry.toMap(), persist: persist);
    }
  }

  Future<bool> delete() {
    final completer = Completer<bool>();
    mediaEditService.delete(entries: {this}).listen(
      (event) => completer.complete(event.success && !event.skipped),
      onError: completer.completeError,
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );
    return completer.future;
  }

  // when the MIME type or the image itself changed (e.g. after rotation)
  Future<void> _onVisualFieldChanged(
    String oldMimeType,
    int? oldDateModifiedSecs,
    int oldRotationDegrees,
    bool oldIsFlipped,
  ) async {
    if ((!MimeTypes.refersToSameType(oldMimeType, mimeType) && !MimeTypes.isVideo(oldMimeType)) || oldDateModifiedSecs != dateModifiedSecs || oldRotationDegrees != rotationDegrees || oldIsFlipped != isFlipped) {
      await EntryCache.evict(uri, oldMimeType, oldDateModifiedSecs, oldRotationDegrees, oldIsFlipped);
      visualChangeNotifier.notify();
    }
  }
}
