import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../models/passage.dart';
import 'passage_pdf_service.dart';

class PassagePdfExporter {
  static Future<void> save(Passage passage, BuildContext context) async {
    final bytes = await PassagePdfService.build(passage);
    final location = await getSaveLocation(
      suggestedName: '${passage.id}.pdf',
      acceptedTypeGroups: [
        const XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
    );
    if (location == null) return;
    if (await File(location.path).exists()) {
      if (!context.mounted) return;
      final overwrite = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Replace existing PDF?'),
          content: Text('${location.path} already exists.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );
      if (overwrite != true) return;
    }
    await XFile.fromData(
      bytes,
      mimeType: 'application/pdf',
      name: '${passage.id}.pdf',
    ).saveTo(location.path);
  }
}
