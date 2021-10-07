import 'package:aves/model/availability.dart';
import 'package:aves/model/metadata_db.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/device_service.dart';
import 'package:aves/services/media/embedded_data_service.dart';
import 'package:aves/services/media/media_file_service.dart';
import 'package:aves/services/media/media_store_service.dart';
import 'package:aves/services/metadata/metadata_edit_service.dart';
import 'package:aves/services/metadata/metadata_fetch_service.dart';
import 'package:aves/services/report_service.dart';
import 'package:aves/services/storage_service.dart';
import 'package:aves/services/window_service.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

final getIt = GetIt.instance;

final p.Context pContext = getIt<p.Context>();
final AvesAvailability availability = getIt<AvesAvailability>();
final MetadataDb metadataDb = getIt<MetadataDb>();

final AndroidAppService androidAppService = getIt<AndroidAppService>();
final DeviceService deviceService = getIt<DeviceService>();
final EmbeddedDataService embeddedDataService = getIt<EmbeddedDataService>();
final MediaFileService mediaFileService = getIt<MediaFileService>();
final MediaStoreService mediaStoreService = getIt<MediaStoreService>();
final MetadataEditService metadataEditService = getIt<MetadataEditService>();
final MetadataFetchService metadataFetchService = getIt<MetadataFetchService>();
final ReportService reportService = getIt<ReportService>();
final StorageService storageService = getIt<StorageService>();
final WindowService windowService = getIt<WindowService>();

void initPlatformServices() {
  getIt.registerLazySingleton<p.Context>(() => p.Context());
  getIt.registerLazySingleton<AvesAvailability>(() => LiveAvesAvailability());
  getIt.registerLazySingleton<MetadataDb>(() => SqfliteMetadataDb());

  getIt.registerLazySingleton<AndroidAppService>(() => PlatformAndroidAppService());
  getIt.registerLazySingleton<DeviceService>(() => PlatformDeviceService());
  getIt.registerLazySingleton<EmbeddedDataService>(() => PlatformEmbeddedDataService());
  getIt.registerLazySingleton<MediaFileService>(() => PlatformMediaFileService());
  getIt.registerLazySingleton<MediaStoreService>(() => PlatformMediaStoreService());
  getIt.registerLazySingleton<MetadataEditService>(() => PlatformMetadataEditService());
  getIt.registerLazySingleton<MetadataFetchService>(() => PlatformMetadataFetchService());
  getIt.registerLazySingleton<ReportService>(() => CrashlyticsReportService());
  getIt.registerLazySingleton<StorageService>(() => PlatformStorageService());
  getIt.registerLazySingleton<WindowService>(() => PlatformWindowService());
}
