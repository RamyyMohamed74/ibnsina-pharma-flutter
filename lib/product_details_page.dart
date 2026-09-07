import 'package:flutter/material.dart';
import 'cart_manager.dart';
import 'api_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;
  final String name;
  final String price;
  final String image;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    required this.image,
    required this.name,
    required this.price,
  });

  @override
  State<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;

  Map<String, dynamic>? product;

  bool isLoading = true;
  String? errorMessage;

  // LOAD PRODUCT

  @override
  void initState() {
    super.initState();

    loadProduct();
  }

  Future<void> loadProduct() async {
    try {
      final result =
          await ApiService.getProductById(widget.productId);

      if (!mounted) return;

      setState(() {
        product = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // INCREASE QUANTITY

  void increaseQuantity() {
    final stock =
        product?['stockQuantity'] ?? 0;

    if (quantity < stock) {
      setState(() {
        quantity++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only $stock items available in stock',
          ),
        ),
      );
    }
  }

  // DECREASE QUANTITY

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  // ADD TO CART

  void addToCart() {
    if (product == null) {
      return;
    }

    final stock =
        product!['stockQuantity'] ?? 0;

    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This product is out of stock',
          ),
        ),
      );

      return;
    }

    final success = CartManager.addItem(
      productId: widget.productId,
      image: widget.image,
      name: product!['name'] ?? widget.name,
      price: '${product!['price'] ?? 0} EGP',
      stockQuantity: stock,
      quantity: quantity,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only $stock items available in stock',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$quantity x ${product!['name'] ?? widget.name} added to cart',
        ),
      ),
    );
  }

  // FORMAT EXPIRY DATE

  String formatExpiryDate(dynamic date) {
    if (date == null) {
      return 'Unknown';
    }

    try {
      final parsedDate =
          DateTime.parse(date.toString());

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (e) {
      return date.toString();
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),

      // LOADING

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          // ERROR

          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'Failed to load product',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          errorMessage!,
                          textAlign:
                              TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            loadProduct();
                          },
                          child:
                              const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )

              // PRODUCT DETAILS

              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // PRODUCT IMAGE

                      Container(
                        height: 280,
                        width: double.infinity,

                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        child: Image.network(
                          product!['imageUrl'] ?? '',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/ibnsina-pharma-logo.png',
                               fit: BoxFit.contain,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 25),

                      // PRODUCT NAME

                      Text(
                        product!['name'] ?? widget.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // PRICE

                      Text(
                        '${product!['price'] ?? 0} EGP',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color.fromARGB(
                            255,
                            76,
                            92,
                            175,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // DESCRIPTION

                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        (product!['description'] ??
                                'No description available.')
                            .toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // CATEGORY

                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        product!['categoryName'] ??
                            'Unknown Category',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // STOCK

                      const Text(
                        'Availability',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        (product!['stockQuantity'] ?? 0) > 0
                            ? '${product!['stockQuantity']} items available'
                            : 'Out of stock',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              (product!['stockQuantity'] ?? 0) > 0
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // EXPIRY DATE

                      const Text(
                        'Expiry Date',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        formatExpiryDate(
                          product!['expiryDate'],
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // QUANTITY

                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade400,
                              ),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed:
                                      decreaseQuantity,
                                  icon: const Icon(
                                    Icons.remove,
                                  ),
                                ),

                                Container(
                                  width: 40,
                                  alignment:
                                      Alignment.center,
                                  child: Text(
                                    '$quantity',
                                    style:
                                        const TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                IconButton(
                                  onPressed:
                                      increaseQuantity,
                                  icon: const Icon(
                                    Icons.add,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 15),

                          Text(
                            'Max: ${product!['stockQuantity'] ?? 0}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ADD TO CART

                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton.icon(
                          onPressed:
                              (product!['stockQuantity'] ?? 0) > 0
                                  ? addToCart
                                  : null,

                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                          ),

                          label: Text(
                            (product!['stockQuantity'] ?? 0) > 0
                                ? 'Add to Cart'
                                : 'Out of Stock',
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
    );
  }
}