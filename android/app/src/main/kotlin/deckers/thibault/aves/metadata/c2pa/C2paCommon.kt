package deckers.thibault.aves.metadata.c2pa

import android.content.Context
import java.io.InputStreamReader

object C2paCommon {
    private val trustAnchorAssets = listOf(
        "C2PA-TRUST-LIST.pem",
        "C2PA-TSA-TRUST-LIST.pem",
    )

    private var trustAnchors: String? = null

    fun getTrustAnchors(context: Context): String {
        trustAnchors = trustAnchors ?: StringBuilder().apply {
            val assets = context.assets
            trustAnchorAssets.forEach {
                append(InputStreamReader(assets.open(it)).readText())
            }
        }.toString()
        return trustAnchors!!
    }
}