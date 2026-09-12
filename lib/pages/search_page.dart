import 'package:flutter/material.dart';
import 'product_details_page.dart';
import '../api_service.dart';

class SearchPage extends StatefulWidget {
  final int? initialCategoryId;
  final String? initialCategoryName;

  const SearchPage({
    super.key,
    this.initialCategoryId,
    this.initialCategoryName,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  // PRODUCTS FROM API

  List<dynamic> products = [];

  bool _isLoading = true;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();

    _loadProducts();
  }

  // LOAD PRODUCTS

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
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                );
      });
    }
  }

  // FILTER PRODUCTS

  List<dynamic> get filteredProducts {
    return products.where((product) {
      final productMap =
          Map<String, dynamic>.from(product);

      // CATEGORY FILTER

      bool matchesCategory = true;

      if (widget.initialCategoryId != null) {
        final productCategoryId =
            productMap['categoryId'];

        matchesCategory =
            productCategoryId != null &&
            int.tryParse(
                  productCategoryId.toString(),
                ) ==
                widget.initialCategoryId;
      }

      // TEXT SEARCH

      bool matchesSearch = true;

      if (_searchText.trim().isNotEmpty) {
        final name =
            (productMap['name'] ?? '')
                .toString()
                .toLowerCase();

        final description =
            (productMap['description'] ?? '')
                .toString()
                .toLowerCase();

        final search =
            _searchText.toLowerCase().trim();

        matchesSearch =
            name.contains(search) ||
            description.contains(search);
      }

      // PRODUCT MUST MATCH BOTH FILTERS

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // PRODUCT CARD

  Widget _buildProductCard(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    final int productId =
        product['id'] ?? 0;

    final String productName =
        product['name'] ?? 'Unknown Product';

    final String productPrice =
        '${product['price'] ?? 0} EGP';

    final String? imageUrl =
        product['imageUrl'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailsPage(
              productId: productId,
              image: imageUrl != null &&
                      imageUrl.trim().isNotEmpty
                  ? imageUrl
                  : 'assets/images/ibnsina-pharma-logo.png',
              name: productName,
              price: productPrice,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(
          bottom: 15,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // IMAGE

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
                child: imageUrl != null &&
                        imageUrl.trim().isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context,
                                error,
                                stackTrace) {
                          return Image.asset(
                            'assets/images/ibnsina-pharma-logo.png',
                            fit: BoxFit.contain,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/ibnsina-pharma-logo.png',
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
                      productName,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      productPrice,
                      style:
                          const TextStyle(
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

                    const SizedBox(height: 5),

                    // STOCK

                    Text(
                      'Stock: ${product['stockQuantity'] ?? 0}',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey.shade600,
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

 
  @override
  Widget build(BuildContext context) {
    final results = filteredProducts;

    final bool isCategorySearch =
        widget.initialCategoryId != null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // TITLE

          Text(
            isCategorySearch &&
                    widget.initialCategoryName != null
                ? widget.initialCategoryName!
                : 'Search Products',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // SEARCH BAR

          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: isCategorySearch
                  ? 'Search in this category...'
                  : 'Search medicines...',
              prefixIcon:
                  const Icon(Icons.search),
              suffixIcon:
                  _searchText.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController
                                .clear();

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

          // RESULTS TITLE

          Text(
            isCategorySearch
                ? 'Products in ${widget.initialCategoryName}'
                : _searchText.isEmpty
                    ? 'All Products'
                    : 'Search Results',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // PRODUCT LIST

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
                              MainAxisAlignment
                                  .center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.red,
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            const Text(
                              'Failed to load products',
                              style:
                                  TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              _errorMessage!,
                              textAlign:
                                  TextAlign.center,
                              style:
                                  const TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            ElevatedButton(
                              onPressed:
                                  _loadProducts,
                              child:
                                  const Text(
                                'Retry',
                              ),
                            ),
                          ],
                        ),
                      )
                    : results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color:
                                      Colors.grey,
                                ),

                                const SizedBox(
                                  height: 15,
                                ),

                                const Text(
                                  'No products found',
                                  style:
                                      TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                Text(
                                  isCategorySearch
                                      ? 'No products in this category'
                                      : 'Try another search',
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.grey,
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
                                Map<String,
                                    dynamic>.from(
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
