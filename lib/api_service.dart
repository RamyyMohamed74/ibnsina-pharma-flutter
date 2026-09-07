import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://localhost:7241/api';

  // AUTHENTICATION

  // Get saved JWT token
  static Future<String?> _getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('auth_token');
  }

  // Create authenticated headers
  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // LOGIN
  // ============================================================

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

  // ============================================================
  // PRODUCTS
  // ============================================================

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

  
  // CATEGORIES
  

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

  
  // CART

  // ADD TO CART
  static Future<Map<String, dynamic>> addToCart(
    int productId,
    int quantity,
  ) async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/Cart'),
      headers: headers,
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    if (response.statusCode == 400 ||
        response.statusCode == 404) {
      String message = 'Could not add product to cart.';

      try {
        final body = jsonDecode(response.body);

        if (body is String) {
          message = body;
        } else if (body is Map &&
            body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    throw Exception(
      'Failed to add product to cart. '
      'Status code: ${response.statusCode}',
    );
  }

  // GET CART
  static Future<List<dynamic>> getCart() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/Cart'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    throw Exception(
      'Failed to load cart. '
      'Status code: ${response.statusCode}',
    );
  }

  // UPDATE CART ITEM
  static Future<Map<String, dynamic>> updateCartItem(
    int productId,
    int quantity,
  ) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl/Cart/$productId'),
      headers: headers,
      body: jsonEncode({
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    if (response.statusCode == 400 ||
        response.statusCode == 404) {
      String message = 'Could not update cart item.';

      try {
        final body = jsonDecode(response.body);

        if (body is String) {
          message = body;
        } else if (body is Map &&
            body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    throw Exception(
      'Failed to update cart item. '
      'Status code: ${response.statusCode}',
    );
  }

  // DELETE CART ITEM
  static Future<void> deleteCartItem(
    int productId,
  ) async {
    final headers = await _authHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/Cart/$productId'),
      headers: headers,
    );

    if (response.statusCode == 204) {
      return;
    }

    if (response.statusCode == 401) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    if (response.statusCode == 404) {
      throw Exception('Cart item not found.');
    }

    throw Exception(
      'Failed to delete cart item. '
      'Status code: ${response.statusCode}',
    );
  }

  
  // ORDERS

  // PLACE ORDER
  static Future<Map<String, dynamic>> placeOrder() async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/Orders'),
      headers: headers,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    if (response.statusCode == 400) {
      String message =
          'Order could not be completed.';

      try {
        final body = jsonDecode(response.body);

        if (body is String) {
          message = body;
        } else if (body is Map &&
            body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    throw Exception(
      'Failed to place order. '
      'Status code: ${response.statusCode}',
    );
  }

  // GET ORDERS
  static Future<List<dynamic>> getOrders() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/Orders'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    throw Exception(
      'Failed to load orders. '
      'Status code: ${response.statusCode}',
    );
  }

  // GET ORDER BY ID
  static Future<Map<String, dynamic>> getOrderById(
    int id,
  ) async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/Orders/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    if (response.statusCode == 404) {
      throw Exception('Order not found');
    }

    throw Exception(
      'Failed to load order. '
      'Status code: ${response.statusCode}',
    );
  }
}
