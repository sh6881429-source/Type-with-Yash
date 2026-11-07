import 'package:flutter/material.dart';

import '../../../data/models/passage.dart';
import 'typing_test_screen.dart';

class TypingTestLauncher {
  static Future<void> open(BuildContext context, Passage passage) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TypingTestScreen(passage: passage),
        ),
      );
}
