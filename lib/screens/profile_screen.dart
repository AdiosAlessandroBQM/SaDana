import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    // In a real app, we'd fetch the latest user data. 
    // For now, let's assume currentUserId gives us enough to mock or find in state if users were synced.
    // However, AppState doesn't store full user list, only currentUserId.
    // Let's assume we can get name from somewhere or just use a placeholder if not available.
    _nameCtrl.text = "User #${state.currentUserId}"; 
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    // Mocking some stats like in HTML
    final userTransactions = state.transactions.length; // Simplified for demo
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(state),
                const SizedBox(height: 25),
                
                // Account Info
                _buildCard(
                  title: 'Informasi Akun',
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'user_${state.currentUserId}',
                          filled: true,
                          fillColor: BG_PRIMARY_DARK.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Username tidak dapat diubah', style: TextStyle(color: TEXT_SECONDARY_DARK, fontSize: 12)),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui')));
                          },
                          child: const Text('💾 Simpan Perubahan'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                
                // Change Password
                _buildCard(
                  title: 'Ubah Password',
                  child: Column(
                    children: [
                      TextField(controller: _oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password Lama')),
                      const SizedBox(height: 16),
                      TextField(controller: _newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password Baru')),
                      const SizedBox(height: 16),
                      TextField(controller: _confirmPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru')),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                             if (_newPassCtrl.text != _confirmPassCtrl.text) {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password tidak cocok!'), backgroundColor: Colors.redAccent));
                               return;
                             }
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah'), backgroundColor: Colors.green));
                          },
                          child: const Text('🔐 Ubah Password'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                
                // Statistics
                _buildCard(
                  title: 'Statistik Anda',
                  child: Row(
                    children: [
                      _buildStatItem('Total Transaksi', '$userTransactions'),
                      _buildStatItem('Bergabung Sejak', DateFormat('MMM yyyy').format(DateTime.now())),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: BG_SECONDARY_DARK,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BORDER_COLOR.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF472B6), PRIMARY_COLOR]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: PRIMARY_COLOR.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
            ),
            child: const Center(child: Text('👤', style: TextStyle(fontSize: 48))),
          ),
          const SizedBox(height: 16),
          Text(_nameCtrl.text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('@user_${state.currentUserId}', style: const TextStyle(color: TEXT_SECONDARY_DARK)),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BG_SECONDARY_DARK,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BORDER_COLOR.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: TEXT_SECONDARY_DARK, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: PRIMARY_COLOR)),
        ],
      ),
    );
  }
}
