import 'package:flutter/material.dart';
import 'package:recolector_dataset/main.dart';
import 'capture_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? selectedClass;
  String? folderID;

  final Map<String, String> classes = {
    // modificar la lista para coordinar con el drive
    // "folderID": "Nombre visible"
    "1jLEwjPBAUn6gC6eWHjh1nOh_Vjem_WGi": "Vidrios",
    "1hdb14vXuEo0hZnvvqn6A66TvubEdyQUb": "Envases de yogurt",
    "1EIAE-00Bn0BuPDPWsFNfmSt_AYovmZh5": "Periódicos",
    "1iW9W6MJ3xwbVOXPIZ_mv1JxbkF9GvvZx": "Cáscaras de huevo",
    "1rVZx2a_hdF624dEs7LW5oBTrtel8aJ1e": "Mates de sopa",
  };

  @override
  Widget build(BuildContext context) {
    final driveService = ref.read(driveServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Selecciona la clase')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: folderID, // ahora usamos el ID como valor de Dropdown
              hint: Text('Selecciona una clase'),
              isExpanded: true,
              items: classes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key, // el ID
                  child: Text(entry.value), // el nombre visible
                );
              }).toList(),
              onChanged: (value) => setState(() {
                folderID = value;
                selectedClass = classes[value];
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
                            folderID: folderID!,
                            className: selectedClass!,
                          ),
                        ),
                      );
                    },
              child: Text('Empezar captura'),
            ),
            // mostramos la lista de cantidad de fotos por clase
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classId = classes.keys.elementAt(index);
                  return FutureBuilder<int>(
                    future: driveService.PhotosCount(classId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text(classes[classId]!),
                          subtitle: Text('Cargando...'),
                        );
                      } else if (snapshot.hasError) {
                        return ListTile(
                          title: Text(classes[classId]!),
                          subtitle: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        return ListTile(
                          title: Text(classes[classId]!),
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
