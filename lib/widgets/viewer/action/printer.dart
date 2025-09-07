import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';

class EntryPrinter with FeedbackMixin {
  final AvesEntry entry;

  static const _fit = pdf.BoxFit.contain;

  EntryPrinter(this.entry);

  Future<void> print(BuildContext context) async {
    final documentName = entry.bestTitle ?? context.l10n.appName;

    final imageWidgets = await _buildImageWidgets(context);
    if (imageWidgets.isNotEmpty) {
      unawaited(Printing.layoutPdf(
        onLayout: (pageFormat) {
          final doc = pdf.Document(title: documentName);
          imageWidgets.map((v) => _buildPdfPage(v, pageFormat)).forEach(doc.addPage);
          return doc.save();
        },
        name: documentName,
      ));
    }
  }

  pdf.Page _buildPdfPage(pdf.Widget imageWidget, PdfPageFormat pageFormat) {
    final displaySize = entry.displaySize;
    final pageTheme = pdf.PageTheme(
      pageFormat: pageFormat,
      orientation: displaySize.aspectRatio < 1 ? pdf.PageOrientation.portrait : pdf.PageOrientation.landscape,
      margin: pdf.EdgeInsets.zero,
      theme: null,
      clip: false,
      textDirection: null,
    );
    return pdf.Page(
      pageTheme: pageTheme,
      build: (context) => pdf.FullPage(
        ignoreMargins: true,
        child: pdf.Center(
          child: pdf.Transform.scale(
            scale: min(pageFormat.availableWidth / displaySize.width, pageFormat.availableHeight / displaySize.height),
            child: pdf.Transform.rotateBox(
              angle: 0,
              unconstrained: true,
              child: imageWidget,
            ),
          ),
        ),
      ),
    );
  }

  Future<List<pdf.Widget>> _buildImageWidgets(BuildContext context) async {
    final widgets = <pdf.Widget>[];

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
            final widget = await _buildPageImage(context, pageEntry);
            if (widget != null) {
              widgets.add(widget);
            }
            streamController.add(pageEntry);
          }
          await streamController.close();
        }
      }
    }

    if (widgets.isEmpty) {
      final widget = await _buildPageImage(context, entry);
      if (widget != null) {
        widgets.add(widget);
      }
    }

    return widgets;
  }

  Future<pdf.Widget?> _buildPageImage(BuildContext context, AvesEntry entry) async {
    try {
      if (entry.isSvg) {
        final data = await mediaFetchService.getOriginalBytes(entry);
        if (data.isNotEmpty) {
          return pdf.SvgImage(
            svg: utf8.decode(data),
            fit: _fit,
          );
        }
      } else {
        return pdf.Image(
          await flutterImageProvider(entry.fullImage),
          fit: _fit,
        );
      }
    } catch (error) {
      debugPrint('failed to load image for entry=$entry, error=$error');
    }
    showFeedback(context, FeedbackType.warn, context.l10n.genericFailureFeedback);
    return null;
  }
}
