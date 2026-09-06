class CartItem {
  final String image;
  final String name;
  final String price;
  int quantity;

  CartItem({
    required this.image,
    required this.name,
    required this.price,
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