import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  void _doLogin() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final res = await ApiService().login(_user.text, _pass.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (res['success']) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Terjadi kesalahan'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: BG_PRIMARY_DARK,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: BG_SECONDARY_DARK.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: BORDER_COLOR.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hanya tampilkan logo tanpa kotak ungu, dengan ukuran yang lebih besar
                    Container(
                      width: 200, // Ukuran diperbesar dari 120 menjadi 200
                      height: 200, // Ukuran diperbesar dari 120 menjadi 200
                      margin: const EdgeInsets.only(bottom: 0),
                      child: Image.asset(
                        'assets/logo.png', // Pastikan ini adalah path ke gambar logo ke-2 Anda
                        fit: BoxFit.contain, // Gunakan 'fit: BoxFit.contain' agar logo tidak terpotong
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.storefront, size: 0, color: Colors.white),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Input Username
                    TextField(
                      controller: _user,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person_outline, color: TEXT_SECONDARY_DARK),
                        filled: true,
                        fillColor: BG_SECONDARY_DARK,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: BORDER_COLOR),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: BORDER_COLOR),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: PRIMARY_COLOR),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Password
                    TextField(
                      controller: _pass,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: TEXT_SECONDARY_DARK),
                        filled: true,
                        fillColor: BG_SECONDARY_DARK,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: BORDER_COLOR),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: BORDER_COLOR),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: PRIMARY_COLOR),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Masuk
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _doLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY_COLOR,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white,))
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_open, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Masuk', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Link Daftar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun? ', style: TextStyle(color: TEXT_SECONDARY_DARK)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: const Text(
                            'Daftar sekarang',
                            style: TextStyle(color: PRIMARY_COLOR, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}