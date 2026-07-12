import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ddnuvem/models/image.dart' as model;
import 'package:http/http.dart' as http;

class ExternalImageResource {

  Future<String> uploadImage(
      String accessToken,
      String assetsFolderId,
      model.Image image
      ) async {
    final createResponse = await http.post(
      Uri.parse('https://www.googleapis.com/drive/v3/files'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': image.path,
        'parents': [assetsFolderId],
      }),
    );

    if (createResponse.statusCode < 200 || createResponse.statusCode >= 300) {
      throw Exception('Error on creating image metadata: ${createResponse.body}');
    }

    final fileId = jsonDecode(createResponse.body)['id'];

    final uploadResponse = await http.patch(
      Uri.parse(
          'https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=media'
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'image/jpeg',
      },
      body: image.data as List<int>,
    );

    if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
      throw Exception('Error on image upload: ${uploadResponse.body}');
    }

    return fileId;
  }

  Future<Uint8List?> downloadImage(String accessToken, String fileId) async {
    final response = await http.get(
      Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error on download image from google drive: ${response.statusCode}\n${response.body}',
      );
    }

    return response.bodyBytes;
  }

  Future<void> deleteImage(String accessToken, String fileId) async {
    final response = await http.delete(
      Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ao deletar a imagem: ${response.statusCode}\n${response.body}',
      );
    }

    debugPrint("Imagem com ID $fileId deletada com sucesso do Drive.");
  }

  Future<String> getAssetsFolderId(String accessToken) async {
    final searchResponse = await http.get(
      Uri.parse(
        "https://www.googleapis.com/drive/v3/files"
            "?spaces=appDataFolder"
            "&q=name='assets' "
            "and mimeType='application/vnd.google-apps.folder' "
            "and trashed=false"
            "&fields=files(id,name)",
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (searchResponse.statusCode != 200) {
      throw Exception(
        'Erro ao procurar pasta assets\n${searchResponse.body}',
      );
    }

    final searchData = jsonDecode(searchResponse.body) as Map<String, dynamic>;

    final files = (searchData['files'] as List<dynamic>? ?? []);

    if (files.isNotEmpty) {
      return files.first['id'];
    }

    // Se não existir, cria
    return await _createAssetsFolder(accessToken);
  }

  Future<String> _createAssetsFolder(String accessToken,) async {
    final createResponse = await http.post(
      Uri.parse(
        'https://www.googleapis.com/drive/v3/files',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': 'assets',
        'mimeType': 'application/vnd.google-apps.folder',
        'parents': ['appDataFolder'],
      }),
    );

    if (createResponse.statusCode < 200 || createResponse.statusCode >= 300) {
      throw Exception(
        'Erro ao criar pasta assets\n${createResponse.body}',
      );
    }

    final created = jsonDecode(createResponse.body) as Map<String, dynamic>;
    return created['id'] as String;
  }
}