package deckers.thibault.aves.metadata

// DNG v1.6.0.0
// cf https://helpx.adobe.com/content/dam/help/en/photoshop/pdf/dng_spec_1_6_0_0.pdf
object DngTags {
    private const val DNG_VERSION = 0xC612
    private const val DNG_BACKWARD_VERSION = 0xC613
    private const val UNIQUE_CAMERA_MODEL = 0xC614
    private const val LOCALIZED_CAMERA_MODEL = 0xC615
    private const val CFA_PLANE_COLOR = 0xC616
    private const val CFA_LAYOUT = 0xC617
    private const val LINEARIZATION_TABLE = 0xC618
    private const val BLACK_LEVEL_REPEAT_DIM = 0xC619
    private const val BLACK_LEVEL = 0xC61A
    private const val BLACK_LEVEL_DELTA_H = 0xC61B
    private const val BLACK_LEVEL_DELTA_V = 0xC61C
    private const val WHITE_LEVEL = 0xC61D
    private const val DEFAULT_SCALE = 0xC61E
    private const val DEFAULT_CROP_ORIGIN = 0xC61F
    private const val DEFAULT_CROP_SIZE = 0xC620
    private const val COLOR_MATRIX_1 = 0xC621
    private const val COLOR_MATRIX_2 = 0xC622
    private const val CAMERA_CALIBRATION_1 = 0xC623
    private const val CAMERA_CALIBRATION_2 = 0xC624
    private const val REDUCTION_MATRIX_1 = 0xC625
    private const val REDUCTION_MATRIX_2 = 0xC626
    private const val ANALOG_BALANCE = 0xC627
    private const val AS_SHOT_NEUTRAL = 0xC628
    private const val AS_SHOT_WHITE_XY = 0xC629
    private const val BASELINE_EXPOSURE = 0xC62A
    private const val BASELINE_NOISE = 0xC62B
    private const val BASELINE_SHARPNESS = 0xC62C
    private const val BAYER_GREEN_SPLIT = 0xC62D
    private const val LINEAR_RESPONSE_LIMIT = 0xC62E
    private const val CAMERA_SERIAL_NUMBER = 0xC62F
    private const val LENS_INFO = 0xC630
    private const val CHROMA_BLUR_RADIUS = 0xC631
    private const val ANTI_ALIAS_STRENGTH = 0xC632
    private const val SHADOW_SCALE = 0xC633
    private const val DNG_PRIVATE_DATA = 0xC634
    private const val MAKER_NOTE_SAFETY = 0xC635
    private const val CALIBRATION_ILLUMINANT_1 = 0xC65A
    private const val CALIBRATION_ILLUMINANT_2 = 0xC65B
    private const val BEST_QUALITY_SCALE = 0xC65C
    private const val RAW_DATA_UNIQUE_ID = 0xC65D
    private const val ORIGINAL_RAW_FILE_NAME = 0xC68B
    private const val ORIGINAL_RAW_FILE_DATA = 0xC68C
    private const val ACTIVE_AREA = 0xC68D
    private const val MASKED_AREAS = 0xC68E
    private const val AS_SHOT_ICC_PROFILE = 0xC68F
    private const val AS_SHOT_PRE_PROFILE_MATRIX = 0xC690
    private const val CURRENT_ICC_PROFILE = 0xC691
    private const val CURRENT_PRE_PROFILE_MATRIX = 0xC692
    private const val COLORIMETRIC_REFERENCE = 0xC6BF
    private const val CAMERA_CALIBRATION_SIGNATURE = 0xC6F3
    private const val PROFILE_CALIBRATION_SIGNATURE = 0xC6F4
    private const val EXTRA_CAMERA_PROFILES = 0xC6F5
    private const val AS_SHOT_PROFILE_NAME = 0xC6F6
    private const val NOISE_REDUCTION_APPLIED = 0xC6F7
    private const val PROFILE_NAME = 0xC6F8
    private const val PROFILE_HUE_SAT_MAP_DIMS = 0xC6F9
    private const val PROFILE_HUE_SAT_MAP_DATA_1 = 0xC6FA
    private const val PROFILE_HUE_SAT_MAP_DATA_2 = 0xC6FB
    private const val PROFILE_TONE_CURVE = 0xC6FC
    private const val PROFILE_EMBED_POLICY = 0xC6FD
    private const val PROFILE_COPYRIGHT = 0xC6FE
    private const val FORWARD_MATRIX_1 = 0xC714
    private const val FORWARD_MATRIX_2 = 0xC715
    private const val PREVIEW_APPLICATION_NAME = 0xC716
    private const val PREVIEW_APPLICATION_VERSION = 0xC717
    private const val PREVIEW_SETTINGS_NAME = 0xC718
    private const val PREVIEW_SETTINGS_DIGEST = 0xC719
    private const val PREVIEW_COLOR_SPACE = 0xC71A
    private const val PREVIEW_DATE_TIME = 0xC71B
    private const val RAW_IMAGE_DIGEST = 0xC71C
    private const val ORIGINAL_RAW_FILE_DIGEST = 0xC71D
    private const val SUB_TILE_BLOCK_SIZE = 0xC71E
    private const val ROW_INTERLEAVE_FACTOR = 0xC71F
    private const val PROFILE_LOOK_TABLE_DIMS = 0xC725
    private const val PROFILE_LOOK_TABLE_DATA = 0xC726
    private const val OPCODE_LIST_1 = 0xC740
    private const val OPCODE_LIST_2 = 0xC741
    private const val OPCODE_LIST_3 = 0xC74E
    private const val NOISE_PROFILE = 0xC761
    private const val ORIGINAL_DEFAULT_FINAL_SIZE = 0xC791
    private const val ORIGINAL_BEST_QUALITY_FINAL_SIZE = 0xC792
    private const val ORIGINAL_DEFAULT_CROP_SIZE = 0xC793
    private const val PROFILE_HUE_SAT_MAP_ENCODING = 0xC7A3
    private const val PROFILE_LOOK_TABLE_ENCODING = 0xC7A4
    private const val BASELINE_EXPOSURE_OFFSET = 0xC7A5
    private const val DEFAULT_BLACK_RENDER = 0xC7A6
    private const val NEW_RAW_IMAGE_DIGEST = 0xC7A7
    private const val RAW_TO_PREVIEW_GAIN = 0xC7A8
    private const val DEFAULT_USER_CROP = 0xC7B5
    private const val DEPTH_FORMAT = 0xC7E9
    private const val DEPTH_NEAR = 0xC7EA
    private const val DEPTH_FAR = 0xC7EB
    private const val DEPTH_UNITS = 0xC7EC
    private const val DEPTH_MEASURE_TYPE = 0xC7ED
    private const val ENHANCE_PARAMS = 0xC7EE
    private const val PROFILE_GAIN_TABLE_MAP = 0xCD2D
    private const val SEMANTIC_NAME = 0xCD2E
    private const val SEMANTIC_INSTANCE_ID = 0xCD30
    private const val CALIBRATION_ILLUMINANT_3 = 0xCD31
    private const val CAMERA_CALIBRATION_3 = 0xCD32
    private const val COLOR_MATRIX_3 = 0xCD33
    private const val FORWARD_MATRIX_3 = 0xCD34
    private const val ILLUMINANT_DATA_1 = 0xCD35
    private const val ILLUMINANT_DATA_2 = 0xCD36
    private const val ILLUMINANT_DATA_3 = 0xCD37
    private const val MASK_SUB_AREA = 0xCD38
    private const val PROFILE_HUE_SAT_MAP_DATA_3 = 0xCD39
    private const val REDUCTION_MATRIX_3 = 0xCD3A
    private const val RGB_TABLES = 0xCD3F

