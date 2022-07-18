import 'dart:async';
import 'dart:convert';

import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';

class EntryPrinter with FeedbackMixin {
  final AvesEntry entry;

  EntryPrinter(this.entry);

  Future<void> print(BuildContext context) async {
    final documentName = entry.bestTitle ?? context.l10n.appName;
    final doc = pdf.Document(title: documentName);

    final pages = await _buildPages(context);
    if (pages.isNotEmpty) {
      pages.forEach(doc.addPage);
      unawaited(Printing.layoutPdf(
        onLayout: (format) => doc.save(),
        name: documentName,
      ));
    }
  }

  Future<List<pdf.Page>> _buildPages(BuildContext context) async {
    final pages = <pdf.Page>[];

    void _addPdfPage(pdf.Widget? pdfChild) {
      if (pdfChild == null) return;
      final displaySize = entry.displaySize;
      pages.add(pdf.Page(
        orientation: displaySize.height > displaySize.width ? pdf.PageOrientation.portrait : pdf.PageOrientation.landscape,
        build: (context) => pdf.FullPage(
          ignoreMargins: true,
          child: pdf.Center(
            child: pdfChild,
          ),
        ),
      ));
    }

    if (entry.isMultiPage && !entry.isMotionPhoto) {
      final multiPageInfo = await entry.getMultiPageInfo();
      if (multiPageInfo != null) {
        final pageCount = multiPageInfo.pageCount;
        if (pageCount > 1) {
          final streamController = StreamController<AvesEntry>.broadcast();
          unawaited(showOpReport<AvesEntry>(
            context: context,
            opStream: streamController.stream,
            itemCount: pageCount,
          ));
          for (var page = 0; page < pageCount; page++) {
            final pageEntry = multiPageInfo.getPageEntryByIndex(page);
            _addPdfPage(await _buildPageImage(pageEntry));
            streamController.add(pageEntry);
          }
          await streamController.close();
        }
      }
    }
    if (pages.isEmpty) {
      _addPdfPage(await _buildPageImage(entry));
    }
    return pages;
  }

  Future<pdf.Widget?> _buildPageImage(AvesEntry entry) async {
    if (entry.isSvg) {
      final bytes = await mediaFetchService.getSvg(entry.uri, entry.mimeType);
      if (bytes.isNotEmpty) {
        return pdf.SvgImage(svg: utf8.decode(bytes));
      }
    } else {
      return pdf.Image(await flutterImageProvider(entry.uriImage));
    }
    return null;
  }
}
