import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentListItem {
  DocumentListItem({
    required this.id,
    required this.fileName,
    required this.pdfBytes,
    required this.createdAt,
  });

  final String id;
  final String fileName;
  final Uint8List pdfBytes;
  final DateTime createdAt;
}

class DocumentListNotifier extends Notifier<List<DocumentListItem>> {
  @override
  List<DocumentListItem> build() => const [];

  void add(DocumentListItem item) {
    state = [item, ...state];
  }
}

final documentListProvider =
    NotifierProvider<DocumentListNotifier, List<DocumentListItem>>(
  DocumentListNotifier.new,
);

