import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

/// Servicio de Google Drive con renovación automática de sesión
class DriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveScope],
  );

  GoogleSignInAccount? _currentUser;

  /// Inicializa sesión en Google Drive
  Future<void> init() async {
    _currentUser = await _googleSignIn.signInSilently();
    _currentUser ??= await _googleSignIn.signIn();

    if (_currentUser == null) {
      throw Exception(
        'No se pudo iniciar sesión con Google. '
        'Verifique su conexión a internet y las credenciales.',
      );
    }
  }

  /// Obtiene una instancia de la API de Drive con credenciales actualizadas
  Future<drive.DriveApi> _getDriveApi() async {
    if (_currentUser == null) {
      await init();
    }

    final authHeaders = await _currentUser!.authHeaders;
    final client = GoogleAuthClient(authHeaders);
    return drive.DriveApi(client);
  }

  /// Sube un archivo a Google Drive
  Future<String?> uploadFile(File file, String folderId) async {
    final api = await _getDriveApi(); // ✅ token fresco en cada request

    final media = drive.Media(file.openRead(), await file.length());
    final driveFile = drive.File()
      ..name = file.path.split('/').last
      ..parents = [folderId];

    final response = await api.files.create(driveFile, uploadMedia: media);
    return response.id;
  }

  /// Cuenta fotos dentro de una carpeta en Drive
  Future<int> photosCount(String carpetaID) async {
    final api = await _getDriveApi(); // ✅ token fresco aquí también

    final query =
        "'$carpetaID' in parents and (mimeType='image/jpeg' or mimeType='image/png') and trashed = false";

    int total = 0;
    String? pageToken;

    do {
      final fileList = await api.files.list(
        q: query,
        spaces: 'drive',
        $fields: 'nextPageToken, files(id)',
        pageSize: 1000,
        pageToken: pageToken,
      );
      total += fileList.files?.length ?? 0;
      pageToken = fileList.nextPageToken;
    } while (pageToken != null);

    return total;
  }

  /// Cierra sesión manualmente si es necesario
  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    _currentUser = null;
  }
}

/// Cliente HTTP personalizado que añade los headers de autenticación
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
