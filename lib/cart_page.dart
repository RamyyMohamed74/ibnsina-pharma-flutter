import 'package:flutter/material.dart';
import 'cart_manager.dart';
import 'cart_item.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  // REMOVE ITEM

  void removeItem(CartItem item) {
    setState(() {
      CartManager.removeItem(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.name} removed from cart',
        ),
      ),
    );
  }

  // INCREASE QUANTITY

  void increaseQuantity(CartItem item) {
    final success = CartManager.increaseQuantity(item);
    setState(() {});

    if(!success){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only ${item.stockQuantity} items available in stock',
          ),
        ),
      );
    }
  }

  // DECREASE QUANTITY

  void decreaseQuantity(CartItem item) {
    setState(() {
      CartManager.decreaseQuantity(item);
    });
  }

  // CHECKOUT

  void checkout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Checkout will be connected to the Order API next!',
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    final items = CartManager.items;

    return Column(
      children: [

        // CART CONTENT

        Expanded(
          child: items.isEmpty

              // EMPTY CART

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

              // PRODUCTS

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

                              child: Image.asset(
                                item.image,
                                fit: BoxFit.contain,
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

                                    style:
                                        const TextStyle(
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
                                              onPressed: () {
                                                decreaseQuantity(
                                                  item,
                                                );
                                              },

                                              icon: const Icon(
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
                                              onPressed: () {
                                                increaseQuantity(
                                                  item,
                                                );
                                              },

                                              icon: const Icon(
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
                              onPressed: () {
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

                // CHECKOUT BUTTON

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: checkout,

                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                    ),

                    label: const Text(
                      'Place Order',

                      style: TextStyle(
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