import 'package:flutter/material.dart';
import 'cart_manager.dart';
import 'cart_item.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  void removeItem(CartItem item) {
    setState(() {
      CartManager.removeItem(item);
    });
  }

  @override
  Widget build(BuildContext context) {

    final items = CartManager.items;

    return Column(
      children: [

        // =================================
        // CART CONTENT
        // =================================

        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )

              : ListView.builder(
                  padding:
                      const EdgeInsets.all(20),

                  itemCount: items.length,

                  itemBuilder:
                      (context, index) {

                    final item = items[index];

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 15,
                      ),

                      child: Padding(
                        padding:
                            const EdgeInsets.all(12),

                        child: Row(
                          children: [

                            // PRODUCT IMAGE
                            Container(
                              width: 80,
                              height: 80,

                              decoration:
                                  BoxDecoration(
                                color: Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .surfaceContainerHighest,

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            12),
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
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(
                                    item.name,

                                    style:
                                        const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 5),

                                  Text(
                                    item.price,

                                    style:
                                        const TextStyle(
                                      color:
                                          Color.fromARGB(
                                        255,
                                        76,
                                        92,
                                        175,
                                      ),
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 5),

                                  Text(
                                    'Quantity: ${item.quantity}',
                                  ),
                                ],
                              ),
                            ),

                            // DELETE BUTTON
                            IconButton(
                              onPressed: () {
                                removeItem(item);
                              },

                              icon: const Icon(
                                Icons.delete_outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // =================================
        // TOTAL
        // =================================

        if (items.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.all(20),

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

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text(
                      'Total',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      '${CartManager.total.toStringAsFixed(2)} EGP',

                      style: const TextStyle(
                        fontSize: 20,
                        color:
                            Color.fromARGB(
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

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Checkout coming soon!',
                          ),
                        ),
                      );
                    },

                    child: const Text(
                      'Checkout',

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