import 'package:flutter/material.dart';
import 'search_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'product_details_page.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  final String name;

  const HomePage({
    super.key,
    required this.name,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<dynamic> _products = [];

  bool _isLoadingProducts = true;
  String? _productsError;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // LOAD PRODUCTS FROM API

  Future<void> _loadProducts() async {
    try {
      final products = await ApiService.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoadingProducts = false;
        _productsError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingProducts = false;
        _productsError = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // SELECTED PAGE

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 1:
        return const SearchPage();

      case 2:
        return const CartPage();

      case 3:
        return ProfilePage(
          name: widget.name,
        );

      default:
        return _buildHomePage();
    }
  }

  // HOME PAGE CONTENT

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // WELCOME

          Text(
            'Welcome, ${widget.name} 👋',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'What are you looking for today?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 24),

          // SEARCH BAR

          TextField(
            decoration: InputDecoration(
              hintText: 'Search medicines...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // CATEGORIES

          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  context,
                  icon: Icons.medication_outlined,
                  title: 'Medicine',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildCategoryCard(
                  context,
                  icon: Icons.local_pharmacy_outlined,
                  title: 'Vitamins',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildCategoryCard(
                  context,
                  icon: Icons.spa_outlined,
                  title: 'Personal Care',
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // FEATURED PRODUCTS

          const Text(
            'Featured Products',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          _buildProductsSection(),
        ],
      ),
    );
  }

  // PRODUCTS SECTION

  Widget _buildProductsSection() {
    if (_isLoadingProducts) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_productsError != null) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
              ),

              const SizedBox(height: 10),

              Text(
                _productsError!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoadingProducts = true;
                    _productsError = null;
                  });

                  _loadProducts();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No products available',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 15);
        },
        itemBuilder: (context, index) {
          final product =
              Map<String, dynamic>.from(_products[index]);

          return _buildProductCard(
            context,
            id: product['id'] ?? 0,
            imageUrl: product['imageUrl'],
            name: product['name'] ?? 'Unknown Product',
            price: '${product['price'] ?? 0} EGP',
          );
        },
      ),
    );
  }

  // CATEGORY CARD

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        setState(() {
          _selectedIndex = 1;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Search Products'),
              ),
              body: SearchPage(
                initialCategory: title,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color.fromARGB(
                255,
                76,
                92,
                175,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PRODUCT CARD

  Widget _buildProductCard(
    BuildContext context, {
    required int id,
    required String? imageUrl,
    required String name,
    required String price,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productId: id,
              image: imageUrl ??
                  'assets/images/ibnsina-pharma-logo.png',
              name: name,
              price: price,
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imageUrl != null &&
                      imageUrl.trim().isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/ibnsina-pharma-logo.png',
                          width: double.infinity,
                          fit: BoxFit.contain,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/ibnsina-pharma-logo.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
            ),

            const SizedBox(height: 8),

            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              price,
              style: const TextStyle(
                fontSize: 15,
                color: Color.fromARGB(
                  255,
                  76,
                  92,
                  175,
                ),
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
      // APP BAR

      appBar: AppBar(
        title: const Text('Ibn Sina Pharma'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
            icon: const Icon(
              Icons.shopping_cart_outlined,
            ),
            tooltip: 'Cart',
          ),
        ],
      ),

      // BODY

      body: _buildSelectedPage(),

      // BOTTOM NAVIGATION

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onBottomNavTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}