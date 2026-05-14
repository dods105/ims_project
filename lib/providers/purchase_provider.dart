import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase/transaction_items.dart';
import '../models/products/products.dart';

class PurchaseItem {
  final Product product;
  int quantity;

  PurchaseItem({required this.product, required this.quantity});

  double get subtotal => product.sellingPrice * quantity;
}

class PurchaseState {
  final Map<int, PurchaseItem> items;

  PurchaseState({this.items = const {}});

  double get totalPrice {
    return items.values.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get totalItems {
    return items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  PurchaseState copyWith({Map<int, PurchaseItem>? items}) {
    return PurchaseState(items: items ?? this.items);
  }
}

class PurchaseNotifier extends Notifier<PurchaseState> {
  @override
  PurchaseState build() {
    return PurchaseState();
  }

  void addProduct(Product product, int quantity) {
    final newItems = Map<int, PurchaseItem>.from(state.items);
    newItems[product.id!] = PurchaseItem(product: product, quantity: quantity);
    state = state.copyWith(items: newItems);
  }

  void removeProduct(int productId) {
    final newItems = Map<int, PurchaseItem>.from(state.items);
    newItems.remove(productId);
    state = state.copyWith(items: newItems);
  }

  void updateQuantity(int productId, int quantity) {
    final newItems = Map<int, PurchaseItem>.from(state.items);
    final existing = newItems[productId];
    if (existing != null && quantity > 0) {
      newItems[productId] = PurchaseItem(
        product: existing.product,
        quantity: quantity,
      );
      state = state.copyWith(items: newItems);
    }
  }

  void clear() {
    state = PurchaseState();
  }

  List<TransactionItems> getTransactionItems(String transactionId) {
    return state.items.values
        .map(
          (item) => TransactionItems(
            transactionId: transactionId,
            productsId: item.product.id!,
            name: item.product.name,
            barcode: item.product.barcode,
            unitPrice: item.product.sellingPrice,
            quantity: item.quantity,
            subtotal: item.subtotal,
          ),
        )
        .toList();
  }
}

final purchaseProvider = NotifierProvider<PurchaseNotifier, PurchaseState>(
  PurchaseNotifier.new,
);
