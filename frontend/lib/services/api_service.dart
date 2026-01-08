import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/constants/api_constants.dart';

class ApiService {
  static Future<Map<String, dynamic>> predictImage(File image) async {


    final uri = Uri.parse("${ApiConstants.baseUrl}/predict");

    final request = http.MultipartRequest("POST", uri);
    request.files.add(
      await http.MultipartFile.fromPath("file", image.path),
    );

    request.headers.addAll({
      "Authorization": "Bearer ${ApiConstants.jwtToken}",
    });


    final response = await request.send();
    print("JWT VALUE = ${ApiConstants.jwtToken}");
    print("JWT IS NULL = ${ApiConstants.jwtToken == null}");


    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return jsonDecode(responseData);
    } else {
      throw Exception("Prediction failed");
    }
  }

}
