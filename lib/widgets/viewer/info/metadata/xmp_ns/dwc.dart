import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/widgets.dart';

class XmpDwcNamespace extends XmpNamespace {
  static const ns = 'dwc';

  static final dcTermsLocationPattern = RegExp(ns + r':dctermsLocation/(.*)');
  static final eventPattern = RegExp(ns + r':Event/(.*)');
  static final geologicalContextPattern = RegExp(ns + r':GeologicalContext/(.*)');
  static final identificationPattern = RegExp(ns + r':Identification/(.*)');
  static final measurementOrFactPattern = RegExp(ns + r':MeasurementOrFact/(.*)');
  static final occurrencePattern = RegExp(ns + r':Occurrence/(.*)');
  static final recordPattern = RegExp(ns + r':Record/(.*)');
  static final resourceRelationshipPattern = RegExp(ns + r':ResourceRelationship/(.*)');
  static final taxonPattern = RegExp(ns + r':Taxon/(.*)');

  final dcTermsLocation = <String, String>{};
  final event = <String, String>{};
  final identification = <String, String>{};
  final geologicalContext = <String, String>{};
  final measurementOrFact = <String, String>{};
  final occurrence = <String, String>{};
  final record = <String, String>{};
  final resourceRelationship = <String, String>{};
  final taxon = <String, String>{};

  XmpDwcNamespace(Map<String, String> rawProps) : super(ns, rawProps);

  @override
  bool extractData(XmpProp prop) {
    var hasStructs = extractStruct(prop, dcTermsLocationPattern, dcTermsLocation);
    hasStructs |= extractStruct(prop, eventPattern, event);
    hasStructs |= extractStruct(prop, geologicalContextPattern, geologicalContext);
    hasStructs |= extractStruct(prop, measurementOrFactPattern, measurementOrFact);
    hasStructs |= extractStruct(prop, identificationPattern, identification);
    hasStructs |= extractStruct(prop, occurrencePattern, occurrence);
    hasStructs |= extractStruct(prop, recordPattern, record);
    hasStructs |= extractStruct(prop, resourceRelationshipPattern, resourceRelationship);
    hasStructs |= extractStruct(prop, taxonPattern, taxon);
    return hasStructs;
  }

  @override
  List<Widget> buildFromExtractedData() => [
        if (dcTermsLocation.isNotEmpty)
          XmpStructCard(
            title: 'DC Terms Location',
            struct: dcTermsLocation,
          ),
        if (event.isNotEmpty)
          XmpStructCard(
            title: 'Event',
            struct: event,
          ),
        if (geologicalContext.isNotEmpty)
          XmpStructCard(
            title: 'Geological Context',
            struct: geologicalContext,
          ),
        if (identification.isNotEmpty)
          XmpStructCard(
            title: 'Identification',
            struct: identification,
          ),
        if (measurementOrFact.isNotEmpty)
          XmpStructCard(
            title: 'Measurement Or Fact',
            struct: measurementOrFact,
          ),
        if (occurrence.isNotEmpty)
          XmpStructCard(
            title: 'Occurrence',
            struct: occurrence,
          ),
        if (record.isNotEmpty)
          XmpStructCard(
            title: 'Record',
            struct: record,
          ),
        if (resourceRelationship.isNotEmpty)
          XmpStructCard(
            title: 'Resource Relationship',
            struct: resourceRelationship,
          ),
        if (taxon.isNotEmpty)
          XmpStructCard(
            title: 'Taxon',
            struct: taxon,
          ),
      ];
}
