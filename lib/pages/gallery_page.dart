import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/utils/delete_photos.dart';
import '../utils/upload_all.dart';

class GalleryPage extends ConsumerStatefulWidget {
  final List<String> photoPaths;
  final String clase;

  const GalleryPage({super.key, required this.photoPaths, required this.clase});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

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
                          });
                          try {
                            await uploadAllPhotos(
                              ref,
                              widget.photoPaths
                                  .map((path) => File(path))
                                  .toList(),
                              'reciduos_solidos_aparicio_jharif/${widget.clase}',
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Fotos subidas exitosamente'),
                              ),
                            );
                            await Future.delayed(Duration(seconds: 1));
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al subir fotos: $e'),
                              ),
                            );
                          } finally {
                            if (!mounted) return;
                            setState(() {
                              uploading = false;
                            });
                          }
                        },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text('Eliminar todas'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: uploading
                      ? null
                      : () {
                          eliminarFotosLocales(
                            widget.photoPaths.first.substring(
                              0,
                              widget.photoPaths.first.lastIndexOf('/'),
                            ),
                          );
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
