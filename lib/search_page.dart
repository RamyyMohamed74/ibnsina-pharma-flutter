import 'package:flutter/material.dart';
import 'product_details_page.dart';
import 'api_service.dart';

class SearchPage extends StatefulWidget {
  final String? initialCategory;

  const SearchPage({
    super.key,
    this.initialCategory,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  // =================================
  // PRODUCTS FROM API
  // =================================

  List<dynamic> products = [];

  bool _isLoading = true;
  String? _errorMessage;

  // =================================
  // LOAD PRODUCTS
  // =================================

  @override
  void initState() {
    super.initState();

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final result = await ApiService.getProducts();

      if (!mounted) return;

      setState(() {
        products = result;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // =================================
  // FILTER PRODUCTS
  // =================================

  List<dynamic> get filteredProducts {
    if (_searchText.trim().isEmpty) {
      return products;
    }

    return products.where((product) {
      final name =
          (product['name'] ?? '').toString().toLowerCase();

      final description =
          (product['description'] ?? '').toString().toLowerCase();

      final search =
          _searchText.toLowerCase().trim();

      return name.contains(search) ||
          description.contains(search);
    }).toList();
  }

  // =================================
  // DISPOSE
  // =================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =================================
  // PRODUCT CARD
  // =================================

  Widget _buildProductCard(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    final int productId = product['id'] ?? 0;

    final String productName =
        product['name'] ?? 'Unknown Product';

    final String productPrice =
        '${product['price'] ?? 0} EGP';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productId: productId,
              image:
                  'assets/images/ibnsina-pharma-logo.png',
              name: productName,
              price: productPrice,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // =================================
              // IMAGE
              // =================================

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/ibnsina-pharma-logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 15),

              // =================================
              // PRODUCT INFO
              // =================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      productPrice,
                      style: const TextStyle(
                        fontSize: 16,
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

                    // =================================
                    // STOCK
                    // =================================

                    const SizedBox(height: 5),

                    Text(
                      'Stock: ${product['stockQuantity'] ?? 0}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =================================
  // BUILD
  // =================================

  @override
  Widget build(BuildContext context) {
    final results = filteredProducts;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =================================
          // TITLE
          // =================================

          const Text(
            'Search Products',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // =================================
          // SEARCH BAR
          // =================================

          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search medicines...',
              prefixIcon:
                  const Icon(Icons.search),
              suffixIcon:
                  _searchText.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();

                            setState(() {
                              _searchText = '';
                            });
                          },
                          icon: const Icon(
                            Icons.clear,
                          ),
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // =================================
          // RESULTS TITLE
          // =================================

          Text(
            _searchText.isEmpty
                ? 'All Products'
                : 'Search Results',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // =================================
          // PRODUCT LIST
          // =================================

          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : _errorMessage != null
                    ? Center(
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
                              'Failed to load products',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              _errorMessage!,
                              textAlign:
                                  TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 15),

                            ElevatedButton(
                              onPressed:
                                  _loadProducts,
                              child:
                                  const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : results.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: Colors.grey,
                                ),

                                SizedBox(height: 15),

                                Text(
                                  'No products found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  'Try another search',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount:
                                results.length,
                            itemBuilder:
                                (context, index) {
                              return _buildProductCard(
                                context,
                                Map<String, dynamic>.from(
                                  results[index],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}