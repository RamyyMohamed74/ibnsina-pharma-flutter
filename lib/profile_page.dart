import 'package:flutter/material.dart';
import 'orders_page.dart';

class ProfilePage extends StatelessWidget {
  final String name;

  const ProfilePage({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          // PROFILE INFORMATION

          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text('Pharmacy Customer'),
          ),

          const Divider(),

          const SizedBox(height: 5),

          // MY ORDERS

          ListTile(
            leading: const Icon(
              Icons.receipt_long,
            ),
            title: const Text(
              'My Orders',
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const OrdersPage(),
                ),
              );
            },
          ),

          // MY ADDRESSES

          ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
            ),
            title: const Text(
              'My Addresses',
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {},
          ),

          // SETTINGS

          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
            ),
            title: const Text(
              'Settings',
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

