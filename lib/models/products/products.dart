class Product {
  final int? id;
  final int userId;
  final String name;
  final int quantity;
  final int sellingPrice;
  final int? originalPrice;
  final String? productType;
  final String? expiryDate;
  final String? barcode;

  Product({
    this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.sellingPrice,
    this.originalPrice,
    this.productType,
    this.expiryDate,
    this.barcode,
  });

  // Product object to db
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'quantity': quantity,
      'selling_price': sellingPrice,
      'original_price': originalPrice,
      'product_type': productType,
      'expiry_date': expiryDate,
      'barcode': barcode,
    };
  }

  // db to Product object
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      quantity: map['quantity'],
      sellingPrice: map['selling_price'],
      originalPrice: map['original_price'],
      productType: map['product_type'],
      expiryDate: map['expiry_date'],
      barcode: map['barcode'],
    );
  }
}
