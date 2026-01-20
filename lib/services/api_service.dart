import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:3000/api';

  // Helper untuk menangani parsing JSON dengan aman
  dynamic _safeDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = _safeDecode(response.body);

      if (response.statusCode == 200 && data != null) {
        final user = User.fromJson(data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(user.toJson()));
        return {'success': true, 'user': user};
      } else {
        return {
          'success': false, 
          'message': data != null ? data['message'] : 'Login gagal (Server tidak merespon)'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: Masalah jaringan atau server mati.'};
    }
  }

  Future<Map<String, dynamic>> register(String username, String password, String fullName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password, 'full_name': fullName}),
      );

      final data = _safeDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return {
          'success': false, 
          'message': data != null ? data['message'] : 'Gagal mendaftar'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: Masalah jaringan atau server mati.'};
    }
  }

  // --- PRODUCTS ---

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));
      if (response.statusCode == 200) {
        final data = _safeDecode(response.body);
        if (data is List) {
          return data.map((item) => Product.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print("GetProducts Error: $e");
    }
    return [];
  }

  Future<bool> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/products/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- TRANSACTIONS ---

  Future<bool> saveTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaction.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/transactions'));
      if (response.statusCode == 200) {
        final data = _safeDecode(response.body);
        if (data is List) {
          return data.map((item) => Transaction.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print("GetTransactions Error: $e");
    }
    return [];
  }
}
