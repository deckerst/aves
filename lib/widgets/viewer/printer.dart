import 'dart:convert';

import 'package:aves/image_providers/uri_image_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:pedantic/pedantic.dart';
import 'package:printing/printing.dart';

class EntryPrinter {
  final ImageEntry entry;

  const EntryPrinter(this.entry);

  Future<void> print() async {
    final documentName = entry.bestTitle ?? 'Aves';
    final doc = pdf.Document(title: documentName);

    final pages = await _buildPages();
    if (pages.isNotEmpty) {
      pages.forEach(doc.addPage); // Page
      unawaited(Printing.layoutPdf(
        onLayout: (format) => doc.save(),
        name: documentName,
      ));
    }
  }

  Future<List<pdf.Page>> _buildPages() async {
    final pages = <pdf.Page>[];

    void _addPdfPage(pdf.Widget pdfChild) {
      if (pdfChild == null) return;
      pages.add(pdf.Page(
        orientation: entry.isPortrait ? pdf.PageOrientation.portrait : pdf.PageOrientation.landscape,
        build: (context) => pdf.FullPage(
          ignoreMargins: true,
          child: pdf.Center(
            child: pdfChild,
          ),
        ),
      ));
    }

    if (entry.isMultipage) {
      final multiPageInfo = await MetadataService.getMultiPageInfo(entry);
      if (multiPageInfo.pageCount > 1) {
        for (final kv in multiPageInfo.pages.entries) {
          _addPdfPage(await _buildPageImage(page: kv.key));
        }
      }
    }
    if (pages.isEmpty) {
      _addPdfPage(await _buildPageImage());
    }
    return pages;
  }

  Future<pdf.Widget> _buildPageImage({page = 0}) async {
    final uri = entry.uri;
    final mimeType = entry.mimeType;
    final rotationDegrees = entry.rotationDegrees;
    final isFlipped = entry.isFlipped;

    if (entry.isSvg) {
      final bytes = await ImageFileService.getImage(uri, mimeType, rotationDegrees, isFlipped);
      if (bytes != null && bytes.isNotEmpty) {
        return pdf.SvgImage(svg: utf8.decode(bytes));
      }
    } else {
      return pdf.Image(await flutterImageProvider(
        UriImage(
          uri: uri,
          mimeType: mimeType,
          page: page,
          rotationDegrees: rotationDegrees,
          isFlipped: isFlipped,
        ),
      ));
    }
    return null;
  }
}
