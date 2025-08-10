import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;

class DriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  Future<void> init() async {
    _currentUser = await _googleSignIn.signInSilently();

    _currentUser ??= await _googleSignIn.signIn();

    if (_currentUser == null) {
      throw Exception(
        'No se pudo iniciar sesión con Google. '
        'Verifique su conexión a internet y las credenciales.',
      );
    }

    final authHeaders = await _currentUser!.authHeaders;
    final client = GoogleAuthClient(authHeaders);

    _driveApi = drive.DriveApi(client);
  }

  Future<String?> uploadFile(File file, String folderId) async {
    if (_driveApi == null) throw Exception('Google Drive no inicializado');

    final media = drive.Media(file.openRead(), await file.length());
    final driveFile = drive.File()
      ..name = file.path.split('/').last
      ..parents = [folderId];

    final response = await _driveApi!.files.create(
      driveFile,
      uploadMedia: media,
    );
    return response.id;
  }

  Future<int> photosCount(String carpetaID) async {
    if (_driveApi == null) throw Exception('Google Drive no inicializado');

    // Consulta para contar las fotos en la carpeta
    final query =
        "'$carpetaID' in parents and mimeType contains 'image/' and trashed = false";
    int total = 0;
    String? pageToken;

    do {
      // Utilizamos la API de Google Drive para listar los archivos
      final fileList = await _driveApi!.files.list(
        q: query,
        spaces: 'drive',
        $fields: 'nextPageToken, files(id)',
        pageSize: 1000,
        pageToken: pageToken,
      );
      total += fileList.files?.length ?? 0;
      pageToken = fileList.nextPageToken;
      // Retornamos la cantidad de archivos encontrados
    } while (pageToken != null);
    return total;
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
