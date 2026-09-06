import 'cart_item.dart';

class CartManager {
  static final List<CartItem> items = [];

  static void addItem({
    required String image,
    required String name,
    required String price,
    int quantity = 1,
  }) {
    final existingItem = items.where(
      (item) => item.name == name,
    );

    if (existingItem.isNotEmpty) {
      existingItem.first.quantity += quantity;
    } else {
      items.add(
        CartItem(
          image: image,
          name: name,
          price: price,
          quantity: quantity,
        ),
      );
    }
  }

  static void removeItem(CartItem item) {
    items.remove(item);
  }

  static double get total {
    double total = 0;

    for (final item in items) {
      total += item.totalPrice;
    }

    return total;
  }

  static void clearCart() {
    items.clear();
  }
}