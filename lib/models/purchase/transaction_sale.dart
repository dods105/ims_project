class TransactionSale {
  final String? id; // transaction id
  final int
  userId; // which user does this transaction belongs to. to get the user id. use: user.id
  final String? customerName;
  final String? customerAddress;
  final double amountPayed;
  final double totalAmount;
  final double changeAmount;
  final String transactedAt; // date and time of transaction. use ISO datetime

  TransactionSale({
    this.id,
    required this.userId,
    this.customerName,
    this.customerAddress,
    required this.amountPayed,
    required this.totalAmount,
    required this.changeAmount,
    required this.transactedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'customer_address': customerAddress,
      'amount_payed': amountPayed,
      'total_amount': totalAmount,
      'change_amount': changeAmount,
      'transacted_at': transactedAt,
    };
  }

  factory TransactionSale.fromMap(Map<String, dynamic> map) {
    return TransactionSale(
      id: map['id'],
      userId: map['user_id'],
      customerName: map['customer_name'],
      customerAddress: map['customer_address'],
      amountPayed: map['amount_payed'],
      totalAmount: map['total_amount'],
      changeAmount: map['change_amount'],
      transactedAt: map['transacted_at'],
    );
  }
}
