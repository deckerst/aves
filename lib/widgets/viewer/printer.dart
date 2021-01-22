import 'dart:convert';

import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/services/image_file_service.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:pedantic/pedantic.dart';
import 'package:printing/printing.dart';

class EntryPrinter {
  final AvesEntry entry;

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
        for (final page in multiPageInfo.pages) {
          final pageEntry = entry.getPageEntry(page);
          _addPdfPage(await _buildPageImage(pageEntry));
        }
      }
    }
    if (pages.isEmpty) {
      _addPdfPage(await _buildPageImage(entry));
    }
    return pages;
  }

  Future<pdf.Widget> _buildPageImage(AvesEntry entry) async {
    if (entry.isSvg) {
      final bytes = await ImageFileService.getSvg(entry.uri, entry.mimeType);
      if (bytes != null && bytes.isNotEmpty) {
        return pdf.SvgImage(svg: utf8.decode(bytes));
      }
    } else {
      return pdf.Image(await flutterImageProvider(entry.uriImage));
    }
    return null;
  }
}
