import 'package:aves/utils/xmp_utils.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_namespaces.dart';
import 'package:aves/widgets/viewer/info/metadata/xmp_structs.dart';
import 'package:flutter/widgets.dart';

class XmpDwcNamespace extends XmpNamespace {
  late final dcTermsLocationPattern = RegExp(nsPrefix + r'dctermsLocation/(.*)');
  late final eventPattern = RegExp(nsPrefix + r'Event/(.*)');
  late final geologicalContextPattern = RegExp(nsPrefix + r'GeologicalContext/(.*)');
  late final identificationPattern = RegExp(nsPrefix + r'Identification/(.*)');
  late final measurementOrFactPattern = RegExp(nsPrefix + r'MeasurementOrFact/(.*)');
  late final occurrencePattern = RegExp(nsPrefix + r'Occurrence/(.*)');
  late final recordPattern = RegExp(nsPrefix + r'Record/(.*)');
  late final resourceRelationshipPattern = RegExp(nsPrefix + r'ResourceRelationship/(.*)');
  late final taxonPattern = RegExp(nsPrefix + r'Taxon/(.*)');

  final dcTermsLocation = <String, String>{};
  final event = <String, String>{};
  final identification = <String, String>{};
  final geologicalContext = <String, String>{};
  final measurementOrFact = <String, String>{};
  final occurrence = <String, String>{};
  final record = <String, String>{};
  final resourceRelationship = <String, String>{};
  final taxon = <String, String>{};

  XmpDwcNamespace(String nsPrefix, Map<String, String> rawProps) : super(Namespaces.dwc, nsPrefix, rawProps);

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
