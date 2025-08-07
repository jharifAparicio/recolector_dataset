import 'dart:io';

Future<void> eliminarFotosLocales(String folderPath) async {
  final directory = Directory(folderPath);

  if (await directory.exists()) {
    final archivos = directory.listSync();

    for (var archivo in archivos) {
      if (archivo is File) {
        try {
          await archivo.delete();
        } catch (e) {
          print("Error al eliminar el archivo ${archivo.path}: $e");
        }
      }
    }
  }
}
