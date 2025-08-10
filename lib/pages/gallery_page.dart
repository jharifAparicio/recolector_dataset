import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/images_provider.dart';
import '../providers/upload_provider.dart';

class GalleryPage extends ConsumerWidget {
  final String folderID;

  const GalleryPage({super.key, required this.folderID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(imagesProvider);
    final uploadState = ref.watch(uploadProvider);
    final isUploading = uploadState.isUploading;

    Future<void> confirmDeletePhoto(int index) async {
      final imageToDelete = images[index];
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Eliminar foto'),
          content: const Text('¿Deseas eliminar esta foto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          final file = File(imageToDelete.localFolder);
          if (await file.exists()) {
            await file.delete();
          }
          ref.read(imagesProvider.notifier).removeImage(imageToDelete.id);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error eliminando foto: $e')),
            );
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Galería de fotos (${images.length})')),
      body: Column(
        children: [
          Expanded(
            child: images.isEmpty
                ? const Center(child: Text('No hay fotos tomadas'))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => confirmDeletePhoto(index),
                        child: Image.file(
                          File(images[index].localFolder),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (isUploading) ...[
                  LinearProgressIndicator(
                    value: uploadState.progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(uploadState.progress * 100).toStringAsFixed(1)}% - '
                    '${uploadState.uploaded} de ${uploadState.total} fotos subidas',
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Subir todas'),
                      onPressed: isUploading || images.isEmpty
                          ? null
                          : () async {
                              await ref
                                  .read(uploadProvider.notifier)
                                  .uploadPhotos(
                                    images
                                        .map((img) => File(img.localFolder))
                                        .toList(),
                                    folderID,
                                    images.map((img) => img.id).toList(),
                                  );
                            },
                    ),
                    // un boton para mas capturas, que navege hasta a seleccion de clases
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Más capturas'),
                      onPressed: () {
                        // dos vistas atras
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
