//per product
class TransactionItems {
  final int? id;
  final String transactionId; // which transaction does this item belongs to.
  final int
  productsId; //id of the product from the products table that was sold.
  final String name;
  final String? barcode;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  TransactionItems({
    this.id,
    required this.transactionId,
    required this.productsId,
    required this.name,
    this.barcode,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'products_id': productsId,
      'product_name': name,
      'barcode': barcode,
      'unit_price': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory TransactionItems.fromMap(Map<String, dynamic> map) {
    return TransactionItems(
      id: map['id'],
      transactionId: map['transaction_id'],
      productsId: map['products_id'],
      name: map['product_name'],
      barcode: map['barcode'],
      unitPrice: map['unit_price'],
      quantity: map['quantity'],
      subtotal: map['subtotal'],
    );
  }
}
