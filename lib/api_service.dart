import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://localhost:7241/api';

//Login

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception('Invalid email or password');
    }

    throw Exception(
      'Login failed. Status code: ${response.statusCode}',
    );
  }

  // GET ALL PRODUCTS

  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Products'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load products. Status code: ${response.statusCode}',
    );
  }

  // GET PRODUCT BY ID

  static Future<Map<String, dynamic>> getProductById(
    int id,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Products/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 404) {
      throw Exception('Product not found');
    }

    throw Exception(
      'Failed to load product. Status code: ${response.statusCode}',
    );
  }

  // GET ALL CATEGORIES

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Categories'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load categories. Status code: ${response.statusCode}',
    );
  }

  // GET CATEGORY BY ID

  static Future<Map<String, dynamic>> getCategoryById(
    int id,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Categories/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 404) {
      throw Exception('Category not found');
    }

    throw Exception(
      'Failed to load category. Status code: ${response.statusCode}',
    );
  }
}

