package deckers.thibault.aves.decoder;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.load.Options;
import com.bumptech.glide.load.model.ModelLoader;
import com.bumptech.glide.load.model.ModelLoaderFactory;
import com.bumptech.glide.load.model.MultiModelLoaderFactory;
import com.bumptech.glide.signature.ObjectKey;

import java.io.InputStream;

class VideoThumbnailLoader implements ModelLoader<VideoThumbnail, InputStream> {
    @Nullable
    @Override
    public LoadData<InputStream> buildLoadData(@NonNull VideoThumbnail model, int width, int height, @NonNull Options options) {
        return new LoadData<>(new ObjectKey(model.getUri()), new VideoThumbnailFetcher(model));
    }

    @Override
    public boolean handles(@NonNull VideoThumbnail videoThumbnail) {
        return true;
    }

    static class Factory implements ModelLoaderFactory<VideoThumbnail, InputStream> {
        @NonNull
        @Override
        public ModelLoader<VideoThumbnail, InputStream> build(@NonNull MultiModelLoaderFactory multiFactory) {
            return new VideoThumbnailLoader();
        }

        @Override
        public void teardown() {
        }
    }
}
