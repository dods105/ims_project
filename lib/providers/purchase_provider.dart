import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase/transaction_items.dart';
import '../models/products/products.dart';

// represents a single line item in the cart.
class PurchaseItem {
  final Product product;
  int quantity;

  PurchaseItem({required this.product, required this.quantity});

  double get subtotal => product.sellingPrice * quantity;
}

// snapssjot of the cart content when purchasing
// so even if the product price change later on, the pass purchase items in the receipt would still keep the orig price it was brought at
class PurchaseState {
  final Map<int, PurchaseItem> items;

  PurchaseState({this.items = const {}});

  // Sum of all item subtotals (quantity × unit price each).
  double get totalPrice {
    return items.values.fold(0, (sum, item) => sum + item.subtotal);
  }

  // Total number of individual units across all line items.
  int get totalItems {
    return items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  // Returns a new PurchaseState with the given fields replaced.
  PurchaseState copyWith({Map<int, PurchaseItem>? items}) {
    return PurchaseState(items: items ?? this.items);
  }
}

class PurchaseNotifier extends Notifier<PurchaseState> {
  @override
  PurchaseState build() {
    return PurchaseState();
  }

  // Adds a product in the cart with the given quantity.
  // called from the product list when the user taps a product.
  void addProduct(Product product, int quantity) {
    final newItems = Map<int, PurchaseItem>.from(state.items);
    newItems[product.id!] = PurchaseItem(product: product, quantity: quantity);
    state = state.copyWith(items: newItems);
  }

  // remove product in cart
  // called when item was checked ad unchecked
  void removeProduct(int productId) {
    final newItems = Map<int, PurchaseItem>.from(state.items);
    newItems.remove(productId);
    state = state.copyWith(items: newItems);
  }

  // updates quantity noth increase and decrease
  void updateQuantity(int productId, int quantity) {
    final newItems = Map<int, PurchaseItem>.from(state.items);
    final existing = newItems[productId];
    // minimum order of 1
    // remove from available product if qty reaches 0 and move to out of stock.
    final safeQty = quantity < 1 ? 1 : quantity;
    if (existing != null) {
      newItems[productId] = PurchaseItem(
        product: existing.product,
        quantity: safeQty,
      );
      state = state.copyWith(items: newItems);
    }
  }

  // make cart empty once checkout is complete
  void clear() {
    state = PurchaseState();
  }

  // saaves the transaction to the database
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
