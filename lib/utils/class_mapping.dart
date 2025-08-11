import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, String>> loadClassMapping() async {
  final String response = await rootBundle.loadString('assets/clases.json');
  final Map<String, dynamic> data = json.decode(response);
  return data.map((key, value) => MapEntry(key, value.toString()));
}
