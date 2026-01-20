import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import 'kasir_screen.dart';
import 'menu_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

// Tambahkan definisi warna jika belum ada di main.dart atau file tema
const Color primaryColor = Color(0xFF6366F1);
const Color textSecondaryDark = Color(0xFF9CA3AF);
const Color bgSecondaryDark = Color(0xFF1F2937);
const Color borderColor = Color(0xFF374151);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AppState>().sync();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () => state.sync(),
              icon: const Icon(Icons.refresh_rounded)
          )
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 25),
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = (constraints.maxWidth - 15) / 2;
                return Row(
                  children: [
                    _buildStatCard('Total Produk', '${state.products.length}', Icons.inventory_2_outlined, Colors.blue, cardWidth),
                    const SizedBox(width: 15),
                    _buildStatCard('Total Transaksi', '${state.transactions.length}', Icons.receipt_long_outlined, Colors.green, cardWidth),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),
            _buildChartSection(state),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: bgSecondaryDark,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [primaryColor, Color(0xFF6366F1)]),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Text('🏪', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'SADANA',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Text(
                    'Dedikasi untuk Kepercayaan Anda',
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          _drawerItem(context, Icons.dashboard_rounded, 'Dashboard', null, isActive: true),
          _drawerItem(context, Icons.point_of_sale_rounded, 'Kasir', const KasirScreen()),
          _drawerItem(context, Icons.inventory_2_rounded, 'Data Menu', const MenuScreen()),
          _drawerItem(context, Icons.history_rounded, 'Riwayat Penjualan', const HistoryScreen()),
          const Spacer(),
          const Divider(color: borderColor),
          _drawerItem(context, Icons.person_outline, 'Profil Saya', const ProfileScreen()),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              final navigator = Navigator.of(context);
              final stateProvider = Provider.of<AppState>(context, listen: false);
              await stateProvider.logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Widget? screen, {bool isActive = false}) {
    return ListTile(
      leading: Icon(icon, color: isActive ? primaryColor : textSecondaryDark),
      title: Text(title, style: TextStyle(color: isActive ? Colors.white : textSecondaryDark, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      tileColor: isActive ? primaryColor.withValues(alpha: 0.1) : null,
      onTap: () {
        Navigator.pop(context);
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryColor, Color(0xFF6366F1)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selamat Datang! 👋', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Kelola stok dan pantau performa warung Anda hari ini.', style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgSecondaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: textSecondaryDark, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChartSection(AppState state) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: bgSecondaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tren Penjualan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Icon(Icons.trending_up, color: Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [const FlSpot(0, 2), const FlSpot(1, 1.5), const FlSpot(2, 4), const FlSpot(3, 3), const FlSpot(4, 5), const FlSpot(5, 4), const FlSpot(6, 6)],
                    isCurved: true,
                    color: primaryColor,
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [primaryColor.withValues(alpha: 0.3), primaryColor.withValues(alpha: 0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}