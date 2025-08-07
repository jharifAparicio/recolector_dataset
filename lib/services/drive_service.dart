import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
// import 'package:http/http.dart' as http;

// existen 3 funciones principales
// 1. init() -> inicializa el servicio de Google Drive
// 2. uploadFile(File file, String folderId) -> sube un archivo a una carpeta especifica
// 3. getFolderIdByName(String folderName) -> obtiene el ID de una carpeta por su nombre
class DriveService {
  static final DriveService _instance = DriveService._internal();

  factory DriveService() => _instance;

  DriveService._internal();

  late drive.DriveApi driveApi;

  Future<void> init() async {
    final jsonCredentials = await rootBundle.loadString(
      'assets/credentials.json',
    );
    final credentialsMap = json.decode(jsonCredentials);

    final accountCredentials = ServiceAccountCredentials.fromJson(
      credentialsMap,
    );

    final scopes = [drive.DriveApi.driveFileScope];

    final authClient = await clientViaServiceAccount(
      accountCredentials,
      scopes,
    );

    driveApi = drive.DriveApi(authClient);
  }

  Future<drive.File> uploadFile(File file, String folderId) async {
    final fileName = file.path.split('/').last;

    final media = drive.Media(file.openRead(), await file.length());

    final driveFile = drive.File();
    driveFile.name = fileName;
    driveFile.parents = [folderId]; // Carpeta destino en Drive

    return await driveApi.files.create(driveFile, uploadMedia: media);
  }

  Future<String?> getFolderIdByName(String folderName) async {
    final result = await driveApi.files.list(
      q: "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName'",
      spaces: 'drive',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id;
    }
    return null;
  }

  Future<String> createFolder(String folderName) async {
    final folder = drive.File();
    folder.name = folderName;
    folder.mimeType = 'application/vnd.google-apps.folder';

    final createdFolder = await driveApi.files.create(folder);
    return createdFolder.id!;
  }
}
