import 'package:flutter/material.dart';
import 'package:recolector_dataset/main.dart';
import 'package:recolector_dataset/pages/gallery_page.dart';
import 'package:recolector_dataset/pages/settings_page.dart';
import 'capture_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/class_mapping.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? selectedClass;
  String? cloudFolderID;

  Map<String, String>? classes; // para almacenar las clases cargadas

  @override
  void initState() {
    super.initState();
    cargarClases(); // cargar las clases al iniciar
  }

  Future<void> cargarClases() async {
    classes = await loadClassMapping();
    setState(() {}); // para refrescar UI cuando carga
  }

  @override
  Widget build(BuildContext context) {
    if (classes == null) {
      return CircularProgressIndicator(); // o alguna pantalla de carga
    }

    final driveService = ref.read(driveServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona la clase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // engranaje
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: cloudFolderID, // ahora usamos el ID como valor de Dropdown
              hint: Text('Selecciona una clase'),
              isExpanded: true,
              items: classes!.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key, // el ID
                  child: Text(entry.value), // el nombre visible
                );
              }).toList(),
              // actualizamos el estado al cambiar la selección
              onChanged: (value) => setState(() {
                cloudFolderID = value;
                selectedClass = classes![value];
              }),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedClass == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CapturePage(
                            cloudFolderID: cloudFolderID!,
                            className: selectedClass!,
                          ),
                        ),
                      );
                    },
              child: Text('Empezar captura'),
            ),
            // boton para ir a la galería de fotos si existen fotos
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => {
                (
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GalleryPage()),
                  ),
                ),
              },
              // botón desactivado cuando no hay imágenes
              child: Text('Abrir galería'),
            ),

            // mostramos la lista de cantidad de fotos por clase
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: classes!.length,
                itemBuilder: (context, index) {
                  final classId = classes!.keys.elementAt(index);
                  final className = classes![classId]!;

                  return FutureBuilder<int>(
                    future: driveService.photosCount(
                      classId,
                    ), // llamamos a la funcion de contar fotos
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text(className),
                          subtitle: Text('Cargando...'),
                        );
                      } else if (snapshot.hasError) {
                        return ListTile(
                          title: Text(className),
                          subtitle: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        return ListTile(
                          title: Text(className),
                          subtitle: Text(
                            'Fotos: ${snapshot.data ?? 0} / 10000 \n Faltantes: ${10000 - (snapshot.data ?? 0)}',
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
