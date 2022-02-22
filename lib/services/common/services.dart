import 'package:aves/model/availability.dart';
import 'package:aves/model/db/db_metadata.dart';
import 'package:aves/model/db/db_metadata_sqflite.dart';
import 'package:aves/model/settings/store/store.dart';
import 'package:aves/model/settings/store/store_shared_pref.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/services/device_service.dart';
import 'package:aves/services/media/embedded_data_service.dart';
import 'package:aves/services/media/media_file_service.dart';
import 'package:aves/services/media/media_store_service.dart';
import 'package:aves/services/metadata/metadata_edit_service.dart';
import 'package:aves/services/metadata/metadata_fetch_service.dart';
import 'package:aves/services/storage_service.dart';
import 'package:aves/services/window_service.dart';
import 'package:aves_report/aves_report.dart';
import 'package:aves_report_platform/aves_report_platform.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

final getIt = GetIt.instance;

// fixed implementation is easier for test driver setup
final SettingsStore settingsStore = SharedPrefSettingsStore();

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
  getIt.registerLazySingleton<p.Context>(p.Context.new);
  getIt.registerLazySingleton<AvesAvailability>(LiveAvesAvailability.new);
  getIt.registerLazySingleton<MetadataDb>(SqfliteMetadataDb.new);

  getIt.registerLazySingleton<AndroidAppService>(PlatformAndroidAppService.new);
  getIt.registerLazySingleton<DeviceService>(PlatformDeviceService.new);
  getIt.registerLazySingleton<EmbeddedDataService>(PlatformEmbeddedDataService.new);
  getIt.registerLazySingleton<MediaFileService>(PlatformMediaFileService.new);
  getIt.registerLazySingleton<MediaStoreService>(PlatformMediaStoreService.new);
  getIt.registerLazySingleton<MetadataEditService>(PlatformMetadataEditService.new);
  getIt.registerLazySingleton<MetadataFetchService>(PlatformMetadataFetchService.new);
  getIt.registerLazySingleton<ReportService>(PlatformReportService.new);
  getIt.registerLazySingleton<StorageService>(PlatformStorageService.new);
  getIt.registerLazySingleton<WindowService>(PlatformWindowService.new);
}
