import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:upschool_projem_app/features/documents/presentation/state/document_state.dart';

class DocumentDetailScreen extends StatefulWidget {
  const DocumentDetailScreen({super.key, required this.doc});

  final DocumentListItem doc;

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  String? _extractedText;
  String? _error;
  bool _extracting = false;

  @override
  void initState() {
    super.initState();
    _startExtract();
  }

  Future<void> _startExtract() async {
    setState(() {
      _extracting = true;
      _error = null;
    });
    try {
      final text = await _extractTextFromPdf(widget.doc.pdfBytes);
      if (!mounted) return;
      setState(() => _extractedText = text);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) {
        setState(() => _extracting = false);
      }
    }
  }

  Future<String> _extractTextFromPdf(Uint8List bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    try {
      final extracted = PdfTextExtractor(document).extractText();
      return extracted.trim();
    } finally {
      document.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.doc.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Metni tekrar çıkar',
            onPressed: _extracting ? null : _startExtract,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: SfPdfViewer.memory(widget.doc.pdfBytes),
            ),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Çıkarılan Metin (MVP v0)',
                            style: theme.textTheme.titleMedium,
                          ),
                          const Spacer(),
                          if (_extracting)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_error != null)
                        Text(
                          'Hata: $_error',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        )
                      else if ((_extractedText ?? '').isEmpty && !_extracting)
                        const Text(
                          'Bu PDF’te metin katmanı olmayabilir (scan PDF). OCR fallback Sprint 0\'da iOS/Android tarafında Xcode/SDK hazır olunca eklenecek.',
                        )
                      else
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _extractedText ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

