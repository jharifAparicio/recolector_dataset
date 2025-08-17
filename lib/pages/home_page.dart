import 'package:flutter/material.dart';
import 'package:recolector_dataset/main.dart';
import 'package:recolector_dataset/pages/gallery_page.dart';
import 'package:recolector_dataset/pages/settings_page.dart';
import 'capture_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/class_mapping.dart';
import '../widgets/class_card.dart';

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

            // lista de clases con sus fotos
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columnas
                  crossAxisSpacing: 3, // espacio entre columnas
                  mainAxisSpacing: 3, // espacio entre tarjetas
                  childAspectRatio:
                      1.8, // relación de aspecto para que se vea bien
                ),
                itemCount: classes!.length,
                itemBuilder: (context, index) {
                  final classId = classes!.keys.elementAt(index);
                  final className = classes![classId]!;

                  return FutureBuilder<int>(
                    future: driveService.photosCount(classId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ClassCard(title: className, count: null);
                      } else if (snapshot.hasError) {
                        return ClassCard(title: className, count: -1);
                      } else {
                        return ClassCard(
                          title: className,
                          count: snapshot.data ?? 0,
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
