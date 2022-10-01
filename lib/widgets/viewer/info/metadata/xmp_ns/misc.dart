import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';

class XmpDarktableNamespace extends XmpNamespace {
  XmpDarktableNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.darktable, nsPrefix, rawProps);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'history\[(\d+)\]/(.*)')),
  ];
}

class XmpDwcNamespace extends XmpNamespace {
  XmpDwcNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.dwc, nsPrefix, rawProps);

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
  XmpIptcCoreNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.iptc4xmpCore, nsPrefix, rawProps);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'CreatorContactInfo/(.*)')),
  ];
}

class XmpIptc4xmpExtNamespace extends XmpNamespace {
  XmpIptc4xmpExtNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.iptc4xmpExt, nsPrefix, rawProps);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'ArtworkOrObject\[(\d+)\]/(.*)')),
  ];
}

class XmpMPNamespace extends XmpNamespace {
  XmpMPNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.mp, nsPrefix, rawProps);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'RegionInfo/MPRI:Regions\[(\d+)\]/(.*)'), title: 'Regions'),
  ];
}

// cf www.metadataworkinggroup.org/pdf/mwg_guidance.pdf (down, as of 2021/02/15)
class XmpMgwRegionsNamespace extends XmpNamespace {
  XmpMgwRegionsNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.mwgrs, nsPrefix, rawProps);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'Regions/mwg-rs:AppliedToDimensions/(.*)'), title: 'Applied to Dimensions'),
    XmpCardData(RegExp(nsPrefix + r'Regions/mwg-rs:RegionList\[(\d+)\]/(.*)'), title: 'Region List'),
  ];
}

class XmpPlusNamespace extends XmpNamespace {
  XmpPlusNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.plus, nsPrefix, rawProps);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'Licensor\[(\d+)\]/(.*)')),
  ];
}

class XmpMMNamespace extends XmpNamespace {
  XmpMMNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.xmpMM, nsPrefix, rawProps);

  @override
  late final List<XmpCardData> cards = [
    XmpCardData(RegExp(nsPrefix + r'DerivedFrom/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'History\[(\d+)\]/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'Ingredients\[(\d+)\]/(.*)')),
    XmpCardData(RegExp(nsPrefix + r'Pantry\[(\d+)\]/(.*)')),
  ];
}
