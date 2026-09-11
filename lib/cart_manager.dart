import 'cart_item.dart';

class CartManager {
  static final List<CartItem> items = [];

  // CART CHANGE LISTENERS

  static final List<void Function()> _listeners = [];

  // ADD LISTENER

  static void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  // REMOVE LISTENER

  static void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  // NOTIFY LISTENERS

  static void _notifyListeners() {
    for (final listener in List<void Function()>.from(_listeners)) {
      listener();
    }
  }

  // ADD ITEM

  static bool addItem({
    required int productId,
    required String image,
    required String name,
    required String price,
    required int stockQuantity,
    int quantity = 1,
  }) {
    final existingItems = items.where(
      (item) => item.productId == productId,
    );

    if (existingItems.isNotEmpty) {
      final existingItem = existingItems.first;

      // Check stock before increasing quantity
      if (existingItem.quantity + quantity >
          existingItem.stockQuantity) {
        return false;
      }

      existingItem.quantity += quantity;

      // Notify HomePage and other listeners
      _notifyListeners();

      return true;
    }

    // Product completely out of stock
    if (stockQuantity <= 0) {
      return false;
    }

    // Requested quantity exceeds stock
    if (quantity > stockQuantity) {
      return false;
    }

    items.add(
      CartItem(
        productId: productId,
        image: image,
        name: name,
        price: price,
        stockQuantity: stockQuantity,
        quantity: quantity,
      ),
    );

    // Notify HomePage and other listeners
    _notifyListeners();

    return true;
  }

  // REMOVE ITEM

  static void removeItem(CartItem item) {
    items.remove(item);

    // Notify HomePage and other listeners
    _notifyListeners();
  }

  // INCREASE QUANTITY

  static bool increaseQuantity(CartItem item) {
    if (item.quantity >= item.stockQuantity) {
      return false;
    }

    item.quantity++;

    // Notify listeners
    _notifyListeners();

    return true;
  }

  // DECREASE QUANTITY

  static void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;

      // Notify listeners
      _notifyListeners();
    }
  }

  // TOTAL

  static double get total {
    double total = 0;

    for (final item in items) {
      total += item.totalPrice;
    }

    return total;
  }

  // CLEAR CART

  static void clearCart() {
    items.clear();

    // Notify listeners
    _notifyListeners();
  }
}