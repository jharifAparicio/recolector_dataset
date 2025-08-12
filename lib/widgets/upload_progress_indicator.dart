import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/providers/upload_provider.dart';

class UploadProgressIndicator extends ConsumerWidget {
  const UploadProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha el estado del proveedor de subida
    final uploadState = ref.watch(uploadProvider);

    // Muestra la barra de progreso solo si se está subiendo
    if (uploadState.isUploading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
      );
    }

    // Si la subida ha terminado, puedes mostrar un mensaje de éxito
    // o simplemente no mostrar nada.
    if (uploadState.uploaded == uploadState.total * 2 &&
        uploadState.total > 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          '✅ Subida de fotos completada.',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Por defecto, no muestra nada
    return const SizedBox.shrink();
  }
}
