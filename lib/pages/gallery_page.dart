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

double uploadProgress = 0.0; // 0.0 a 1.0
bool uploading = false;

class _GalleryPageState extends ConsumerState<GalleryPage> {
  bool uploading = false;
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
                ? Center(child: Text('No hay fotos tomadas'))
                : GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.upload_file),
                  label: Text('Subir todas'),
                  onPressed: uploading
                      ? null
                      : () async {
                          setState(() {
                            uploading = true;
                            uploadProgress = 0.0; // inicializar barra
                          });
                          try {
                            await uploadAllPhotos(
                              ref,
                              widget.photoPaths
                                  .map((path) => File(path))
                                  .toList(),
                              widget.folderID,
                              (progress) {
                                // actualización en tiempo real
                                setState(() {
                                  uploadProgress = progress;
                                });
                              },
                            );

                            if (!mounted) return;
                            setState(() {
                              widget.photoPaths.clear();
                            });
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Fotos subidas exitosamente'),
                              ),
                            );

                            await Future.delayed(Duration(seconds: 1));
                            Navigator.of(
                              // ignore: use_build_context_synchronously
                              context,
                            ).popUntil((route) => route.isFirst);
                          } catch (e) {
                            if (!mounted) return;
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al subir fotos: $e'),
                              ),
                            );
                          } finally {
                            // ignore: control_flow_in_finally
                            if (!mounted) return;
                            setState(() {
                              uploading = false;
                            });
                          }
                        },
                ),

                if (uploading) ...[
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  Text('${(uploadProgress * 100).toStringAsFixed(1)}% subido'),
                ],

                ElevatedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text('Eliminar todas'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: uploading
                      ? null
                      : () async {
                          final folderPath = widget.photoPaths.first.substring(
                            0,
                            widget.photoPaths.first.lastIndexOf('/'),
                          );

                          await eliminarFotosLocales(folderPath);
                          // recargar vista
                          if (!mounted) return;
                          setState(() {
                            widget.photoPaths.clear();
                          });
                          // Eliminar todas las fotos locales después de subir
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
