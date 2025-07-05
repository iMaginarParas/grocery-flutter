import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'paras.dart'; // Import authentication screens
import 'atul.dart';  // Import main app screens

void main() {
  runApp(const GroceryApp());
}

// API Service Class
class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Change to your backend URL
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  static Map<String, String> get headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Auth APIs
  static Future<Map<String, dynamic>> register(String name, String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'phone': phone,
        'password': password,
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': phone,
        'password': password,
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  // Category APIs
  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  // Product APIs
  static Future<List<dynamic>> getProducts({String? categoryId, bool? featured, String? search}) async {
    var url = '$baseUrl/products';
    List<String> queryParams = [];
    
    if (categoryId != null) queryParams.add('category_id=$categoryId');
    if (featured != null) queryParams.add('featured=$featured');
    if (search != null) queryParams.add('search=$search');
    
    if (queryParams.isNotEmpty) {
      url += '?' + queryParams.join('&');
    }

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getProduct(String productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  // Cart APIs
  static Future<List<dynamic>> getCart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addToCart(String productId, int quantity, String selectedWeight, int selectedUnit) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
      body: json.encode({
        'product_id': productId,
        'quantity': quantity,
        'selected_weight': selectedWeight,
        'selected_unit': selectedUnit,
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateCartItem(String cartItemId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/$cartItemId?quantity=$quantity'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> removeCartItem(String cartItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> clearCart() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  // Order APIs
  static Future<Map<String, dynamic>> createOrder({
    required String deliverySlot,
    required String deliveryDate,
    required Map<String, dynamic> deliveryAddress,
    required String paymentMethod,
    String? specialInstructions,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
      body: json.encode({
        'delivery_slot': deliverySlot,
        'delivery_date': deliveryDate,
        'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
        'special_instructions': specialInstructions,
      }),
    );
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getOrder(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: headers,
    );
    return json.decode(response.body);
  }
}

// Models
class User {
  final String id;
  final String name;
  final String phone;
  final bool isActive;
  final bool isVerified;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      isActive: json['is_active'],
      isVerified: json['is_verified'],
      createdAt: json['created_at'],
    );
  }
}

class Category {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final int displayOrder;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.displayOrder,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      displayOrder: json['display_order'],
      isActive: json['is_active'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final double basePrice;
  final int stockQuantity;
  final bool featured;
  final bool isActive;
  final List<String> weightOptions;
  final List<int> unitOptions;
  final double discountPercentage;
  final String? imageUrl;
  final Category? category;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.basePrice,
    required this.stockQuantity,
    required this.featured,
    required this.isActive,
    required this.weightOptions,
    required this.unitOptions,
    required this.discountPercentage,
    this.imageUrl,
    this.category,
    this.quantity = 1,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      categoryId: json['category_id'],
      basePrice: json['base_price'].toDouble(),
      stockQuantity: json['stock_quantity'],
      featured: json['featured'],
      isActive: json['is_active'],
      weightOptions: List<String>.from(json['weight_options']),
      unitOptions: List<int>.from(json['unit_options']),
      discountPercentage: json['discount_percentage'].toDouble(),
      imageUrl: json['image_url'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }
}

class CartItem {
  final String id;
  final String userId;
  final String productId;
  int quantity;
  final String selectedWeight;
  final int selectedUnit;
  final String addedAt;
  final String updatedAt;
  final Product? product;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.selectedWeight,
    required this.selectedUnit,
    required this.addedAt,
    required this.updatedAt,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      selectedWeight: json['selected_weight'],
      selectedUnit: json['selected_unit'],
      addedAt: json['added_at'],
      updatedAt: json['updated_at'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

// Main App
class GroceryApp extends StatelessWidget {
  const GroceryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charkhi Vegetables',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// Auth Wrapper
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    // For demo purposes, we'll assume user is not logged in initially
    // In a real app, you'd check stored auth token here
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isLoggedIn 
        ? const MainScreen() 
        : LoginScreen(onLoginSuccess: () {
            setState(() {
              _isLoggedIn = true;
            });
          });
  }
}