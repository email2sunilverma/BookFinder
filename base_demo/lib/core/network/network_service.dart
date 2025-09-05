import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';
import '../constants/api_constants.dart';

class NetworkService {
  final http.Client client;
  
  NetworkService({required this.client});
  
  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await client
          .get(
            Uri.parse(url),
            headers: headers ?? {'Content-Type': 'application/json'},
          )
          .timeout(ApiConstants.timeoutDuration);
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('No Internet connection');
    } on http.ClientException {
      throw const NetworkException('Client error occurred');
    } catch (e) {
      throw NetworkException('Network error: ${e.toString()}');
    }
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body);
      case 400:
        throw const ServerException('Bad request');
      case 401:
        throw const ServerException('Unauthorized');
      case 403:
        throw const ServerException('Forbidden');
      case 404:
        throw const ServerException('Not found');
      case 500:
        throw const ServerException('Internal server error');
      default:
        throw ServerException('Server error: ${response.statusCode}');
    }
  }
}
