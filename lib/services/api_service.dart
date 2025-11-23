import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secure_storage.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8080"; // ANDROID EMULATOR

  static final SecureStorage _storage = SecureStorage();

  /// 모든 요청에 공통적으로 들어가는 헤더
  static Future<Map<String, String>> _headers() async {
    final token = await _storage.getAccessToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ---------------- AUTH ----------------

  static Future<Map<String, dynamic>> register(String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/register"),
      headers: await _headers(),
      body: jsonEncode({"username": username, "password": password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/login"),
      headers: await _headers(),
      body: jsonEncode({"username": username, "password": password}),
    );

    final data = jsonDecode(res.body);

    // 로그인 성공 시 token 저장
    if (data["token"] != null) {
      await _storage.saveAccessToken(data["token"]);
      print("🔑 토큰 저장됨 → ${data["token"]}");
    }

    return data;
  }

  // ---------------- RECIPE ----------------

  static Future<List<dynamic>> getRecipes() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/recipe"),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    return data["recipes"];
  }

  static Future<Map<String, dynamic>> getRecipe(int id) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/recipe/$id"),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> likeRecipe(int id) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/recipe/$id/like"),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> unlikeRecipe(int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/api/recipe/$id/like"),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<dynamic> getLikedRecipes() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/recipe/like"),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }
}