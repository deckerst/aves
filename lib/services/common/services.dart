import 'package:aves/model/availability.dart';
import 'package:aves/model/db/db.dart';
import 'package:aves/model/db/db_sqflite.dart';
import 'package:aves/model/settings/store_shared_pref.dart';
import 'package:aves/services/app_service.dart';
import 'package:aves/services/device_service.dart';
import 'package:aves/services/media/embedded_data_service.dart';
import 'package:aves/services/media/media_edit_service.dart';
import 'package:aves/services/media/media_fetch_service.dart';
import 'package:aves/services/media/media_session_service.dart';
import 'package:aves/services/media/media_store_service.dart';
import 'package:aves/services/metadata/metadata_edit_service.dart';
import 'package:aves/services/metadata/metadata_fetch_service.dart';
import 'package:aves/services/security_service.dart';
import 'package:aves/services/storage_service.dart';
import 'package:aves/services/window_service.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_report/aves_report.dart';
import 'package:aves_report_platform/aves_report_platform.dart';
import 'package:aves_services/aves_services.dart';
import 'package:aves_services_platform/aves_services_platform.dart';
import 'package:aves_video/aves_video.dart';
import 'package:aves_video_ffmpeg/aves_video_ffmpeg.dart';
import 'package:aves_video_mpv/aves_video_mpv.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

final getIt = GetIt.instance;

// fixed implementation is easier for test driver setup
final SettingsStore settingsStore = SharedPrefSettingsStore();

final p.Context pContext = getIt<p.Context>();
final AvesAvailability availability = getIt<AvesAvailability>();
final LocalMediaDb localMediaDb = getIt<LocalMediaDb>();
final AvesVideoControllerFactory videoControllerFactory = getIt<AvesVideoControllerFactory>();
final AvesVideoMetadataFetcher videoMetadataFetcher = getIt<AvesVideoMetadataFetcher>();

final AppService appService = getIt<AppService>();
final DeviceService deviceService = getIt<DeviceService>();
final EmbeddedDataService embeddedDataService = getIt<EmbeddedDataService>();
final MediaEditService mediaEditService = getIt<MediaEditService>();
final MediaFetchService mediaFetchService = getIt<MediaFetchService>();
final MediaSessionService mediaSessionService = getIt<MediaSessionService>();
final MediaStoreService mediaStoreService = getIt<MediaStoreService>();
final MetadataEditService metadataEditService = getIt<MetadataEditService>();
final MetadataFetchService metadataFetchService = getIt<MetadataFetchService>();
final MobileServices mobileServices = getIt<MobileServices>();
final ReportService reportService = getIt<ReportService>();
final SecurityService securityService = getIt<SecurityService>();
final StorageService storageService = getIt<StorageService>();
final WindowService windowService = getIt<WindowService>();

void initPlatformServices() {
  getIt.registerLazySingleton<p.Context>(p.Context.new);
  getIt.registerLazySingleton<AvesAvailability>(LiveAvesAvailability.new);
  getIt.registerLazySingleton<LocalMediaDb>(SqfliteLocalMediaDb.new);
  getIt.registerLazySingleton<AvesVideoControllerFactory>(MpvVideoControllerFactory.new);
  getIt.registerLazySingleton<AvesVideoMetadataFetcher>(FfmpegVideoMetadataFetcher.new);

  getIt.registerLazySingleton<AppService>(PlatformAppService.new);
  getIt.registerLazySingleton<DeviceService>(PlatformDeviceService.new);
  getIt.registerLazySingleton<EmbeddedDataService>(PlatformEmbeddedDataService.new);
  getIt.registerLazySingleton<MediaEditService>(PlatformMediaEditService.new);
  getIt.registerLazySingleton<MediaFetchService>(PlatformMediaFetchService.new);
  getIt.registerLazySingleton<MediaSessionService>(PlatformMediaSessionService.new);
  getIt.registerLazySingleton<MediaStoreService>(PlatformMediaStoreService.new);
  getIt.registerLazySingleton<MetadataEditService>(PlatformMetadataEditService.new);
  getIt.registerLazySingleton<MetadataFetchService>(PlatformMetadataFetchService.new);
  getIt.registerLazySingleton<MobileServices>(PlatformMobileServices.new);
  getIt.registerLazySingleton<ReportService>(PlatformReportService.new);
  getIt.registerLazySingleton<SecurityService>(PlatformSecurityService.new);
  getIt.registerLazySingleton<StorageService>(PlatformStorageService.new);
  getIt.registerLazySingleton<WindowService>(PlatformWindowService.new);
}
