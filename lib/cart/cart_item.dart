class CartItem {
  final int productId;
  final String image;
  final String name;
  final String price;
  final int stockQuantity;
  int quantity;

  CartItem({
    required this.productId,
    required this.image,
    required this.name,
    required this.price,
    required this.stockQuantity,
    this.quantity = 1,
  });

  double get numericPrice {
    return double.parse(
      price.replaceAll(' EGP', ''),
    );
  }

  double get totalPrice {
    return numericPrice * quantity;
  }
}