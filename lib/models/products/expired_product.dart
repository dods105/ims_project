class ExpiredProduct {
  final int? id;
  final int userId;
  final String name;
  final int quantity;
  final double sellingPrice;
  final double? originalPrice;
  final String? productType;
  final String expiryDate;
  final String? description;
  final String? imagePath;
  final String movedAt; // date moved to exipred table db

  ExpiredProduct({
    this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.sellingPrice,
    this.originalPrice,
    this.productType,
    required this.expiryDate,
    this.description,
    this.imagePath,
    required this.movedAt,
  });

  // product obj to db
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
      'description': description,
      'image_path': imagePath,
      'moved_at': movedAt,
    };
  }

  // db back to prod object
  factory ExpiredProduct.fromMap(Map<String, dynamic> map) {
    return ExpiredProduct(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      quantity: map['quantity'],
      sellingPrice: map['selling_price'],
      originalPrice: map['original_price'],
      productType: map['product_type'],
      expiryDate: map['expiry_date'],
      description: map['description'],
      imagePath: map['image_path'],
      movedAt: map['moved_at'],
    );
  }
}
