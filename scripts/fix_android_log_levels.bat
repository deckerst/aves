@echo off
setlocal

if defined ANDROID_SDK_ROOT (set sdk=%ANDROID_SDK_ROOT%)
if defined ANDROID_SDK (set sdk=%ANDROID_SDK%)
cd /d %sdk%\platform-tools

@echo on

adb.exe shell setprop persist.log.tag.ACodec WARN
adb.exe shell setprop persist.log.tag.AHierarchicalStateMachine ERROR
adb.exe shell setprop persist.log.tag.AudioCapabilities ERROR
adb.exe shell setprop persist.log.tag.AudioTrack INFO
adb.exe shell setprop persist.log.tag.BufferPoolAccessor2.0 INFO
adb.exe shell setprop persist.log.tag.CCodec INFO
adb.exe shell setprop persist.log.tag.CCodecBufferChannel INFO
adb.exe shell setprop persist.log.tag.CCodecBuffers INFO
adb.exe shell setprop persist.log.tag.CCodecConfig INFO
adb.exe shell setprop persist.log.tag.Codec2Client INFO
adb.exe shell setprop persist.log.tag.CompatibilityChangeReporter INFO
adb.exe shell setprop persist.log.tag.Counters WARN
adb.exe shell setprop persist.log.tag.CustomizedTextParser INFO
adb.exe shell setprop persist.log.tag.EGL_emulation INFO
adb.exe shell setprop persist.log.tag.HostConnection INFO
adb.exe shell setprop persist.log.tag.InputMethodManager WARN
adb.exe shell setprop persist.log.tag.InsetsSourceConsumer INFO
adb.exe shell setprop persist.log.tag.InputTransport INFO
adb.exe shell setprop persist.log.tag.J4A INFO
adb.exe shell setprop persist.log.tag.MediaCodec WARN
adb.exe shell setprop persist.log.tag.MediaMetadataRetriever INFO
adb.exe shell setprop persist.log.tag.MediaMetadataRetrieverJNI INFO
adb.exe shell setprop persist.log.tag.NativeTiffDecoder INFO
adb.exe shell setprop persist.log.tag.NuMediaExtractor INFO
adb.exe shell setprop persist.log.tag.PipelineWatcher INFO
adb.exe shell setprop persist.log.tag.ReflectedParamUpdater INFO
adb.exe shell setprop persist.log.tag.skia INFO
adb.exe shell setprop persist.log.tag.SurfaceControl WARN
adb.exe shell setprop persist.log.tag.SurfaceUtils INFO
adb.exe shell setprop persist.log.tag.SurfaceView WARN
adb.exe shell setprop persist.log.tag.VideoCapabilities ERROR

@echo off
endlocal
