import 'package:flutter/material.dart';
import 'product_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  // =================================
  // PRODUCTS
  // =================================

  final List<Map<String, String>> products = [
    {
      'name': 'Paracetamol',
      'price': '50 EGP',
      'image': 'assets/images/ibnsina-pharma-logo.png',
    },
    {
      'name': 'Vitamin C',
      'price': '120 EGP',
      'image': 'assets/images/ibnsina-pharma-logo.png',
    },
    {
      'name': 'Skin Care',
      'price': '200 EGP',
      'image': 'assets/images/ibnsina-pharma-logo.png',
    },
    {
      'name': 'Panadol',
      'price': '75 EGP',
      'image': 'assets/images/ibnsina-pharma-logo.png',
    },
    {
      'name': 'Omega 3',
      'price': '250 EGP',
      'image': 'assets/images/ibnsina-pharma-logo.png',
    },
  ];

  // =================================
  // FILTER PRODUCTS
  // =================================

  List<Map<String, String>> get filteredProducts {
    if (_searchText.isEmpty) {
      return products;
    }

    return products.where((product) {
      final name = product['name']!.toLowerCase();

      return name.contains(
        _searchText.toLowerCase(),
      );
    }).toList();
  }

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
    Map<String, String> product,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              image: product['image']!,
              name: product['name']!,
              price: product['price']!,
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
                  product['image']!,
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
                      product['name']!,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      product['price']!,

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
          // RESULTS
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
            child: results.isEmpty
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
                    itemCount: results.length,

                    itemBuilder:
                        (context, index) {
                      return _buildProductCard(
                        context,
                        results[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}