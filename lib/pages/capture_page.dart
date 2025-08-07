import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recolector_dataset/utils/delete_photos.dart';
import 'package:uuid/uuid.dart';
import 'gallery_page.dart';

class CapturePage extends StatefulWidget {
  final String selectedClass;

  const CapturePage({super.key, required this.selectedClass});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

const maxPhotos = 5;
const intervalePhotos = 250;
List<String> photoPaths = [];
String datasetFolder = 'dataset';

class _CapturePageState extends State<CapturePage> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  bool isCapturing = false;
  int photosTaken = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();
    await _initializeControllerFuture;
    setState(() {});
  }

  Future<String> _getSavePath() async {
    // final dir = await getApplicationDocumentsDirectory();
    final dir = await getExternalStorageDirectory(); //
    final folderPath = '${dir!.path}/dataset/${widget.selectedClass}';
    final folder = Directory(folderPath);

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    return folderPath;
  }

  Future<void> _takeBurstPhotos() async {
    if (isCapturing) return;

    setState(() {
      isCapturing = true;
      photosTaken = 0;
    });

    final folderPath = await _getSavePath();
    final uuid = Uuid();

    for (int i = 0; i < maxPhotos; i++) {
      try {
        final fileName = '${uuid.v4()}.jpg';
        final filePath = '$folderPath/$fileName';

        await _controller!.takePicture().then((XFile file) async {
          // Mover a carpeta destino con UUID nombre
          await File(file.path).copy(filePath);
        });

        setState(() {
          photosTaken = i + 1;
        });

        photoPaths.add(filePath);

        await Future.delayed(Duration(milliseconds: intervalePhotos));
      } catch (e) {
        print('Error capturando foto $i: $e');
      }
    }
    // cargar la dirección de las fotos tomadas
    datasetFolder = _getSavePath().toString();
    setState(() {
      isCapturing = false;
    });

    // navegar hacia la galería de las fotos tomadas
    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (_) =>
            GalleryPage(photoPaths: photoPaths, clase: widget.selectedClass),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capturando: ${widget.selectedClass}')),
      body: Column(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            AspectRatio(
              // aspectRatio: _controller!.value.aspectRatio,
              aspectRatio: 3 / 4, // Ajustar según sea necesario
              child: CameraPreview(_controller!),
            )
          else
            const Center(child: CircularProgressIndicator()),
          SizedBox(height: 20),
          Text('Fotos tomadas: $photosTaken / $maxPhotos'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                isCapturing ||
                    _controller == null ||
                    !_controller!.value.isInitialized
                ? null
                : _takeBurstPhotos,
            child: Text(
              isCapturing ? 'Capturando...' : 'Iniciar ráfaga de fotos',
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              eliminarFotosLocales(
                '${(await getExternalStorageDirectory())!.path}/dataset/${widget.selectedClass}',
              );
            },
            child: Text('Volver'),
          ),
        ],
      ),
    );
  }
}
