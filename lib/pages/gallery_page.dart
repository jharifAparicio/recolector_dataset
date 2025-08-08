import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/utils/delete_photos.dart';
import '../utils/upload_all.dart';

class GalleryPage extends ConsumerStatefulWidget {
  final List<String> photoPaths;
  final String folderID;

  const GalleryPage({
    super.key,
    required this.photoPaths,
    required this.folderID,
  });

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  bool uploading = false;
  double uploadProgress = 0.0;
  int totalPhotos = 0;
  int uploadedPhotos = 0;

  Future<void> startUpload() async {
    setState(() {
      uploading = true;
      totalPhotos = widget.photoPaths.length;
      uploadedPhotos = 0;
      uploadProgress = 0.0;
    });

    await uploadAllPhotos(
      ref,
      widget.photoPaths.map((path) => File(path)).toList(),
      widget.folderID,
      (progress) {
        // progress viene como 0.0 -> 1.0
        setState(() {
          uploadProgress = progress;
          uploadedPhotos = (progress * totalPhotos).round();
        });
      },
    );

    if (!mounted) return;
    setState(() {
      uploading = false;
      widget.photoPaths.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Fotos subidas exitosamente')));

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galería de fotos (${widget.photoPaths.length})'),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.photoPaths.isEmpty
                ? const Center(child: Text('No hay fotos tomadas'))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: widget.photoPaths.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(widget.photoPaths[index]),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (uploading) ...[
                  LinearProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(uploadProgress * 100).toStringAsFixed(1)}% - '
                    '$uploadedPhotos de $totalPhotos fotos subidas',
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Subir todas'),
                      onPressed: uploading ? null : startUpload,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar todas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: uploading
                          ? null
                          : () async {
                              final folderPath = widget.photoPaths.first
                                  .substring(
                                    0,
                                    widget.photoPaths.first.lastIndexOf('/'),
                                  );

                              await eliminarFotosLocales(folderPath);

                              if (!mounted) return;
                              setState(() {
                                widget.photoPaths.clear();
                              });

                              Navigator.pop(context);
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
