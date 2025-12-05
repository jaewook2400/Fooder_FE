import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8080"; // ANDROID EMULATOR

  static final SecureStorage _storage = SecureStorage();

  /// 모든 요청에 공통적으로 들어가는 헤더
  static Future<Map<String, String>> _headers() async {
    final token = await _storage.getAccessToken();
    print("token is $token");
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // ---------------- AUTH ----------------

  static Future<Map<String, dynamic>> register(String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    final data = jsonDecode(res.body);

    // 로그인 성공 시 token 저장
    if (data["token"] != null) {
      await _storage.saveAccessToken(data["token"]);
      print("----- 토큰 저장됨 → ${data["token"]} -----");
    }

    return data;
  }

  // ---------------- RECIPE ----------------

  static Future<List<Map<String, dynamic>>> getIngredients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/home/ingredient'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load ingredients");
    }

    final json = jsonDecode(response.body);

    // 서버 구조: { "ingredients": [ { ingredient: "...", imageUrl: "..."} ] }
    final list = json['ingredients'] as List;

    // 리스트 안의 요소는 Map<String, dynamic> 형태
    return list.map((item) => {
      'ingredient': item['ingredient'],
      'imageUrl': item['imageUrl'],
    }).toList();
  }

  static Future<Map<String, dynamic>> sendPreference(List<bool> prefs) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/home/preference"),
      headers: await _headers(),
      body: jsonEncode({"preference": prefs}),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to send preference");
    }

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteRecipe(int recipeId) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/api/home/$recipeId"),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to delete recipe");
    }

    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getRecipes() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/recipe"),
      headers: {"Content-Type": "application/json"},
    );
    final data = jsonDecode(res.body);
    return data["recipes"];
  }

  static Future<Map<String, dynamic>> getRecipe(int id) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/recipe/$id"),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    return data["recipe"];
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

  static Future<List<dynamic>> getRecordedRecipes() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/record/recipe"),
      headers: await _headers(),
    );

    final json = jsonDecode(res.body);
    return json["recipes"] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> sendRecordRecipe(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/record/recipe"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteRecordedRecipe(int recipeId) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/api/record/$recipeId"),
      headers: await _headers(),
    );

    return jsonDecode(res.body);
  }

  static Future<String> createImageUrl() async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/imageUrl"),
      headers: await _headers(),
    );

    final data = jsonDecode(res.body);
    return data["imageUrl"] as String;
  }



  //-----디버그용-----

  static Future<int> getRecipeCount() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/debug/recipe-count"),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load recipe count");
    }

    final data = jsonDecode(res.body);
    return data["recipeCount"] as int;
  }
}