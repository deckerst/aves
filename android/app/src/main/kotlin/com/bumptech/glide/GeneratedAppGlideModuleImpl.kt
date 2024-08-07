package com.bumptech.glide

import android.content.Context
import deckers.thibault.aves.decoder.AvesAppGlideModule
import deckers.thibault.aves.decoder.MultiPageImageGlideModule
import deckers.thibault.aves.decoder.SvgGlideModule
import deckers.thibault.aves.decoder.TiffGlideModule
import deckers.thibault.aves.decoder.VideoThumbnailGlideModule
import kotlin.Boolean
import kotlin.Suppress
import kotlin.Unit

internal class GeneratedAppGlideModuleImpl(
  @Suppress("UNUSED_PARAMETER")
  context: Context,
) : GeneratedAppGlideModule() {
  private val appGlideModule: AvesAppGlideModule
  init {
    appGlideModule = AvesAppGlideModule()
  }

  public override fun registerComponents(
    context: Context,
    glide: Glide,
    registry: Registry,
  ): Unit {
    MultiPageImageGlideModule().registerComponents(context, glide, registry)
    SvgGlideModule().registerComponents(context, glide, registry)
    TiffGlideModule().registerComponents(context, glide, registry)
    VideoThumbnailGlideModule().registerComponents(context, glide, registry)
    appGlideModule.registerComponents(context, glide, registry)
  }

  public override fun applyOptions(context: Context, builder: GlideBuilder): Unit {
    appGlideModule.applyOptions(context, builder)
  }

  public override fun isManifestParsingEnabled(): Boolean = false
}
