import 'package:flutter/material.dart';
import '../api_service.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic>? order;

  bool isLoading = true;
  String? errorMessage;

  final Map<int, Map<String, dynamic>> productCache = {};

  @override
  void initState() {
    super.initState();
    loadOrderDetails();
  }

  // LOAD ORDER DETAILS
  Future<void> loadOrderDetails() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await ApiService.getOrderById(widget.orderId);

      if (!mounted) return;

      setState(() {
        order = result;
        isLoading = false;
      });

      await loadProductDetails();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  // LOAD PRODUCT DETAILS USING PRODUCT ID
  Future<void> loadProductDetails() async {
    final items = getOrderItems();

    for (final item in items) {
      final productId = int.tryParse(
        item['productId']?.toString() ?? '',
      );

      if (productId == null) {
        continue;
      }

      if (productCache.containsKey(productId)) {
        continue;
      }

      try {
        final product = await ApiService.getProductById(productId);

        productCache[productId] = product;
      } catch (_) {
        // Keep the order information even if
        // the product request fails.
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  // FORMAT DATE
  String formatDate(dynamic date) {
    if (date == null) {
      return 'Unknown date';
    }

    try {
      final parsedDate = DateTime.parse(
        date.toString(),
      ).toLocal();

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return date.toString();
    }
  }

  // FORMAT TIME
  String formatTime(dynamic date) {
    if (date == null) {
      return '';
    }

    try {
      final parsedDate = DateTime.parse(
        date.toString(),
      ).toLocal();

      final hour = parsedDate.hour;

      final minute = parsedDate.minute.toString().padLeft(
            2,
            '0',
          );

      final period = hour >= 12 ? 'PM' : 'AM';

      final displayHour = hour % 12 == 0 ? 12 : hour % 12;

      return '$displayHour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  // GET ORDER ITEMS
  List<dynamic> getOrderItems() {
    if (order == null) {
      return [];
    }

    final items = order!['items'];

    if (items is List) {
      return items;
    }

    return [];
  }

  // GET PRODUCT FROM CACHE
  Map<String, dynamic>? getProduct(dynamic item) {
    final productId = int.tryParse(
      item['productId']?.toString() ?? '',
    );

    if (productId == null) {
      return null;
    }

    return productCache[productId];
  }

  // GET PRODUCT NAME
  String getProductName(dynamic item) {
    return item['productName']?.toString() ?? 'Product';
  }

  // GET PRODUCT IMAGE
  String? getProductImage(dynamic item) {
    final product = getProduct(item);

    final imageUrl = product?['imageUrl'];

    if (imageUrl == null) {
      return null;
    }

    final image = imageUrl.toString();

    if (image.isEmpty) {
      return null;
    }

    return image;
  }

  // GET UNIT PRICE
  double getItemPrice(dynamic item) {
    return double.tryParse(
          item['unitPrice']?.toString() ?? '0',
        ) ??
        0;
  }

  // GET QUANTITY
  int getItemQuantity(dynamic item) {
    return int.tryParse(
          item['quantity']?.toString() ?? '0',
        ) ??
        0;
  }

  // GET SUBTOTAL
  double getItemSubtotal(dynamic item) {
    return double.tryParse(
          item['subtotal']?.toString() ?? '0',
        ) ??
        0;
  }

  // BUILD PRODUCT IMAGE
  Widget buildProductImage(dynamic item) {
    final imageUrl = getProductImage(item);

    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: imageUrl != null &&
              imageUrl.isNotEmpty &&
              imageUrl.startsWith('http')
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 35,
                  );
                },
              ),
            )
          : const Icon(
              Icons.image_not_supported,
              size: 35,
            ),
    );
  }

  // BUILD PRODUCT CARD
  Widget buildProductCard(dynamic item) {
    final name = getProductName(item);
    final price = getItemPrice(item);
    final quantity = getItemQuantity(item);
    final subtotal = getItemSubtotal(item);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // PRODUCT IMAGE
            buildProductImage(item),

            const SizedBox(width: 15),

            // PRODUCT INFORMATION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    '${price.toStringAsFixed(2)} EGP',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Quantity: $quantity',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ITEM TOTAL
            Text(
              '${subtotal.toStringAsFixed(2)} EGP',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${widget.orderId}',
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'Failed to load order',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: loadOrderDetails,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : order == null
                  ? const Center(
                      child: Text(
                        'Order not found',
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadOrderDetails,
                      child: ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        children: [
                          // ORDER HEADER
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.08),
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 55,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  'Order #${order!['id']}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green
                                        .withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ORDER INFORMATION
                          const Text(
                            'Order Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  // DATE
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        color: Colors.grey,
                                      ),

                                      const SizedBox(width: 12),

                                      const Expanded(
                                        child: Text(
                                          'Date',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      Text(
                                        formatDate(
                                          order!['orderDate'],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 15),

                                  // TIME
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_outlined,
                                        color: Colors.grey,
                                      ),

                                      const SizedBox(width: 12),

                                      const Expanded(
                                        child: Text(
                                          'Time',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      Text(
                                        formatTime(
                                          order!['orderDate'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // ORDER ITEMS
                          Text(
                            'Products (${getOrderItems().length})',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          ...getOrderItems().map(
                            (item) => buildProductCard(item),
                          ),

                          const SizedBox(height: 15),

                          // ORDER SUMMARY
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  // ITEMS
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Items',
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),

                                      Text(
                                        '${getOrderItems().fold<int>(
                                          0,
                                          (sum, item) =>
                                              sum +
                                              getItemQuantity(item),
                                        )}',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  const Divider(),

                                  const SizedBox(height: 12),

                                  // TOTAL
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Text(
                                        '${double.tryParse(
                                              order!['totalAmount']
                                                      ?.toString() ??
                                                  '0',
                                            )?.toStringAsFixed(2) ?? '0.00'} EGP',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }
}
