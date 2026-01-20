import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'models/models.dart';

// --- Konstanta Tema (DIKEMBALIKAN KE KAPITAL) ---
const Color PRIMARY_COLOR = Color(0xFF8B5CF6);
const Color BG_PRIMARY_DARK = Color(0xFF111827);
const Color BG_SECONDARY_DARK = Color(0xFF1F2937);
const Color BORDER_COLOR = Color(0xFF374151);
const Color TEXT_PRIMARY_DARK = Color(0xFFF9FAFB);
const Color TEXT_SECONDARY_DARK = Color(0xFF9CA3AF);

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const SadanaApp(),
    ),
  );
}

class AppState extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Product> products = [];
  List<Transaction> transactions = [];
  Map<int, int> cart = {};
  int? currentUserId;

  Future<void> sync() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      currentUserId = User.fromJson(jsonDecode(userStr)).id;
    }
    products = await _api.getProducts();
    transactions = await _api.getTransactions();
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUserId = null;
    cart = {};
    notifyListeners();
  }

  void addToCart(Product p) {
    cart[p.id!] = (cart[p.id!] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(Product p) {
    if (cart.containsKey(p.id!)) {
      if (cart[p.id!]! > 1) {
        cart[p.id!] = cart[p.id!]! - 1;
      } else {
        cart.remove(p.id!);
      }
      notifyListeners();
    }
  }

  // Method publik untuk merefresh UI dari luar class
  void refresh() => notifyListeners();

  double get total => cart.entries.fold(0, (sum, entry) {
    try {
      final p = products.firstWhere((p) => p.id == entry.key);
      return sum + (p.price * entry.value);
    } catch (e) {
      return sum;
    }
  });
}

class SadanaApp extends StatelessWidget {
  const SadanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
      bodyColor: TEXT_PRIMARY_DARK,
      displayColor: TEXT_PRIMARY_DARK,
    );

    return MaterialApp(
      title: 'SADANA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: BG_PRIMARY_DARK,
        textTheme: textTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PRIMARY_COLOR,
          primary: PRIMARY_COLOR,
          surface: BG_SECONDARY_DARK,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: BG_SECONDARY_DARK,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: BG_SECONDARY_DARK,
        ),
        dialogTheme: DialogThemeData(
            backgroundColor: BG_SECONDARY_DARK,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: BG_PRIMARY_DARK,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: BORDER_COLOR, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: BORDER_COLOR, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: PRIMARY_COLOR, width: 2),
          ),
          labelStyle: const TextStyle(color: TEXT_SECONDARY_DARK),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: PRIMARY_COLOR,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: PRIMARY_COLOR,
          )
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
