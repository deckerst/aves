class AppDirs {
  // custom matches for album directory names that do not match their app names
  static final knownAppDirs = {
    // App name: "Photos"
    // https://play.google.com/store/apps/details?id=com.google.android.apps.photos
    'com.google.android.apps.photos': {
      'Google Photos',
    },

    // App name: "Instagram"
    // https://play.google.com/store/apps/details?id=com.instagram.android
    'com.instagram.android': {
      'Instagram/Images',
      'Instagram/Videos',
    },

    // App name: "Glow HDR"
    // https://play.google.com/store/apps/details?id=com.iunis.hdr.glow
    'com.iunis.hdr.glow': {
      'GlowHDR',
    },

    // App name: "KakaoTalk"
    // https://play.google.com/store/apps/details?id=com.kakao.talk
    'com.kakao.talk': {
      'KakaoTalkDownload',
    },

    // App name: "Imaging Edge"
    // https://play.google.com/store/apps/details?id=com.sony.playmemories.mobile
    'com.sony.playmemories.mobile': {
      'Imaging Edge Mobile',
    },

    // App name: "WhatsApp"
    // https://play.google.com/store/apps/details?id=com.whatsapp
    'com.whatsapp': {
      'WhatsApp Animated Gifs',
      'WhatsApp Documents',
      'WhatsApp Images',
      'WhatsApp Video',
    },

    // App name: "Nekogram X"
    // https://apt.izzysoft.de/fdroid/index/apk/nekox.messenger?repo=archive
    'nekox.messenger': {
      'NekoX',
    },

    // App name: "Telegram"
    // https://play.google.com/store/apps/details?id=org.telegram.messenger
    'org.telegram.messenger': {
      'Telegram Images',
      'Telegram Video',
    },

    // App name: "Image Toolbox"
    // https://play.google.com/store/apps/details?id=ru.tech.imageresizershrinker
    'ru.tech.imageresizershrinker': {
      'ImageToolbox',
    },
  };
}
