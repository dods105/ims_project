class Product {
  final int? id;
  final int userId;
  final String name;
  final int quantity;
  final double sellingPrice;
  final double? originalPrice;
  final String productType;
  final String? expiryDate;
  final String? barcode;
  final String? description;
  final String? imagePath;

  Product({
    this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.sellingPrice,
    this.originalPrice,
    required this.productType,
    this.expiryDate,
    this.barcode,
    this.description,
    this.imagePath,
  });

  // prod to db
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
      'description': description,
      'image_path': imagePath,
    };
  }

  // db to product obj
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
      description: map['description'],
      imagePath: map['image_path'],
    );
  }
}
