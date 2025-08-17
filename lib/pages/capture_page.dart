import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/providers/upload_provider.dart';
import 'package:recolector_dataset/widgets/upload_progress_indicator.dart';
import '../utils/init_camera.dart';
import '../utils/get_save_path.dart';
import 'gallery_page.dart';
import '../providers/settings_provider.dart';

class CapturePage extends ConsumerStatefulWidget {
  final String cloudFolderID;
  final String className;

  const CapturePage({
    super.key,
    required this.cloudFolderID,
    required this.className,
  });

  @override
  CapturePageState createState() => CapturePageState();
}

String datasetFolder = 'dataset';

class CapturePageState extends ConsumerState<CapturePage> {
  CameraController? _controller;

  bool isCapturing = false;
  int photosTaken = 0;
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    initializeBackCamera()
        .then((controller) {
          _controller = controller;
          setState(() {});
        })
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al inicializar la cámara: $e')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final uploadState = ref.watch(uploadProvider);
    final message = uploadState.message; // 🟢 Accedes al campo

    int maxPhotos = settings.cantidadPhotos;
    return Scaffold(
      appBar: AppBar(title: Text('Capturando: ${widget.className}')),
      body: Column(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            AspectRatio(aspectRatio: 3 / 4, child: CameraPreview(_controller!))
          else
            const Center(child: CircularProgressIndicator()),

          const SizedBox(height: 20),
          Text('Fotos tomadas: $photosTaken / $maxPhotos'),
          const SizedBox(height: 20),
          UploadProgressIndicator(),
          ElevatedButton(
            onPressed:
                isCapturing ||
                    _controller == null ||
                    !_controller!.value.isInitialized
                ? null
                : () async {
                    setState(() {
                      isCapturing = true;
                      photosTaken = 0;
                    });

                    await takeBurstPhotos(
                      controller: _controller!,
                      ref: ref,
                      folderID: widget.cloudFolderID,
                      maxPhotos: maxPhotos,
                      datasetFolder: datasetFolder,
                      onProgress: (count) {
                        setState(() {
                          photosTaken = count;
                        });
                      },
                    );

                    setState(() {
                      isCapturing = false;
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GalleryPage()),
                    );
                  },
            child: Text(
              isCapturing ? 'Capturando...' : 'Iniciar ráfaga de fotos',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Volver'),
          ),
          // Mensaje de error no invasivo
          if (message != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Material(
                // ignore: deprecated_member_use
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
