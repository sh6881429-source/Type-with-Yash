import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/neo_colors.dart';
import '../../../data/models/passage.dart';
import '../../../data/repositories/passage_repository.dart';
import '../../../data/services/passage_pdf_service.dart';
import '../../../data/services/passage_pdf_exporter.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/neo_button.dart';
import '../typing/typing_test_launcher.dart';

class PassageLibraryScreen extends StatefulWidget {
  const PassageLibraryScreen({
    super.key,
    this.isPrintMode = false,
  });

  final bool isPrintMode;

  @override
  State<PassageLibraryScreen> createState() => _PassageLibraryScreenState();
}

class _PassageLibraryScreenState extends State<PassageLibraryScreen> {
  final _repository = PassageRepository();
  final _search = TextEditingController();
  List<Passage> _passages = [];
  Passage? _selected;
  String _difficulty = 'All', _category = 'All';
  bool _loading = true;
  String? _error;
  Passage? _lastSelected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final rows = await _repository.getAllPassages();
      if (!mounted) return;
      setState(() {
        _passages = rows;
        _selected ??= rows.isEmpty ? null : rows.first;
        _lastSelected ??= _selected;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _savePdf() async {
    final passage = _selected;
    if (passage == null) return;
    try {
      await PassagePdfExporter.save(passage, context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF save failed: $e')),
        );
      }
    }
  }

  Future<void> _printPassage() async {
    final passage = _selected;
    if (passage == null) return;
    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            width: 900,
            height: 760,
            child: PdfPreview(
              canChangePageFormat: false,
              canChangeOrientation: false,
              allowSharing: false,
              build: (_) => PassagePdfService.build(passage),
              pdfFileName: '${passage.id}.pdf',
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print preview failed. Try Save as PDF. $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _passages.map((p) => p.category).toSet().toList()
      ..sort();
    final query = _search.text.trim().toLowerCase();
    final visible = _passages
        .where(
          (p) =>
              (query.isEmpty ||
                  p.title.toLowerCase().contains(query) ||
                  p.category.toLowerCase().contains(query) ||
                  p.content.toLowerCase().contains(query)) &&
              (_difficulty == 'All' || p.difficulty == _difficulty) &&
              (_category == 'All' || p.category == _category),
        )
        .toList();

    return Scaffold(
      backgroundColor: NeoColors.background,
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isPrintMode ? 'Print & Save Passages' : 'Start Typing Test — Select Passage',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              widget.isPrintMode
                  ? 'Browse all offline passages. Preview, print paper copies, or save as PDF for offline exam practice.'
                  : 'Choose a passage from your offline library and begin your typing test with live speed and accuracy tracking.',
              style: const TextStyle(color: NeoColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text('Unable to load passages: $_error'))
                  : Row(
                      children: [
                        SizedBox(
                          width: 390,
                          child: NeoBox(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _search,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    hintText: 'Search title, category, or text',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  children: ['All', 'Easy', 'Medium', 'Hard']
                                      .map(
                                        (v) => ChoiceChip(
                                          label: Text(v),
                                          selected: _difficulty == v,
                                          onSelected: (_) =>
                                              setState(() => _difficulty = v),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 6),
                                DropdownButton<String>(
                                  isExpanded: true,
                                  value: _category,
                                  items: ['All', ...categories]
                                      .map(
                                        (v) => DropdownMenuItem(
                                          value: v,
                                          child: Text(
                                            v,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _category = v ?? 'All'),
                                ),
                                Row(
                                  children: [
                                    Text('${visible.length} passages', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () async {
                                        final p = await _repository.getRandomPassage();
                                        if (mounted && p != null) {
                                          setState(() {
                                            _selected = p;
                                            _lastSelected = p;
                                          });
                                        }
                                      },
                                      child: const Text('Random'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: NeoColors.textPrimary,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => setState(() {
                                        _search.clear();
                                        _difficulty = 'All';
                                        _category = 'All';
                                      }),
                                      child: const Text('Clear'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: NeoColors.textPrimary,
                                      ),
                                    ),
                                    if (_lastSelected != null)
                                      TextButton(
                                        onPressed: () => setState(
                                          () => _selected = _lastSelected,
                                        ),
                                        child: const Text('Repeat last'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: NeoColors.textPrimary,
                                        ),
                                      ),
                                  ],
                                ),
                                const Divider(),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: visible.length,
                                    itemBuilder: (_, i) {
                                      final p = visible[i];
                                      final isSelected = p.id == _selected?.id;
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? NeoColors.mint
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? NeoColors.border
                                                : Colors.transparent,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ListTile(
                                          selected: isSelected,
                                          selectedColor: NeoColors.textPrimary,
                                          title: Text(
                                            p.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: NeoColors.textPrimary,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${p.difficulty} • ${p.wordCount} words',
                                            style: const TextStyle(
                                              color: NeoColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          onTap: () => setState(() {
                                            _selected = p;
                                            _lastSelected = p;
                                          }),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _selected == null
                              ? const Center(
                                  child: Text('No passages available.'),
                                )
                              : NeoBox(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selected!.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 22,
                                          color: NeoColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Category: ${_selected!.category} • ${_selected!.difficulty} • ${_selected!.wordCount} words • ${_selected!.characterCount} characters',
                                        style: const TextStyle(color: NeoColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      const Divider(height: 20),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: NeoColors.surfaceSubtle,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: NeoColors.border, width: 1.5),
                                          ),
                                          child: SingleChildScrollView(
                                            child: SelectableText(
                                              _selected!.content,
                                              style: const TextStyle(fontSize: 15, height: 1.55),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Tip: Print this passage so you can place it beside your keyboard and type without seeing reference text on screen.',
                                        style: TextStyle(color: NeoColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 14),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 10,
                                        children: widget.isPrintMode
                                            ? [
                                                NeoButton(
                                                  onPressed: _printPassage,
                                                  icon: const Icon(Icons.print_rounded),
                                                  label: 'Print Passage',
                                                  backgroundColor: NeoColors.yellow,
                                                ),
                                                NeoButton(
                                                  onPressed: _savePdf,
                                                  icon: const Icon(Icons.picture_as_pdf_rounded),
                                                  label: 'Save as PDF',
                                                  backgroundColor: NeoColors.lavender,
                                                ),
                                                NeoButton(
                                                  onPressed: () => TypingTestLauncher.open(
                                                    context,
                                                    _selected!,
                                                  ),
                                                  icon: const Icon(Icons.play_arrow_rounded),
                                                  label: 'Start Test with Passage',
                                                  backgroundColor: NeoColors.mint,
                                                ),
                                              ]
                                            : [
                                                NeoButton(
                                                  onPressed: () => TypingTestLauncher.open(
                                                    context,
                                                    _selected!,
                                                  ),
                                                  icon: const Icon(Icons.play_arrow_rounded),
                                                  label: 'Start Test',
                                                  backgroundColor: NeoColors.yellow,
                                                ),
                                                NeoButton(
                                                  onPressed: _printPassage,
                                                  icon: const Icon(Icons.print_rounded),
                                                  label: 'Print Passage',
                                                  backgroundColor: NeoColors.surfaceSubtle,
                                                ),
                                                NeoButton(
                                                  onPressed: _savePdf,
                                                  icon: const Icon(Icons.picture_as_pdf_rounded),
                                                  label: 'Save as PDF',
                                                  backgroundColor: NeoColors.lavender,
                                                ),
                                              ],
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
