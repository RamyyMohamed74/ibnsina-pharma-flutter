import 'package:flutter/material.dart';
import 'search_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'product_details_page.dart';
import 'api_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String name;

  // Dark mode
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.name,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late bool _isDarkMode;

  // PRODUCTS
  List<dynamic> _products = [];

  bool _isLoadingProducts = true;
  String? _productsError;

  // CATEGORIES
  List<dynamic> _categories = [];

  bool _isLoadingCategories = true;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();

    _isDarkMode = widget.isDarkMode;

    _loadProducts();
    _loadCategories();
  }

  // LOAD PRODUCTS

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

  // LOAD CATEGORIES

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        _categoriesError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingCategories = false;
        _categoriesError = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  // LOGOUT

  Future<void> _logout() async {
    await ApiService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          onToggleTheme: widget.onToggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
      (route) => false,
    );
  }

  // BOTTOM NAVIGATION

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ORDER COMPLETED
  //
  // This is called by CartPage after a successful order.
  // It changes the selected tab back to Home.

  void _onOrderCompleted() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  // SELECTED PAGE

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 1:
        return const SearchPage();

      case 2:
        return CartPage(
          onOrderCompleted: _onOrderCompleted,
        );

      case 3:
        return ProfilePage(
          name: widget.name,
          onLogout: _logout,
        );

      default:
        return _buildHomePage();
    }
  }

  // HOME PAGE

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

          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
            child: AbsorbPointer(
              child: TextField(
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

          _buildCategoriesSection(),

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

  // CATEGORIES SECTION

  Widget _buildCategoriesSection() {
    if (_isLoadingCategories) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_categoriesError != null) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 35,
              ),
              const SizedBox(height: 8),
              Text(
                _categoriesError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoadingCategories = true;
                    _categoriesError = null;
                  });

                  _loadCategories();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No categories available',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final category =
              Map<String, dynamic>.from(_categories[index]);

          final int categoryId = category['id'] ?? 0;

          final String categoryName =
              category['name'] ?? 'Unknown Category';

          return _buildCategoryCard(
            context,
            categoryId: categoryId,
            title: categoryName,
          );
        },
      ),
    );
  }

  // CATEGORY CARD WITH HOVER ANIMATION

  Widget _buildCategoryCard(
    BuildContext context, {
    required int categoryId,
    required String title,
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setHoverState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            setHoverState(() {
              isHovered = true;
            });
          },
          onExit: (_) {
            setHoverState(() {
              isHovered = false;
            });
          },
          child: AnimatedScale(
            scale: isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                0,
                isHovered ? -4 : 0,
                0,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text(title),
                        ),
                        body: SearchPage(
                          initialCategoryId: categoryId,
                          initialCategoryName: title,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 125,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: isHovered
                        ? [
                            BoxShadow(
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 5),
                              color:
                                  Colors.black.withOpacity(0.15),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCategoryIcon(title),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // CATEGORY ICON

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('medicine') ||
        name.contains('drug') ||
        name.contains('anti-biotic')) {
      return Icons.medication_outlined;
    }

    if (name.contains('vitamin') ||
        name.contains('supplement')) {
      return Icons.health_and_safety_outlined;
    }

    if (name.contains('personal') ||
        name.contains('care') ||
        name.contains('beauty')) {
      return Icons.spa_outlined;
    }

    if (name.contains('tooth') ||
        name.contains('child')) {
      return Icons.brush_outlined;
    }

    if (name.contains('skin') ||
        name.contains('derma')) {
      return Icons.face_retouching_natural;
    }

    if (name.contains('first aid')) {
      return Icons.medical_services_outlined;
    }

    return Icons.local_pharmacy_outlined;
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

  // PRODUCT CARD WITH HOVER ANIMATION

  Widget _buildProductCard(
    BuildContext context, {
    required int id,
    required String? imageUrl,
    required String name,
    required String price,
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setHoverState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            setHoverState(() {
              isHovered = true;
            });
          },
          onExit: (_) {
            setHoverState(() {
              isHovered = false;
            });
          },
          child: AnimatedScale(
            scale: isHovered ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                0,
                isHovered ? -5 : 0,
                0,
              ),
              child: GestureDetector(
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
                    boxShadow: isHovered
                        ? [
                            BoxShadow(
                              blurRadius: 14,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                              color:
                                  Colors.black.withOpacity(0.15),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
              ),
            ),
          ),
        );
      },
    );
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APP BAR

      appBar: AppBar(
        title: const Text('Ibn Sina Pharma'),
        actions: [
          // DARK / LIGHT MODE

          IconButton(
            onPressed: () {
              widget.onToggleTheme();

              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
            icon: Icon(
              _isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: _isDarkMode
                ? 'Light mode'
                : 'Dark mode',
          ),

          // CART

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
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.search_outlined,
            ),
            selectedIcon: Icon(
              Icons.search,
            ),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.shopping_cart_outlined,
            ),
            selectedIcon: Icon(
              Icons.shopping_cart,
            ),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}