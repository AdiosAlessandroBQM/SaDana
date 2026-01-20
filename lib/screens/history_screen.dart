import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/models.dart';

// Tambahkan definisi warna jika belum ada di main.dart atau file tema
const Color primaryColor = Color(0xFF6366F1);
const Color textSecondaryDark = Color(0xFF9CA3AF);
const Color bgSecondaryDark = Color(0xFF1F2937);
const Color borderColor = Color(0xFF374151);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final transactions = state.transactions;

    final double totalRevenue = transactions.fold(0, (sum, t) => sum + t.totalAmount);
    final int totalCount = transactions.length;
    final double avgTransaction = totalCount > 0 ? totalRevenue / totalCount : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penjualan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Stats (Top Row)
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = (constraints.maxWidth - 30) / (constraints.maxWidth > 800 ? 3 : 1);
                return Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    _buildRevenueCard(totalRevenue, cardWidth),
                    _buildStatCard('Total Transaksi', '$totalCount', Icons.receipt_long, cardWidth),
                    _buildStatCard('Rata-rata Transaksi', NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(avgTransaction), Icons.analytics, cardWidth),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),

            // Filters Row
            _buildFilters(),
            const SizedBox(height: 25),

            // Transactions List
            const Text('Daftar Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            transactions.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text('Tidak ada transaksi ditemukan', style: TextStyle(color: textSecondaryDark)),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return _buildTransactionCard(context, t);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(double total, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💰 Total Pemasukan', style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(total),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgSecondaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: textSecondaryDark, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgSecondaryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterBtn('Hari Ini'),
            _filterBtn('7 Hari'),
            _filterBtn('30 Hari'),
            _filterBtn('Semua'),
          ],
        ),
      ),
    );
  }

  Widget _filterBtn(String label) {
    bool active = _activeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () => setState(() => _activeFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: active ? null : Border.all(color: borderColor),
          ),
          child: Text(label, style: TextStyle(color: active ? Colors.white : textSecondaryDark, fontSize: 13, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction t) {
    return InkWell(
      onTap: () => _showDetail(context, t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgSecondaryDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${t.id}', style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  t.date != null ? DateFormat('dd MMM yyyy, HH:mm').format(t.date!) : '-',
                  style: const TextStyle(color: textSecondaryDark, fontSize: 12),
                ),
                Text(
                  'Kasir ID: ${t.userId} • ${t.items.length} item',
                  style: const TextStyle(color: textSecondaryDark, fontSize: 12),
                ),
              ],
            ),
            Text(
              NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(t.totalAmount),
              style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Transaction t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Transaksi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('No. Transaksi', '#${t.id}'),
              _detailRow('Waktu', t.date != null ? DateFormat('dd/MM/yyyy HH:mm').format(t.date!) : '-'),
              const Divider(height: 32),
              const Text('Item Pembelian:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...t.items.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(i.productName ?? 'Unknown')),
                    Text('x${i.quantity} ${NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(i.price * i.quantity)}'),
                  ],
                ),
              )),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(t.totalAmount),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: textSecondaryDark)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}