@echo off
setlocal

if defined ANDROID_SDK_ROOT (set sdk=%ANDROID_SDK_ROOT%)
if defined ANDROID_SDK (set sdk=%ANDROID_SDK%)
cd /d %sdk%\platform-tools

@echo on

adb.exe shell setprop log.tag.ACodec WARN
adb.exe shell setprop log.tag.AHierarchicalStateMachine ERROR
adb.exe shell setprop log.tag.AudioCapabilities ERROR
adb.exe shell setprop log.tag.AudioTrack INFO
adb.exe shell setprop log.tag.BufferPoolAccessor2.0 INFO
adb.exe shell setprop log.tag.CCodec INFO
adb.exe shell setprop log.tag.CCodecBufferChannel INFO
adb.exe shell setprop log.tag.CCodecBuffers INFO
adb.exe shell setprop log.tag.CCodecConfig INFO
adb.exe shell setprop log.tag.Codec2Client INFO
adb.exe shell setprop log.tag.CompatibilityChangeReporter INFO
adb.exe shell setprop log.tag.Counters WARN
adb.exe shell setprop log.tag.CustomizedTextParser INFO
adb.exe shell setprop log.tag.EGL_emulation INFO
adb.exe shell setprop log.tag.HostConnection INFO
adb.exe shell setprop log.tag.InputMethodManager WARN
adb.exe shell setprop log.tag.InsetsSourceConsumer INFO
adb.exe shell setprop log.tag.InputTransport INFO
adb.exe shell setprop log.tag.J4A INFO
adb.exe shell setprop log.tag.MediaCodec WARN
adb.exe shell setprop log.tag.MediaMetadataRetriever INFO
adb.exe shell setprop log.tag.MediaMetadataRetrieverJNI INFO
adb.exe shell setprop log.tag.NuMediaExtractor INFO
adb.exe shell setprop log.tag.PipelineWatcher INFO
adb.exe shell setprop log.tag.ReflectedParamUpdater INFO
adb.exe shell setprop log.tag.skia INFO
adb.exe shell setprop log.tag.SurfaceControl WARN
adb.exe shell setprop log.tag.SurfaceUtils INFO
adb.exe shell setprop log.tag.SurfaceView WARN
adb.exe shell setprop log.tag.VideoCapabilities ERROR

@echo off
endlocal
