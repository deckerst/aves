import 'package:aves/model/availability.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/media_store_service.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/services/time_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

final availability = getIt<AvesAvailability>();
final metadataDb = getIt<MetadataDb>();

final imageFileService = getIt<ImageFileService>();
final mediaStoreService = getIt<MediaStoreService>();
final metadataService = getIt<MetadataService>();
final timeService = getIt<TimeService>();

void initPlatformServices() {
  getIt.registerLazySingleton<AvesAvailability>(() => LiveAvesAvailability());
  getIt.registerLazySingleton<MetadataDb>(() => SqfliteMetadataDb());

  getIt.registerLazySingleton<ImageFileService>(() => PlatformImageFileService());
  getIt.registerLazySingleton<MediaStoreService>(() => PlatformMediaStoreService());
  getIt.registerLazySingleton<MetadataService>(() => PlatformMetadataService());
  getIt.registerLazySingleton<TimeService>(() => PlatformTimeService());
}
