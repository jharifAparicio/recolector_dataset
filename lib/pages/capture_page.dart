import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/init_camera.dart';
import '../utils/get_save_path.dart';
import 'gallery_page.dart';

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

const int maxPhotos = 50; // máximo de fotos a capturar
const int intervalePhotos = 350; // milisegundos entre fotos
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
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      if (isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      print('Error al cambiar flash: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
