class Assertions {
  static final actionPrefixPattern = RegExp('(c2pa||cawg||stds)\\.');

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
