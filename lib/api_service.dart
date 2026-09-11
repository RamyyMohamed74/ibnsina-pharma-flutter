import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://localhost:7241/api';

  // AUTHENTICATION

  static Future<Map<String, String>> _headers({
    bool includeJson = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (includeJson) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();

      if (data['token'] != null &&
          data['token'].toString().isNotEmpty) {
        await prefs.setString(
          'auth_token',
          data['token'].toString(),
        );
      }

      return data;
    }

    String message = 'Login failed';

    try {
      final data = jsonDecode(response.body);

      if (data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {
      // Keep default message.
    }

    throw Exception(message);
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Registration does NOT automatically log the user in.
      // The backend currently returns an empty token.
      // The user will login normally after creating the account.

      return data;
    }

    String message = 'Registration failed';

    try {
      final data = jsonDecode(response.body);

      if (data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {}

    throw Exception(message);
  }

  // GET CURRENT USER
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Auth/me'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to get current user: ${response.body}',
    );
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
  }

  // PRODUCTS

  static Future<List<dynamic>> getProducts({
    String? search,
    int? categoryId,
  }) async {
    final queryParameters = <String, String>{};

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    if (categoryId != null) {
      queryParameters['categoryId'] = categoryId.toString();
    }

    final uri = Uri.parse(
      '$baseUrl/Products',
    ).replace(
      queryParameters: queryParameters.isEmpty
          ? null
          : queryParameters,
    );

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      return [];
    }

    throw Exception(
      'Failed to load products: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> getProductById(
    int productId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Products/$productId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load product: ${response.body}',
    );
  }

  // CATEGORIES

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Categories'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      return [];
    }

    throw Exception(
      'Failed to load categories: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> getCategoryById(
    int categoryId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Categories/$categoryId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load category: ${response.body}',
    );
  }

  // CART

  static Future<List<dynamic>> getCart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Cart'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      return [];
    }

    throw Exception(
      'Failed to load cart: ${response.body}',
    );
  }

  static Future<void> addToCart(
    int productId,
    int quantity,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Cart'),
      headers: await _headers(
        includeJson: true,
      ),
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Failed to add product to cart: ${response.body}',
      );
    }
  }

  static Future<void> updateCartItem(
    int productId,
    int quantity,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Cart/$productId'),
      headers: await _headers(
        includeJson: true,
      ),
      body: jsonEncode({
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update cart: ${response.body}',
      );
    }
  }

  static Future<void> removeFromCart(
    int productId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Cart/$productId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Failed to remove product from cart: ${response.body}',
      );
    }
  }

  // ORDERS

  static Future<Map<String, dynamic>> placeOrder() async {
    final response = await http.post(
      Uri.parse('$baseUrl/Orders'),
      headers: await _headers(
        includeJson: true,
      ),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to place order: ${response.body}',
    );
  }

  static Future<List<dynamic>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Orders'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      return [];
    }

    throw Exception(
      'Failed to load orders: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> getOrderById(
    int orderId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Orders/$orderId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load order: ${response.body}',
    );
  }

  // CHECKOUT

  static Future<Map<String, dynamic>> checkout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/Orders'),
      headers: await _headers(
        includeJson: true,
      ),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Checkout failed: ${response.body}',
    );
  }

  // USER ADDRESS

  static Future<Map<String, dynamic>> getMyAddress() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Users/me/address'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load address: ${response.body}',
    );
  }

  static Future<void> updateMyAddress(
    Map<String, dynamic> address,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Users/me/address'),
      headers: await _headers(
        includeJson: true,
      ),
      body: jsonEncode(address),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update address: ${response.body}',
      );
    }
  }
}
