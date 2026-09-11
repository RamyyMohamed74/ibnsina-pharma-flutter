import 'package:flutter/material.dart';
import 'cart_manager.dart';
import 'cart_item.dart';
import 'api_service.dart';

class CartPage extends StatefulWidget {
  // Callback sent from HomePage.
  // It will be called after an order is successfully completed.
  final VoidCallback onOrderCompleted;

  const CartPage({
    super.key,
    required this.onOrderCompleted,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isCheckingOut = false;

  // REMOVE ITEM

  Future<void> removeItem(CartItem item) async {
    try {
      // First remove the item from the backend
      await ApiService.removeFromCart(item.productId);

      // Then remove it from the local Flutter cart
      CartManager.removeItem(item);

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.name} removed from cart',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  // INCREASE QUANTITY

  Future<void> increaseQuantity(CartItem item) async {
    final newQuantity = item.quantity + 1;

    // Check local stock first
    if (newQuantity > item.stockQuantity) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only ${item.stockQuantity} items available in stock',
          ),
        ),
      );

      return;
    }

    try {
      // Update backend first
      await ApiService.updateCartItem(
        item.productId,
        newQuantity,
      );

      // Then update local cart
      final success = CartManager.increaseQuantity(item);

      if (!mounted) return;

      setState(() {});

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Only ${item.stockQuantity} items available in stock',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  // DECREASE QUANTITY

  Future<void> decreaseQuantity(CartItem item) async {
    final newQuantity = item.quantity - 1;

    try {
      if (newQuantity <= 0) {
        // If quantity becomes zero,
        // remove the product from backend
        await ApiService.removeFromCart(
          item.productId,
        );

        // Remove from local cart
        CartManager.removeItem(item);
      } else {
        // Update backend
        await ApiService.updateCartItem(
          item.productId,
          newQuantity,
        );

        // Update local cart
        CartManager.decreaseQuantity(item);
      }

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  // PLACE ORDER

  Future<void> checkout() async {
    if (CartManager.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your cart is empty',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    try {
      // Call backend Order API
      final order = await ApiService.placeOrder();

      if (!mounted) return;

      // Get information returned by backend
      final orderId = order['id'];

      final totalAmount =
          order['totalAmount'] ?? CartManager.total;

      
      CartManager.clearCart();

      setState(() {});

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            title: const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Thank you for your order.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),

                if (orderId != null)
                  Text(
                    'Order #$orderId',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 10),

                Text(
                  'Total: ${double.parse(totalAmount.toString()).toStringAsFixed(2)} EGP',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );

      // ORDER COMPLETED
      // Tell HomePage to switch from Cart to Home.

      if (!mounted) return;

      widget.onOrderCompleted();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final items = CartManager.items;

    return Column(
      children: [
        // CART CONTENT

        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Add some products to your cart',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 15,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // PRODUCT IMAGE

                            Container(
                              width: 85,
                              height: 85,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: item.image.startsWith('http')
                                  ? Image.network(
                                      item.image,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                        return const Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      item.image,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                        return const Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                        );
                                      },
                                    ),
                            ),

                            const SizedBox(width: 15),

                            // PRODUCT INFO

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    item.price,
                                    style: const TextStyle(
                                      color: Color.fromARGB(
                                        255,
                                        76,
                                        92,
                                        175,
                                      ),
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // QUANTITY CONTROLS

                                  Row(
                                    children: [
                                      Container(
                                        decoration:
                                            BoxDecoration(
                                          border: Border.all(
                                            color: Colors
                                                .grey
                                                .shade400,
                                          ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed:
                                                  _isCheckingOut
                                                      ? null
                                                      : () {
                                                          decreaseQuantity(
                                                            item,
                                                          );
                                                        },
                                              icon:
                                                  const Icon(
                                                Icons.remove,
                                                size: 18,
                                              ),
                                              constraints:
                                                  const BoxConstraints(
                                                minWidth: 35,
                                                minHeight: 35,
                                              ),
                                            ),

                                            SizedBox(
                                              width: 30,
                                              child: Text(
                                                '${item.quantity}',
                                                textAlign:
                                                    TextAlign
                                                        .center,
                                                style:
                                                    const TextStyle(
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                              ),
                                            ),

                                            IconButton(
                                              onPressed:
                                                  _isCheckingOut
                                                      ? null
                                                      : () {
                                                          increaseQuantity(
                                                            item,
                                                          );
                                                        },
                                              icon:
                                                  const Icon(
                                                Icons.add,
                                                size: 18,
                                              ),
                                              constraints:
                                                  const BoxConstraints(
                                                minWidth: 35,
                                                minHeight: 35,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      // ITEM TOTAL

                                      Text(
                                        '${item.totalPrice.toStringAsFixed(2)} EGP',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // DELETE

                            IconButton(
                              onPressed: _isCheckingOut
                                  ? null
                                  : () {
                                      removeItem(item);
                                    },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // CHECKOUT SECTION

        if (items.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // SUBTOTAL

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${CartManager.total.toStringAsFixed(2)} EGP',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // TOTAL

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${CartManager.total.toStringAsFixed(2)} EGP',
                      style: const TextStyle(
                        fontSize: 21,
                        color: Color.fromARGB(
                          255,
                          76,
                          92,
                          175,
                        ),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // PLACE ORDER BUTTON

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isCheckingOut ? null : checkout,
                    icon: _isCheckingOut
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.shopping_bag_outlined,
                          ),
                    label: Text(
                      _isCheckingOut
                          ? 'Placing Order...'
                          : 'Place Order',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}