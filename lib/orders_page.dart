import 'package:flutter/material.dart';
import 'api_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];

  bool isLoading = true;
  String? errorMessage;

  // ============================================================
  // LOAD ORDERS
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadOrders();
  }

  Future<void> loadOrders() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await ApiService.getOrders();

      if (!mounted) return;

      setState(() {
        orders = result;
        isLoading = false;
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

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(dynamic date) {
    if (date == null) {
      return 'Unknown date';
    }

    try {
      final parsedDate =
          DateTime.parse(date.toString()).toLocal();

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return date.toString();
    }
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String formatTime(dynamic date) {
    if (date == null) {
      return '';
    }

    try {
      final parsedDate =
          DateTime.parse(date.toString()).toLocal();

      final hour = parsedDate.hour;
      final minute =
          parsedDate.minute.toString().padLeft(2, '0');

      final period = hour >= 12 ? 'PM' : 'AM';

      final displayHour =
          hour % 12 == 0 ? 12 : hour % 12;

      return '$displayHour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  // ============================================================
  // GET ITEM COUNT
  // ============================================================

  int getItemCount(dynamic order) {
    final items = order['items'];

    if (items is! List) {
      return 0;
    }

    int count = 0;

    for (final item in items) {
      count +=
          int.tryParse(
                item['quantity']?.toString() ?? '0',
              ) ??
              0;
    }

    return count;
  }

  // ============================================================
  // BUILD ORDER CARD
  // ============================================================

  Widget buildOrderCard(
    BuildContext context,
    dynamic order,
  ) {
    final orderId = order['id'] ?? 0;

    final totalAmount =
        double.tryParse(
              order['totalAmount']?.toString() ?? '0',
            ) ??
            0;

    final orderDate = order['orderDate'];

    final itemCount = getItemCount(order);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // ORDER NUMBER
            // --------------------------------------------------

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                        Text(
                          '#$orderId',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // DATE
            // --------------------------------------------------

            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 19,
                  color: Colors.grey,
                ),

                const SizedBox(width: 10),

                Text(
                  formatDate(orderDate),
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(width: 20),

                const Icon(
                  Icons.access_time_outlined,
                  size: 19,
                  color: Colors.grey,
                ),

                const SizedBox(width: 8),

                Text(
                  formatTime(orderDate),
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // ITEMS
            // --------------------------------------------------

            Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: Colors.grey,
                ),

                const SizedBox(width: 10),

                Text(
                  '$itemCount '
                  '${itemCount == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // --------------------------------------------------
            // TOTAL
            // --------------------------------------------------

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  '${totalAmount.toStringAsFixed(2)} EGP',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // --------------------------------------------------
            // VIEW DETAILS BUTTON
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Order details coming next!',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'View Order Details',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),

      body: RefreshIndicator(
        onRefresh: loadOrders,

        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )

            // --------------------------------------------------
            // ERROR
            // --------------------------------------------------

            : errorMessage != null
                ? ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.of(context)
                                    .size
                                    .height *
                                0.3,
                      ),

                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      const Center(
                        child: Text(
                          'Failed to load orders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: loadOrders,
                          child:
                              const Text('Retry'),
                        ),
                      ),
                    ],
                  )

                // --------------------------------------------------
                // EMPTY ORDERS
                // --------------------------------------------------

                : orders.isEmpty
                    ? ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height:
                                MediaQuery.of(context)
                                        .size
                                        .height *
                                    0.25,
                          ),

                          Icon(
                            Icons.receipt_long_outlined,
                            size: 90,
                            color: Colors.grey.shade400,
                          ),

                          const SizedBox(height: 20),

                          const Center(
                            child: Text(
                              'No orders yet',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Text(
                                'Your completed orders '
                                'will appear here.',
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )

                    // --------------------------------------------------
                    // ORDERS LIST
                    // --------------------------------------------------

                    : ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder:
                            (context, index) {
                          return buildOrderCard(
                            context,
                            orders[index],
                          );
                        },
                      ),
      ),
    );
  }
}

