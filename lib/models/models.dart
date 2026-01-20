// lib/models/user.dart
class User {
  final int id;
  final String username;
  final String fullName;

  User({required this.id, required this.username, required this.fullName});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    fullName: json['full_name'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'full_name': fullName,
  };
}

// lib/models/product.dart
class Product {
  final int? id;
  final String name;
  final String category;
  final double price;
  final int stock;

  Product({this.id, required this.name, required this.category, required this.price, required this.stock});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    category: json['category'] ?? 'Umum',
    price: double.parse(json['price'].toString()),
    stock: int.parse(json['stock'].toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'stock': stock,
  };
}

// lib/models/transaction.dart
class TransactionItem {
  final int? productId;
  final String? productName;
  final int quantity;
  final double price;

  TransactionItem({this.productId, this.productName, required this.quantity, required this.price});

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
    productId: json['product_id'],
    productName: json['name'],
    quantity: json['quantity'],
    price: double.parse(json['price_at_transaction'].toString()),
  );

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'price_at_transaction': price,
  };
}

class Transaction {
  final int? id;
  final int? userId;
  final double totalAmount;
  final DateTime? date;
  final List<TransactionItem> items;

  Transaction({this.id, this.userId, required this.totalAmount, this.date, required this.items});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    var itemsList = (json['items'] as List? ?? []).map((i) => TransactionItem.fromJson(i)).toList();
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      totalAmount: double.parse(json['total_amount'].toString()),
      date: json['transaction_date'] != null ? DateTime.parse(json['transaction_date']) : null,
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'total_amount': totalAmount,
    'items': items.map((e) => e.toJson()).toList(),
  };
}
