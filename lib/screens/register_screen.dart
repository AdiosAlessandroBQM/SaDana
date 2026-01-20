import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _confirmPass = TextEditingController();
  final _fullName = TextEditingController();
  bool _loading = false;

  void _doRegister() async {
    if (_pass.text != _confirmPass.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi tidak cocok!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _loading = true);

    final res = await ApiService().register(_user.text, _pass.text, _fullName.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil! Silakan login.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Gagal mendaftar'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: BG_PRIMARY_DARK),
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
                    // Judul dengan ikon bintang
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.yellow, size: 24), // Ikon bintang
                        const SizedBox(width: 8),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [PRIMARY_COLOR, Color(0xFF6366F1)],
                          ).createShader(bounds),
                          child: const Text(
                            'Daftar Akun',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    const Text(
                      'Isi data diri Anda untuk memulai',
                      style: TextStyle(fontSize: 14, color: TEXT_SECONDARY_DARK),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Input Nama Lengkap
                    TextField(
                      controller: _fullName,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
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

                    // Input Username
                    TextField(
                      controller: _user,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.alternate_email, color: TEXT_SECONDARY_DARK),
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
                    const SizedBox(height: 16),

                    // Input Konfirmasi Password
                    TextField(
                      controller: _confirmPass,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: const Icon(Icons.lock_reset, color: TEXT_SECONDARY_DARK),
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

                    // Tombol Daftar Akun
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _doRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY_COLOR,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white,))
                            : const Text('Daftar Akun', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Link Masuk
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun? ', style: TextStyle(color: TEXT_SECONDARY_DARK)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Masuk',
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