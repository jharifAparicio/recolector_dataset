import 'package:camera/camera.dart';

Future<CameraController> initializeBackCamera({
  ResolutionPreset resolution = ResolutionPreset.medium,
}) async {
  final cameras = await availableCameras();
  final camera = cameras.firstWhere(
    (cam) => cam.lensDirection == CameraLensDirection.external,
    orElse: () => cameras.first,
  );

  final controller = CameraController(camera, resolution);
  await controller.initialize();

  return controller;
}
