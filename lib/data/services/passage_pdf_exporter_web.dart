import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/passage.dart';
import 'passage_pdf_service.dart';

class PassagePdfExporter {
  static Future<void> save(Passage passage, BuildContext context) async {
    await Printing.sharePdf(
      bytes: await PassagePdfService.build(passage),
      filename: '${passage.id}.pdf',
    );
  }
}
