import 'package:aves/model/entry_metadata_edition.dart';
import 'package:aves/utils/xmp_utils.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  const toolkit = 'test-toolkit';

  String? _toExpect(String? xmpString) => xmpString != null
      ? XmlDocument.parse(xmpString).toXmlString(
          pretty: true,
          sortAttributes: (a, b) => a.name.qualified.compareTo(b.name.qualified),
        )
      : null;

  List<XmlNode> _getDescriptions(String xmpString) {
    final xmpDoc = XmlDocument.parse(xmpString);
    final root = xmpDoc.rootElement;
    final rdf = root.getElement(XMP.rdfRoot, namespace: Namespaces.rdf);
    return rdf!.children.where((node) {
      return node is XmlElement && node.name.local == XMP.rdfDescription && node.name.namespaceUri == Namespaces.rdf;
    }).toList();
  }

  const inMultiDescriptionRatings = '''
<x:xmpmeta xmlns:x="adobe:ns:meta/">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description xmlns:xmp="http://ns.adobe.com/xap/1.0/" rdf:about="uuid:faf5bdd5-ba3d-11da-ad31-d33d75182f1b">
      <xmp:Rating>5</xmp:Rating>
    </rdf:Description>
    <rdf:Description xmlns:MicrosoftPhoto="http://ns.microsoft.com/photo/1.0/" rdf:about="uuid:faf5bdd5-ba3d-11da-ad31-d33d75182f1b">
      <MicrosoftPhoto:Rating>99</MicrosoftPhoto:Rating>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
''';
  const inRatingAttribute = '''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core Test.SNAPSHOT">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description xmlns:xmp="http://ns.adobe.com/xap/1.0/" rdf:about="" xmp:Rating="5" />
  </rdf:RDF>
</x:xmpmeta>
''';
  const inRatingElement = '''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core Test.SNAPSHOT">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description xmlns:xmp="http://ns.adobe.com/xap/1.0/" rdf:about="">
      <xmp:Rating>5</xmp:Rating>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
''';
  const inSubjects = '''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core Test.SNAPSHOT">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
      xmlns:dc="http://purl.org/dc/elements/1.1/">
      <dc:subject>
        <rdf:Bag>
          <rdf:li>the king</rdf:li>
        </rdf:Bag>
      </dc:subject>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
''';
  const inSubjectsCreator = '''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core Test.SNAPSHOT">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
        xmlns:xmp="http://ns.adobe.com/xap/1.0/"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmp:ModifyDate="2021-12-24T21:41:46+09:00"
      xmp:MetadataDate="2021-12-24T21:41:46+09:00">
      <dc:creator>
        <rdf:Seq>
          <rdf:li>c</rdf:li>
        </rdf:Seq>
      </dc:creator>
      <dc:subject>
        <rdf:Bag>
          <rdf:li>a</rdf:li>
          <rdf:li>b</rdf:li>
        </rdf:Bag>
      </dc:subject>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
''';
  const inMotionPhotoMicroVideo = '''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core 5.1.0-jc003">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
      xmlns:GCamera="http://ns.google.com/photos/1.0/camera/"
      GCamera:MicroVideo="1"
      GCamera:MicroVideoVersion="1"
      GCamera:MicroVideoOffset="1228513"
      GCamera:MicroVideoPresentationTimestampUs="233246"/>
  </rdf:RDF>
</x:xmpmeta>
''';
  const inMotionPhotoContainer = '''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core 5.1.0-jc003">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
      xmlns:GCamera="http://ns.google.com/photos/1.0/camera/"
      xmlns:Container="http://ns.google.com/photos/1.0/container/"
      xmlns:Item="http://ns.google.com/photos/1.0/container/item/"
      GCamera:MotionPhoto="1"
      GCamera:MotionPhotoVersion="1"
      GCamera:MotionPhotoPresentationTimestampUs="2306056">
      <Container:Directory>
        <rdf:Seq>
          <rdf:li rdf:parseType="Resource">
            <Container:Item
              Item:Mime="image/jpeg"
              Item:Semantic="Primary"
              Item:Length="0"
              Item:Padding="59"/>
          </rdf:li>
          <rdf:li rdf:parseType="Resource">
            <Container:Item
              Item:Mime="video/mp4"
              Item:Semantic="MotionPhoto"
              Item:Length="3491777"
              Item:Padding="0"/>
          </rdf:li>
        </rdf:Seq>
      </Container:Directory>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
''';

  test('Get string', () async {
    expect(XMP.getString(_getDescriptions(inRatingAttribute), XMP.xmpRating, namespace: Namespaces.xmp), '5');
    expect(XMP.getString(_getDescriptions(inRatingElement), XMP.xmpRating, namespace: Namespaces.xmp), '5');
    expect(XMP.getString(_getDescriptions(inSubjects), XMP.xmpRating, namespace: Namespaces.xmp), null);
  });

  test('Set tags without existing XMP', () async {
    final modifyDate = DateTime.now();
    final xmpDate = XMP.toXmpDate(modifyDate);

    expect(
        _toExpect(await XMP.edit(
          null,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editTagsXmp(descriptions, {'one', 'two'}),
          modifyDate: modifyDate,
        )),
        _toExpect('''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="$toolkit">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:xmp="http://ns.adobe.com/xap/1.0/"
      xmp:MetadataDate="$xmpDate"
      xmp:ModifyDate="$xmpDate">
      <dc:subject>
        <rdf:Bag>
          <rdf:li>one</rdf:li>
          <rdf:li>two</rdf:li>
        </rdf:Bag>
      </dc:subject>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
'''));
  });

  test('Set tags to XMP with ratings (multiple descriptions)', () async {
    final modifyDate = DateTime.now();
    final xmpDate = XMP.toXmpDate(modifyDate);

    expect(
        _toExpect(await XMP.edit(
          inMultiDescriptionRatings,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editTagsXmp(descriptions, {'one', 'two'}),
          modifyDate: modifyDate,
        )),
        _toExpect('''
<x:xmpmeta xmlns:x="adobe:ns:meta/">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about="uuid:faf5bdd5-ba3d-11da-ad31-d33d75182f1b"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:xmp="http://ns.adobe.com/xap/1.0/"
      xmp:MetadataDate="$xmpDate"
      xmp:ModifyDate="$xmpDate">
      <xmp:Rating>5</xmp:Rating>
      <dc:subject>
        <rdf:Bag>
          <rdf:li>one</rdf:li>
          <rdf:li>two</rdf:li>
        </rdf:Bag>
      </dc:subject>
    </rdf:Description>
    <rdf:Description xmlns:MicrosoftPhoto="http://ns.microsoft.com/photo/1.0/" rdf:about="uuid:faf5bdd5-ba3d-11da-ad31-d33d75182f1b">
      <MicrosoftPhoto:Rating>99</MicrosoftPhoto:Rating>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
'''));
  });

  test('Set tags to XMP with subjects only', () async {
    final modifyDate = DateTime.now();
    final xmpDate = XMP.toXmpDate(modifyDate);

    expect(
        _toExpect(await XMP.edit(
          inSubjects,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editTagsXmp(descriptions, {'one', 'two'}),
          modifyDate: modifyDate,
        )),
        _toExpect('''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core Test.SNAPSHOT">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:xmp="http://ns.adobe.com/xap/1.0/"
      xmp:MetadataDate="$xmpDate"
      xmp:ModifyDate="$xmpDate">
      <dc:subject>
        <rdf:Bag>
          <rdf:li>one</rdf:li>
          <rdf:li>two</rdf:li>
        </rdf:Bag>
      </dc:subject>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
'''));
  });

  test('Remove tags from XMP with subjects only', () async {
    expect(
        _toExpect(await XMP.edit(
          inSubjects,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editTagsXmp(descriptions, {}),
        )),
        _toExpect(null));
  });

  test('Remove tags from XMP with subjects and creator', () async {
    final modifyDate = DateTime.now();
    final xmpDate = XMP.toXmpDate(modifyDate);

    expect(
        _toExpect(await XMP.edit(
          inSubjectsCreator,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editTagsXmp(descriptions, {}),
          modifyDate: modifyDate,
        )),
        _toExpect('''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core Test.SNAPSHOT">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:xmp="http://ns.adobe.com/xap/1.0/"
      xmp:MetadataDate="$xmpDate"
      xmp:ModifyDate="$xmpDate">
      <dc:creator>
        <rdf:Seq>
          <rdf:li>c</rdf:li>
        </rdf:Seq>
      </dc:creator>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
'''));
  });

  test('Set rating without existing XMP', () async {
    final modifyDate = DateTime.now();
    final xmpDate = XMP.toXmpDate(modifyDate);

    expect(
        _toExpect(await XMP.edit(
          null,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editRatingXmp(descriptions, 3),
          modifyDate: modifyDate,
        )),
        _toExpect('''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="$toolkit">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
      xmlns:xmp="http://ns.adobe.com/xap/1.0/"
      xmp:Rating="3"
      xmp:MetadataDate="$xmpDate"
      xmp:ModifyDate="$xmpDate" />
  </rdf:RDF>
</x:xmpmeta>
'''));
  });

  test('Set rating to XMP with ratings (multiple descriptions)', () async {
    final modifyDate = DateTime.now();
    final xmpDate = XMP.toXmpDate(modifyDate);

    expect(
        _toExpect(await XMP.edit(
          inMultiDescriptionRatings,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editRatingXmp(descriptions, 3),
          modifyDate: modifyDate,
        )),
        _toExpect('''
<x:xmpmeta xmlns:x="adobe:ns:meta/">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about="uuid:faf5bdd5-ba3d-11da-ad31-d33d75182f1b"
      xmlns:MicrosoftPhoto="http://ns.microsoft.com/photo/1.0/"
      xmlns:xmp="http://ns.adobe.com/xap/1.0/"
      MicrosoftPhoto:Rating="50"
      xmp:Rating="3"
      xmp:MetadataDate="$xmpDate"
      xmp:ModifyDate="$xmpDate" />
  </rdf:RDF>
</x:xmpmeta>
'''));
  });

  test('Set rating to XMP with rating attribute', () async {
    final modifyDate = DateTime.now();
    final xmpDate = XMP.toXmpDate(modifyDate);

    expect(
        _toExpect(await XMP.edit(
          inRatingAttribute,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editRatingXmp(descriptions, 3),
          modifyDate: modifyDate,
        )),
        _toExpect('''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core Test.SNAPSHOT">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
      xmlns:xmp="http://ns.adobe.com/xap/1.0/"
      xmp:Rating="3"
      xmp:MetadataDate="$xmpDate"
      xmp:ModifyDate="$xmpDate" />
  </rdf:RDF>
</x:xmpmeta>
'''));
  });

  test('Set rating to XMP with rating element', () async {
    final modifyDate = DateTime.now();
    final xmpDate = XMP.toXmpDate(modifyDate);

    expect(
        _toExpect(await XMP.edit(
          inRatingElement,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editRatingXmp(descriptions, 3),
          modifyDate: modifyDate,
        )),
        _toExpect('''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core Test.SNAPSHOT">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
      xmlns:xmp="http://ns.adobe.com/xap/1.0/"
      xmp:Rating="3"
      xmp:MetadataDate="$xmpDate"
      xmp:ModifyDate="$xmpDate" />
  </rdf:RDF>
</x:xmpmeta>
'''));
  });

  test('Set rating to XMP with subjects only', () async {
    final modifyDate = DateTime.now();
    final xmpDate = XMP.toXmpDate(modifyDate);

    expect(
        _toExpect(await XMP.edit(
          inSubjects,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editRatingXmp(descriptions, 3),
          modifyDate: modifyDate,
        )),
        _toExpect('''
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core Test.SNAPSHOT">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about=""
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:xmp="http://ns.adobe.com/xap/1.0/"
      xmp:Rating="3"
      xmp:MetadataDate="$xmpDate"
      xmp:ModifyDate="$xmpDate">
      <dc:subject>
        <rdf:Bag>
          <rdf:li>the king</rdf:li>
        </rdf:Bag>
      </dc:subject>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
'''));
  });

  test('Remove rating from XMP with subjects only', () async {
    final modifyDate = DateTime.now();

    expect(
        _toExpect(await XMP.edit(
          inSubjects,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editRatingXmp(descriptions, null),
          modifyDate: modifyDate,
        )),
        _toExpect(inSubjects));
  });

  test('Remove trailer media info from XMP with micro video', () async {
    final modifyDate = DateTime.now();

    expect(
        _toExpect(await XMP.edit(
          inMotionPhotoMicroVideo,
          () async => toolkit,
          ExtraAvesEntryMetadataEdition.removeContainerXmp,
          modifyDate: modifyDate,
        )),
        _toExpect(null));
  });

  test('Remove trailer media info from XMP with container', () async {
    final modifyDate = DateTime.now();

    expect(
        _toExpect(await XMP.edit(
          inMotionPhotoContainer,
          () async => toolkit,
          ExtraAvesEntryMetadataEdition.removeContainerXmp,
          modifyDate: modifyDate,
        )),
        _toExpect(null));
  });

  test('Remove trailer media info from XMP with no related metadata', () async {
    final modifyDate = DateTime.now();

    expect(
        _toExpect(await XMP.edit(
          inSubjects,
          () async => toolkit,
          ExtraAvesEntryMetadataEdition.removeContainerXmp,
          modifyDate: modifyDate,
        )),
        _toExpect(inSubjects));
  });

  test('Remove rating from XMP with ratings (multiple descriptions)', () async {
    final modifyDate = DateTime.now();

    expect(
        _toExpect(await XMP.edit(
          inMultiDescriptionRatings,
          () async => toolkit,
          (descriptions) => ExtraAvesEntryMetadataEdition.editRatingXmp(descriptions, null),
          modifyDate: modifyDate,
        )),
        _toExpect(null));
  });
}
