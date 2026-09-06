import 'package:flutter/material.dart';
import 'cart_manager.dart';

class ProductDetailsPage extends StatefulWidget {
  final String image;
  final String name;
  final String price;

  const ProductDetailsPage({
    super.key,
    required this.image,
    required this.name,
    required this.price,
  });

  @override
  State<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState
    extends State<ProductDetailsPage> {

  int quantity = 1;

  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void addToCart() {
    CartManager.addItem(
      image: widget.image,
      name: widget.name,
      price: widget.price,
      quantity: quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$quantity x ${widget.name} added to cart',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =================================
            // PRODUCT IMAGE
            // =================================

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

              child: Image.asset(
                widget.image,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 25),

            // =================================
            // PRODUCT NAME
            // =================================

            Text(
              widget.name,

              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // =================================
            // PRICE
            // =================================

            Text(
              widget.price,

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

            // =================================
            // DESCRIPTION
            // =================================

            const Text(
              'Description',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'This is a high-quality pharmacy product. '
              'Please follow the instructions and recommended '
              'dosage when using this product.',

              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // =================================
            // QUANTITY
            // =================================

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

                IconButton(
                  onPressed: decreaseQuantity,
                  icon: const Icon(
                    Icons.remove,
                  ),
                ),

                Container(
                  width: 50,

                  alignment:
                      Alignment.center,

                  child: Text(
                    '$quantity',

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: increaseQuantity,
                  icon: const Icon(
                    Icons.add,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // =================================
            // ADD TO CART
            // =================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(

                onPressed: addToCart,

                icon: const Icon(
                  Icons.shopping_cart_outlined,
                ),

                label: const Text(
                  'Add to Cart',

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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