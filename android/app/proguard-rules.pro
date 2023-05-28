-keep class org.beyka.tiffbitmapfactory.**{ *; }
-keep class org.mp4parser.**{ *; }

# referenced from: com.google.crypto.tink
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**

# report all the code that R8 removed (<output-dir> is `/build/app/outputs/mapping/[build]/`)
-printusage <output-dir>/usage.txt
