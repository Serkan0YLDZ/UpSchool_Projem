import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:upschool_projem_app/features/documents/presentation/state/document_state.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({super.key});

  Future<void> _pickPdfAndOpen(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF okunamadı (bytes yok).')),
        );
      }
      return;
    }

    final item = DocumentListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: file.name,
      pdfBytes: bytes,
      createdAt: DateTime.now(),
    );

    ref.read(documentListProvider.notifier).add(item);
    if (context.mounted) context.push('/detail', extra: item);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(documentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Belgeler'),
        actions: [
          IconButton(
            tooltip: 'PDF ekle',
            onPressed: () => _pickPdfAndOpen(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? _EmptyState(onAdd: () => _pickPdfAndOpen(context, ref))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: Text(
                        item.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${item.createdAt}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/detail', extra: item),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickPdfAndOpen(context, ref),
        icon: const Icon(Icons.upload_file),
        label: const Text('PDF Yükle'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Henüz belge yok',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sprint 0 demo: PDF seç → PDF görüntüle → metin çıkarımı.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.upload_file),
                label: const Text('PDF Yükle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

