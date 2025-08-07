import 'dart:io';

Future<void> eliminarFotosLocales(String folderPath) async {
  final directory = Directory(folderPath);

  if (await directory.exists()) {
    // Listado asincrónico
    await for (var archivo in directory.list()) {
      if (archivo is File) {
        try {
          await archivo.delete();
          print('Archivo eliminado: ${archivo.path}');
        } catch (e) {
          print("Error al eliminar el archivo ${archivo.path}: $e");
        }
      }
    }
  } else {
    print('Directorio no existe: $folderPath');
  }
}

Future<void> eliminarCarpeta(String folderPath) async {
  final directory = Directory(folderPath);
  if (await directory.exists()) {
    try {
      await directory.delete(recursive: true);
      print('Carpeta eliminada: $folderPath');
    } catch (e) {
      print('Error eliminando carpeta: $e');
    }
  } else {
    print('Carpeta no existe: $folderPath');
  }
}
