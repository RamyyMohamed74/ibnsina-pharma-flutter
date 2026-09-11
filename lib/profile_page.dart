import 'package:flutter/material.dart';
import 'orders_page.dart';
import 'my_addresses_page.dart';
import 'edit_profile_page.dart';
import 'api_service.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.name,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profile;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // LOAD PROFILE

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await ApiService.getMyProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
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

  // OPEN EDIT PROFILE

  Future<void> _openEditProfile() async {
    if (_profile == null) return;

    final updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          profile: _profile!,
        ),
      ),
    );

    if (!mounted) return;

    if (updatedProfile != null &&
        updatedProfile is Map<String, dynamic>) {
      setState(() {
        _profile = updatedProfile;
      });
    } else {
      await _loadProfile();
    }
  }

  // GET PROFILE NAME

  String _getName() {
    if (_profile != null &&
        _profile!['fullName'] != null &&
        _profile!['fullName']
            .toString()
            .trim()
            .isNotEmpty) {
      return _profile!['fullName'].toString();
    }

    return widget.name;
  }

  // GET PROFILE IMAGE

  String? _getProfileImageUrl() {
    if (_profile != null &&
        _profile!['profileImageUrl'] != null &&
        _profile!['profileImageUrl']
            .toString()
            .trim()
            .isNotEmpty) {
      return _profile!['profileImageUrl'].toString();
    }

    return null;
  }

  // PROFILE HEADER

  Widget _buildProfileHeader() {
    final name = _getName();
    final imageUrl = _getProfileImageUrl();

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // PROFILE IMAGE
            CircleAvatar(
              radius: 35,
              backgroundImage:
                  imageUrl != null
                      ? NetworkImage(imageUrl)
                      : null,
              child: imageUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 38,
                    )
                  : null,
            ),

            const SizedBox(width: 15),

            // NAME + CUSTOMER
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pharmacy Customer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color,
                    ),
                  ),
                ],
              ),
            ),

            // EDIT BUTTON
            IconButton(
              onPressed:
                  _profile == null
                      ? null
                      : _openEditProfile,
              icon: const Icon(
                Icons.edit_outlined,
              ),
              tooltip: 'Edit Profile',
            ),
          ],
        ),
      ),
    );
  }

  // PROFILE CONTENT

  Widget _buildProfileContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Column(
        children: [
          const SizedBox(height: 30),

          const Icon(
            Icons.error_outline,
            size: 50,
          ),

          const SizedBox(height: 15),

          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      );
    }

    return _buildProfileHeader();
  }

  // LOGOUT

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onLogout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          // PROFILE HEADER
          _buildProfileContent(),

          const SizedBox(height: 15),

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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MyAddressesPage(),
                ),
              );
            },
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

          const SizedBox(height: 180),

          // LOGOUT
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(
                Icons.logout,
              ),
              label: const Text(
                'Logout',
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}