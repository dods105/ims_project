enum NotifType { expiringSoon, expired, lowStock, outOfStock }

class AppNotification {
  final int? id;
  final int userId;
  final int? productId;
  final String productName;
  final int quantity;
  final String expiryDate;
  final NotifType type;
  final bool isRead;
  final String createdAt;

  AppNotification({
    this.id,
    required this.userId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.expiryDate,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'expiry_date': expiryDate,
      'type': _typeToString(type),
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      userId: map['user_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      quantity: map['quantity'],
      expiryDate: map['expiry_date'],
      type: _typeFromString(map['type']),
      isRead: map['is_read'] == 1,
      createdAt: map['created_at'] ?? '',
    );
  }

  static String _typeToString(NotifType t) {
    switch (t) {
      case NotifType.expired:
        return 'expired';
      case NotifType.expiringSoon:
        return 'expiringSoon';
      case NotifType.lowStock:
        return 'lowStock';
      case NotifType.outOfStock:
        return 'outOfStock';
    }
  }

  static NotifType _typeFromString(String? s) {
    switch (s) {
      case 'expired':
        return NotifType.expired;
      case 'lowStock':
        return NotifType.lowStock;
      case 'outOfStock':
        return NotifType.outOfStock;
      default:
        return NotifType.expiringSoon;
    }
  }
}
