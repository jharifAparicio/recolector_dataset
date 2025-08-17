import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final String title;
  final int? count; // null = cargando, -1 = error, >=0 = datos válidos
  final int total;

  const ClassCard({
    super.key,
    required this.title,
    required this.count,
    this.total = 10_000,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (count != null && count! >= 0) ? count! / total : 0.0;
    final faltantes = (count != null && count! >= 0) ? total - count! : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            if (count == null) ...[
              Text(
                "Cargando...",
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ] else if (count! < 0) ...[
              Text(
                "Error",
                style: TextStyle(fontSize: 11, color: Colors.red[700]),
              ),
            ] else ...[
              Text(
                "$count / $total",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: progress >= 1 ? Colors.green : Colors.blue,
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 4),
              Text(
                "Faltan: $faltantes",
                style: TextStyle(
                  fontSize: 11,
                  color: faltantes! > 0
                      ? Colors.orange[700]
                      : Colors.green[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
