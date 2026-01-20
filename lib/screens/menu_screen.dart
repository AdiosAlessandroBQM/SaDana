import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

// Tambahkan definisi warna jika belum ada di main.dart atau file tema
const Color primaryColor = Color(0xFF6366F1);
const Color textSecondaryDark = Color(0xFF9CA3AF);
const Color bgSecondaryDark = Color(0xFF1F2937);
const Color borderColor = Color(0xFF374151);
const Color bgPrimaryDark = Color(0xFF111827);
const Color textPrimaryDark = Color(0xFFE5E7EB);

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filteredProducts = state.products.where((p) {
      final matchSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory = _selectedCategory == null || p.category == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Menu', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              scrollDirection: Axis.vertical,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgSecondaryDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor.withValues(alpha: 0.5)),
                ),
                child: DataTable(
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('Produk')),
                    DataColumn(label: Text('Kategori')),
                    DataColumn(label: Text('Harga')),
                    DataColumn(label: Text('Stok')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: filteredProducts.map((p) => _buildDataRow(context, state, p)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context, state),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        backgroundColor: primaryColor,
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: '🔍 Cari produk...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: bgPrimaryDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                hint: const Text('Semua Kategori'),
                items: ['Makanan', 'Minuman', 'Snack', 'Sembako']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList()
                  ..insert(0, const DropdownMenuItem(value: null, child: Text('Semua Kategori'))),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, AppState state, Product p) {
    final bool lowStock = p.stock < 10;

    return DataRow(cells: [
      DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(p.category)),
      DataCell(Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(p.price))),
      DataCell(
          Row(
            children: [
              Text('${p.stock}'),
              if (lowStock)
                const Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                ),
            ],
          )
      ),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () => _showProductDialog(context, state, product: p),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteProduct(context, state, p),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    ]);
  }

  void _showProductDialog(BuildContext context, AppState state, {Product? product}) {
    final nameCtrl = TextEditingController(text: product?.name);
    final priceCtrl = TextEditingController(text: product?.price.toInt().toString());
    final stockCtrl = TextEditingController(text: product?.stock.toString());
    String category = product?.category ?? 'Makanan';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: ['Makanan', 'Minuman', 'Snack', 'Sembako']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => category = val!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
                onPressed: () async {
                  final p = Product(
                    id: product?.id,
                    name: nameCtrl.text,
                    category: category,
                    price: double.parse(priceCtrl.text),
                    stock: int.parse(stockCtrl.text),
                  );

                  bool ok;
                  if (product == null) {
                    ok = await ApiService().addProduct(p);
                  } else {
                    ok = await ApiService().updateProduct(p);
                  }

                  if (ok && context.mounted) {
                    Navigator.pop(context);
                    state.sync();
                  }
                },
                child: const Text('Simpan')
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(BuildContext context, AppState state, Product p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await ApiService().deleteProduct(p.id!);
      if (ok && context.mounted) {
        state.sync();
      }
    }
  }
}