import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../main.dart';
import '../models/models.dart' as m;
import '../services/api_service.dart';

// Tambahkan definisi warna jika belum ada di main.dart atau file tema
const Color primaryColor = Color(0xFF6366F1);
const Color textSecondaryDark = Color(0xFF9CA3AF);
const Color bgSecondaryDark = Color(0xFF1F2937);
const Color borderColor = Color(0xFF374151);
const Color bgPrimaryDark = Color(0xFF111827);
const Color textPrimaryDark = Color(0xFFE5E7EB);

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filteredProducts = state.products.where((p) =>
        p.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Row(
        children: [
          // Products Section
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: '🔍 Cari produk...',
                      fillColor: bgSecondaryDark,
                      prefixIcon: const Icon(Icons.search, color: textSecondaryDark),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          }
                      )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, i) {
                      final p = filteredProducts[i];
                      return _buildProductCard(context, state, p);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Cart Section
          if (MediaQuery.of(context).size.width > 900)
            Container(
              width: 350,
              decoration: const BoxDecoration(
                color: bgSecondaryDark,
                border: Border(left: BorderSide(color: borderColor)),
              ),
              child: _buildCartPanel(context, state),
            ),
        ],
      ),
      // Mobile Cart Toggle
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900
          ? _buildMobileCartBar(context, state)
          : null,
    );
  }

  Widget _buildProductCard(BuildContext context, AppState state, m.Product p) {
    final bool outOfStock = p.stock <= 0;

    return InkWell(
      onTap: outOfStock ? null : () => state.addToCart(p),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bgSecondaryDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getCategoryIcon(p.category),
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              p.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(p.price),
              style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Stok: ${p.stock}',
              style: TextStyle(
                  fontSize: 11,
                  color: outOfStock ? Colors.redAccent : textSecondaryDark
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan': return '🍜';
      case 'Minuman': return '🥤';
      case 'Snack': return '🍿';
      case 'Sembako': return '🌾';
      default: return '📦';
    }
  }

  Widget _buildCartPanel(BuildContext context, AppState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Keranjang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (state.cart.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => state.cart.clear()),
                  child: const Text('Kosongkan', style: TextStyle(color: Colors.redAccent)),
                ),
            ],
          ),
        ),
        Expanded(
          child: state.cart.isEmpty
              ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(opacity: 0.5, child: Text('🛒', style: TextStyle(fontSize: 64))),
              SizedBox(height: 16),
              Text('Keranjang masih kosong', style: TextStyle(color: textSecondaryDark)),
            ],
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.cart.length,
            itemBuilder: (context, i) {
              final entry = state.cart.entries.toList()[i];
              final p = state.products.firstWhere((prod) => prod.id == entry.key);
              return _buildCartItem(state, p, entry.value);
            },
          ),
        ),
        _buildCartSummary(context, state),
      ],
    );
  }

  Widget _buildCartItem(AppState state, m.Product p, int qty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgPrimaryDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                onPressed: () {
                  state.cart.remove(p.id);
                  state.refresh();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _qtyBtn(Icons.remove, () => state.removeFromCart(p)),
                  SizedBox(width: 30, child: Center(child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)))),
                  _qtyBtn(Icons.add, () => state.addToCart(p)),
                ],
              ),
              Text(
                NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(p.price * qty),
                style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: textPrimaryDark),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(state.total),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: state.cart.isEmpty ? null : () => _doCheckout(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✓', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Text('Proses Transaksi'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCartBar(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: bgSecondaryDark,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontSize: 12, color: textSecondaryDark)),
                Text(
                  NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(state.total),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: state.cart.isEmpty ? null : () => _showMobileCart(context, state),
            child: Text('Keranjang (${state.cart.length})'),
          ),
        ],
      ),
    );
  }

  void _showMobileCart(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgSecondaryDark,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: _buildCartPanel(context, state),
      ),
    );
  }

  void _doCheckout(BuildContext context, AppState state) async {
    final transaction = m.Transaction(
      userId: state.currentUserId,
      totalAmount: state.total,
      items: state.cart.entries.map((e) {
        final p = state.products.firstWhere((prod) => prod.id == e.key);
        return m.TransactionItem(productId: p.id, productName: p.name, quantity: e.value, price: p.price);
      }).toList(),
    );

    final ok = await ApiService().saveTransaction(transaction);
    if (ok) {
      if (mounted) {
        _showReceipt(context, transaction);
        state.cart.clear();
        state.sync();
      }
    }
  }

  void _showReceipt(BuildContext context, m.Transaction t) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Struk Pembayaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    const Text('SADANA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const TextStyle(color: Colors.black, fontSize: 12)),
                    const Divider(color: Colors.black54),
                    ...t.items.map((i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${i.productName} x${i.quantity}', style: const TextStyle(color: Colors.black, fontSize: 14)),
                          Text(NumberFormat.currency(locale: 'id', symbol: '').format(i.price * i.quantity), style: const TextStyle(color: Colors.black, fontSize: 14)),
                        ],
                      ),
                    )),
                    const Divider(color: Colors.black, thickness: 1.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(t.totalAmount), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _printPdf(t),
                      child: const Text('🖨️ Print'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printPdf(m.Transaction t) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        children: [
          pw.Header(level: 0, text: 'SADANA - STRUK PEMBAYARAN'),
          pw.Divider(),
          ...t.items.map((i) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [pw.Text('${i.productName} x${i.quantity}'), pw.Text('Rp ${i.price * i.quantity}')],
          )),
          pw.Divider(),
          pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('TOTAL: Rp ${t.totalAmount}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        ],
      ),
    ));
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }
}