import 'package:flutter/material.dart';

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

          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('My Orders'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('My Addresses'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}