import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/passage.dart';

class PassagePdfService {
  static Future<Uint8List> build(Passage passage) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(48, 46, 48, 52),
        header: (_) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Text(
            'Type with Yash',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        build: (_) => [
          pw.Text(
            passage.title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            'Passage ID: ${passage.id}   -   ${passage.category}   -   ${passage.difficulty}   -   ${passage.wordCount} words',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Candidate: ______________________________     Date: __________________',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),
          for (final paragraph in passage.content.split(RegExp(r'\n\s*\n')))
            if (paragraph.trim().isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Text(
                  paragraph.trim(),
                  textAlign: pw.TextAlign.justify,
                  style: const pw.TextStyle(fontSize: 11, lineSpacing: 4),
                ),
              ),
        ],
      ),
    );
    return document.save();
  }

  static Future<void> previewAndPrint(Passage passage) async =>
      Printing.layoutPdf(onLayout: (_) => build(passage));
}
