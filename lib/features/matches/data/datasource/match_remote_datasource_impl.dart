import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/match_user_model.dart';
import 'match_remote_datasource.dart';

class MatchRemoteDatasourceImpl implements MatchRemoteDatasource {
  final http.Client client;
  final String baseUrl;
  final String token;

  MatchRemoteDatasourceImpl({
    required this.client,
    required this.baseUrl,
    required this.token,
  });

  @override
  Future<List<MatchUserModel>> getPotentialMatches() async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/matches/potential'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => MatchUserModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener matches: ${response.body}');
    }
  }
}