    val tagNameMap = hashMapOf(
        DNG_VERSION to "DNG Version",
        DNG_BACKWARD_VERSION to "DNG Backward Version",
        UNIQUE_CAMERA_MODEL to "Unique Camera Model",
        LOCALIZED_CAMERA_MODEL to "Localized Camera Model",
        CFA_PLANE_COLOR to "CFA Plane Color",
        CFA_LAYOUT to "CFA Layout",
        LINEARIZATION_TABLE to "Linearization Table",
        BLACK_LEVEL_REPEAT_DIM to "Black Level Repeat Dim",
        BLACK_LEVEL to "Black Level",
        BLACK_LEVEL_DELTA_H to "Black Level Delta H",
        BLACK_LEVEL_DELTA_V to "Black Level Delta V",
        WHITE_LEVEL to "White Level",
        DEFAULT_SCALE to "Default Scale",
        DEFAULT_CROP_ORIGIN to "Default Crop Origin",
        DEFAULT_CROP_SIZE to "Default Crop Size",
        COLOR_MATRIX_1 to "Color Matrix 1",
        COLOR_MATRIX_2 to "Color Matrix 2",
        CAMERA_CALIBRATION_1 to "Camera Calibration 1",
        CAMERA_CALIBRATION_2 to "Camera Calibration 2",
        REDUCTION_MATRIX_1 to "Reduction Matrix 1",
        REDUCTION_MATRIX_2 to "Reduction Matrix 2",
        ANALOG_BALANCE to "Analog Balance",
        AS_SHOT_NEUTRAL to "As Shot Neutral",
        AS_SHOT_WHITE_XY to "As Shot White XY",
        BASELINE_EXPOSURE to "Baseline Exposure",
        BASELINE_NOISE to "Baseline Noise",
        BASELINE_SHARPNESS to "Baseline Sharpness",
        BAYER_GREEN_SPLIT to "Bayer Green Split",
        LINEAR_RESPONSE_LIMIT to "Linear Response Limit",
        CAMERA_SERIAL_NUMBER to "Camera Serial Number",
        LENS_INFO to "Lens Info",
        CHROMA_BLUR_RADIUS to "Chroma Blur Radius",
        ANTI_ALIAS_STRENGTH to "Anti Alias Strength",
        SHADOW_SCALE to "Shadow Scale",
        DNG_PRIVATE_DATA to "DNG Private Data",
        MAKER_NOTE_SAFETY to "Maker Note Safety",
        CALIBRATION_ILLUMINANT_1 to "Calibration Illuminant 1",
        CALIBRATION_ILLUMINANT_2 to "Calibration Illuminant 2",
        BEST_QUALITY_SCALE to "Best Quality Scale",
        RAW_DATA_UNIQUE_ID to "Raw Data Unique ID",
        ORIGINAL_RAW_FILE_NAME to "Original Raw File Name",
        ORIGINAL_RAW_FILE_DATA to "Original Raw File Data",
        ACTIVE_AREA to "Active Area",
        MASKED_AREAS to "Masked Areas",
        AS_SHOT_ICC_PROFILE to "As Shot ICC Profile",
        AS_SHOT_PRE_PROFILE_MATRIX to "As Shot Pre Profile Matrix",
        CURRENT_ICC_PROFILE to "Current ICC Profile",
        CURRENT_PRE_PROFILE_MATRIX to "Current Pre Profile Matrix",
        COLORIMETRIC_REFERENCE to "Colorimetric Reference",
        CAMERA_CALIBRATION_SIGNATURE to "Camera Calibration Signature",
        PROFILE_CALIBRATION_SIGNATURE to "Profile Calibration Signature",
        EXTRA_CAMERA_PROFILES to "Extra Camera Profiles",
        AS_SHOT_PROFILE_NAME to "As Shot Profile Name",
        NOISE_REDUCTION_APPLIED to "Noise Reduction Applied",
        PROFILE_NAME to "Profile Name",
        PROFILE_HUE_SAT_MAP_DIMS to "Profile Hue Sat Map Dims",
        PROFILE_HUE_SAT_MAP_DATA_1 to "Profile Hue Sat Map Data 1",
        PROFILE_HUE_SAT_MAP_DATA_2 to "Profile Hue Sat Map Data 2",
        PROFILE_TONE_CURVE to "Profile Tone Curve",
        PROFILE_EMBED_POLICY to "Profile Embed Policy",
        PROFILE_COPYRIGHT to "Profile Copyright",
        FORWARD_MATRIX_1 to "Forward Matrix 1",
        FORWARD_MATRIX_2 to "Forward Matrix 2",
        PREVIEW_APPLICATION_NAME to "Preview Application Name",
        PREVIEW_APPLICATION_VERSION to "Preview Application Version",
        PREVIEW_SETTINGS_NAME to "Preview Settings Name",
        PREVIEW_SETTINGS_DIGEST to "Preview Settings Digest",
        PREVIEW_COLOR_SPACE to "Preview Color Space",
        PREVIEW_DATE_TIME to "Preview Date Time",
        RAW_IMAGE_DIGEST to "Raw Image Digest",
        ORIGINAL_RAW_FILE_DIGEST to "Original Raw File Digest",
        SUB_TILE_BLOCK_SIZE to "Sub Tile Block Size",
        ROW_INTERLEAVE_FACTOR to "Row Interleave Factor",
        PROFILE_LOOK_TABLE_DIMS to "Profile Look Table Dims",
        PROFILE_LOOK_TABLE_DATA to "Profile Look Table Data",
        OPCODE_LIST_1 to "Opcode List 1",
        OPCODE_LIST_2 to "Opcode List 2",
        OPCODE_LIST_3 to "Opcode List 3",
        NOISE_PROFILE to "Noise Profile",
        ORIGINAL_DEFAULT_FINAL_SIZE to "Original Default Final Size",
        ORIGINAL_BEST_QUALITY_FINAL_SIZE to "Original Best Quality Final Size",
        ORIGINAL_DEFAULT_CROP_SIZE to "Original Default Crop Size",
        PROFILE_HUE_SAT_MAP_ENCODING to "Profile Hue Sat Map Encoding",
        PROFILE_LOOK_TABLE_ENCODING to "Profile Look Table Encoding",
        BASELINE_EXPOSURE_OFFSET to "Baseline Exposure Offset",
        DEFAULT_BLACK_RENDER to "Default Black Render",
        NEW_RAW_IMAGE_DIGEST to "New Raw Image Digest",
        RAW_TO_PREVIEW_GAIN to "Raw To Preview Gain",
        DEFAULT_USER_CROP to "Default User Crop",
        DEPTH_FORMAT to "Depth Format",
        DEPTH_NEAR to "Depth Near",
        DEPTH_FAR to "Depth Far",
        DEPTH_UNITS to "Depth Units",
        DEPTH_MEASURE_TYPE to "Depth Measure Type",
        ENHANCE_PARAMS to "Enhance Params",
        PROFILE_GAIN_TABLE_MAP to "Profile Gain Table Map",
        SEMANTIC_NAME to "Semantic Name",
        SEMANTIC_INSTANCE_ID to "Semantic Instance ID",
        CALIBRATION_ILLUMINANT_3 to "Calibration Illuminant 3",
        CAMERA_CALIBRATION_3 to "Camera Calibration 3",
        COLOR_MATRIX_3 to "Color Matrix 3",
        FORWARD_MATRIX_3 to "Forward Matrix 3",
        ILLUMINANT_DATA_1 to "Illuminant Data 1",
        ILLUMINANT_DATA_2 to "Illuminant Data 2",
        ILLUMINANT_DATA_3 to "Illuminant Data 3",
        MASK_SUB_AREA to "Mask Sub Area",
        PROFILE_HUE_SAT_MAP_DATA_3 to "Profile Hue Sat Map Data 3",
        REDUCTION_MATRIX_3 to "Reduction Matrix 3",
        RGB_TABLES to "RGB Tables",
    )

    val tags = tagNameMap.keys
}
