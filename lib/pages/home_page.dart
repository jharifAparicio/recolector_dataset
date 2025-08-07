import 'package:flutter/material.dart';
import 'capture_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedClass;

  final Map<String, String> classes = {
    // modificar la lista para coordinar con el drive
    "Vidrios": "Vidrios",
    "yogurt": "Envases de yogurt",
    "Periodicos": "Periódicos",
    "Huevos": "Cáscaras de huevo",
    "Mates": "Mates de sopa",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selecciona la clase')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedClass,
              hint: Text('Selecciona una clase'),
              isExpanded: true,
              items: classes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value.toString()),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedClass = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedClass == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CapturePage(selectedClass: selectedClass!),
                        ),
                      );
                    },
              child: Text('Empezar captura'),
            ),
          ],
        ),
      ),
    );
  }
}
