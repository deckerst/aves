import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';

class XmpCreatorAtom extends XmpNamespace {
  XmpCreatorAtom({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.creatorAtom);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'aeProjectLink/(.*)'), title: 'AE Project Link'),
  ];
}

class XmpDarktableNamespace extends XmpNamespace {
  XmpDarktableNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.darktable);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'history\[(\d+)\]/(.*)')),
  ];
}

class XmpDwcNamespace extends XmpNamespace {
  XmpDwcNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.dwc);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'dctermsLocation/(.*)'), title: 'DC Terms Location'),
    XmpCardData(RegExp(nsPrefix + r'Event/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'GeologicalContext/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'Identification/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'MeasurementOrFact/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'Occurrence/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'Record/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'ResourceRelationship/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'Taxon/(.*)')),
  ];
}

class XmpIptcCoreNamespace extends XmpNamespace {
  XmpIptcCoreNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.iptc4xmpCore);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'CreatorContactInfo/(.*)')),
  ];
}

class XmpIptc4xmpExtNamespace extends XmpNamespace {
  XmpIptc4xmpExtNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.iptc4xmpExt);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'ArtworkOrObject\[(\d+)\]/(.*)')),
  ];
}

class XmpMPNamespace extends XmpNamespace {
  XmpMPNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.mp);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'RegionInfo/MPRI:Regions\[(\d+)\]/(.*)'), title: 'Regions'),
  ];
}

// cf www.metadataworkinggroup.org/pdf/mwg_guidance.pdf (down, as of 2021/02/15)
class XmpMgwRegionsNamespace extends XmpNamespace {
  XmpMgwRegionsNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.mwgrs);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'Regions/mwg-rs:AppliedToDimensions/(.*)'), title: 'Applied to Dimensions'),
    XmpCardData(RegExp(nsPrefix + r'Regions/mwg-rs:RegionList\[(\d+)\]/(.*)'), title: 'Region List'),
  ];
}

class XmpPlusNamespace extends XmpNamespace {
  XmpPlusNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.plus);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'CopyrightOwner\[(\d+)\]/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'ImageCreator\[(\d+)\]/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'Licensor\[(\d+)\]/(.*)')),
  ];
}

class XmpMMNamespace extends XmpNamespace {
  XmpMMNamespace({required super.schemaRegistryPrefixes, required super.rawProps}) : super(nsUri: Namespaces.xmpMM);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'DerivedFrom/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'History\[(\d+)\]/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'Ingredients\[(\d+)\]/(.*)')),
    XmpCardData(
      RegExp(nsPrefix + r'Pantry\[(\d+)\]/(.*)'),
      cards: [
        XmpCardData(RegExp(nsPrefix + r'DerivedFrom/(.*)')),
        XmpCardData(RegExp(nsPrefix + r'History\[(\d+)\]/(.*)')),
      ],
    ),
  ];
}
