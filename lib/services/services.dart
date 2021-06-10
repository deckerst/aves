import 'package:aves/model/availability.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/services/embedded_data_service.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/media_store_service.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/services/storage_service.dart';
import 'package:aves/services/time_service.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

final getIt = GetIt.instance;

final p.Context pContext = getIt<p.Context>();
final AvesAvailability availability = getIt<AvesAvailability>();
final MetadataDb metadataDb = getIt<MetadataDb>();

final EmbeddedDataService embeddedDataService = getIt<EmbeddedDataService>();
final ImageFileService imageFileService = getIt<ImageFileService>();
final MediaStoreService mediaStoreService = getIt<MediaStoreService>();
final MetadataService metadataService = getIt<MetadataService>();
final StorageService storageService = getIt<StorageService>();
final TimeService timeService = getIt<TimeService>();

void initPlatformServices() {
  getIt.registerLazySingleton<p.Context>(() => p.Context());
  getIt.registerLazySingleton<AvesAvailability>(() => LiveAvesAvailability());
  getIt.registerLazySingleton<MetadataDb>(() => SqfliteMetadataDb());

  getIt.registerLazySingleton<EmbeddedDataService>(() => PlatformEmbeddedDataService());
  getIt.registerLazySingleton<ImageFileService>(() => PlatformImageFileService());
  getIt.registerLazySingleton<MediaStoreService>(() => PlatformMediaStoreService());
  getIt.registerLazySingleton<MetadataService>(() => PlatformMetadataService());
  getIt.registerLazySingleton<StorageService>(() => PlatformStorageService());
  getIt.registerLazySingleton<TimeService>(() => PlatformTimeService());
}
