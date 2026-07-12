import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/external_queue.dart';

class ExternalQueueResource {

  Future<void> update(
      String accessToken,
      String fileId,
      String activeQueueId,
      List<ExternalQueue> queues
      ) async {
    final body = {
      "activeQueue": activeQueueId,
      "updatedAt": DateTime.now().toIso8601String(),
      "queues": queues.map((q) => q.toMap()).toList(),
    };

    final response = await http.patch(
      Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=media',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ao atualizar queues.json: ${response.statusCode}\n${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> get(String accessToken, String fileId) async {
    final response = await http.get(
      Uri.parse(
        'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao baixar queues.json: ${response.statusCode}\n${response.body}',
      );
    }

    if (response.body.trim().isEmpty) {
      debugPrint("Archive is empty. Returning default");

      return {
        'activeQueue': "",
        'updatedAt': DateTime.now().toIso8601String(),
        'queues': [],
      };
    }

    return jsonDecode(response.body);
  }

  Future<String> getQueuesJsonId(String accessToken) async {
    final searchResponse = await http.get(
      Uri.parse(
        "https://www.googleapis.com/drive/v3/files"
            "?spaces=appDataFolder"
            "&q=name='queues.json' and trashed=false"
            "&fields=files(id,name)",
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (searchResponse.statusCode != 200) {
      throw Exception(
        'Erro ao procurar queues.json\n${searchResponse.body}',
      );
    }

    final searchData = jsonDecode(searchResponse.body) as Map<String, dynamic>;

    final files = (searchData['files'] as List<dynamic>? ?? []);

    if (files.isNotEmpty) {
      return files.first['id'];
    }

    // Se não existir, cria
    return await _createQueuesJson(accessToken);
  }

  Future<String> _createQueuesJson(String accessToken) async {
    final createResponse = await http.post(
      Uri.parse(
        'https://www.googleapis.com/drive/v3/files',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': 'queues.json',
        'parents': ['appDataFolder'],
        'mimeType': 'application/json',
      }),
    );

    if (createResponse.statusCode < 200 || createResponse.statusCode >= 300) {
      throw Exception(
        'Erro ao criar queues.json\n${createResponse.body}',
      );
    }

    final created = jsonDecode(createResponse.body) as Map<String, dynamic>;
    final fileId = created['id'] as String;

    // Inicializa com JSON válido
    final initializeResponse = await http.patch(
      Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=media',
      ),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'activeQueue': "",
        'updatedAt': DateTime.now().toIso8601String(),
        'queues': [],
      }),
    );

    if (initializeResponse.statusCode < 200 || initializeResponse.statusCode >= 300) {
      throw Exception(
        'Erro ao inicializar queues.json\n${initializeResponse.body}',
      );
    }

    debugPrint("FILE ID: $fileId");

    return fileId;
  }
}
