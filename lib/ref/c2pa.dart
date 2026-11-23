// cf https://spec.c2pa.org/specifications/specifications/2.2/specs/C2PA_Specification.html#standard-assertions
class C2paAssertions {
  static final actionPrefixPattern = RegExp('(aves||c2pa||cawg||stds)\\.');

  static const all = {
    actionsV2,
    creativeWork,
    metadataC2pa,
    metadataCawg,
    metadataExif,
    metadataIptc,
    hashBmffV2,
    hashBmffV3,
    hashDataPart,
    hashMultiAsset,
    identity,
    softBinding,
    trainingMiningC2pa,
    trainingMiningCawg,
  };

  // displayed
  static const actionsV2 = 'c2pa.actions.v2';
  static const creativeWork = 'stds.schema-org.CreativeWork';
  static const metadataC2pa = 'c2pa.metadata';
  static const metadataCawg = 'cawg.metadata';
  static const metadataExif = 'stds.exif';
  static const metadataIptc = 'stds.iptc';

  // others
  static const hashBmffV2 = 'c2pa.hash.bmff.v2';
  static const hashBmffV3 = 'c2pa.hash.bmff.v3';
  static const hashDataPart = 'c2pa.hash.data.part';
  static const hashMultiAsset = 'c2pa.hash.multi-asset';
  static const identity = 'cawg.identity';
  static const softBinding = 'c2pa.soft-binding';
  static const trainingMiningC2pa = 'c2pa.training-mining';
  static const trainingMiningCawg = 'cawg.training-mining';
}

// cf https://spec.c2pa.org/specifications/specifications/2.2/specs/C2PA_Specification.html#list-of-actions
class C2paActions {
  static const editedMetadata = 'c2pa.edited.metadata';
}

class AvesC2paActions {
  static const date = 'aves.date';
  static const description = 'aves.description';
  static const location = 'aves.location';
  static const rating = 'aves.rating';
  static const orientation = 'aves.orientation';
  static const redaction = 'aves.redaction';
  static const tags = 'aves.tags';
}

class CreativeWorkAuthorTypes {
  static const organization = 'Organization';
  static const person = 'Person';
}

// cf https://cv.iptc.org/newscodes/digitalsourcetype/
class DigitalSourceTypes {
  static const _root = 'http://cv.iptc.org/newscodes/digitalsourcetype';

  static const compositeSynthetic = '$_root/compositeSynthetic';
  static const compositeWithTrainedAlgorithmicMedia = '$_root/compositeWithTrainedAlgorithmicMedia';
  static const trainedAlgorithmicMedia = '$_root/trainedAlgorithmicMedia';

  static const genAiSources = {
    compositeSynthetic,
    compositeWithTrainedAlgorithmicMedia,
    trainedAlgorithmicMedia,
  };

  static const names = {
    compositeSynthetic: 'Composite including generative AI elements',
    compositeWithTrainedAlgorithmicMedia: 'Edited using Generative AI',
    trainedAlgorithmicMedia: 'Created using Generative AI',
  };
}
