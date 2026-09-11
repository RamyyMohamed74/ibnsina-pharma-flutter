import 'package:flutter/material.dart';
import 'api_service.dart';

class MyAddressesPage extends StatefulWidget {
  const MyAddressesPage({super.key});

  @override
  State<MyAddressesPage> createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _governorateController =
      TextEditingController();

  final TextEditingController _cityController =
      TextEditingController();

  final TextEditingController _streetController =
      TextEditingController();

  final TextEditingController _buildingController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      final address = await ApiService.getMyAddress();

      if (!mounted) return;

      setState(() {
        _phoneController.text =
            address['phoneNumber']?.toString() ?? '';

        _governorateController.text =
            address['governorate']?.toString() ?? '';

        _cityController.text =
            address['city']?.toString() ?? '';

        _streetController.text =
            address['streetAddress']?.toString() ?? '';

        _buildingController.text =
            address['buildingApartment']?.toString() ?? '';

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load address: $e',
          ),
        ),
      );
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ApiService.updateMyAddress({
        'phoneNumber': _phoneController.text.trim(),
        'governorate': _governorateController.text.trim(),
        'city': _cityController.text.trim(),
        'streetAddress': _streetController.text.trim(),
        'buildingApartment': _buildingController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Address updated successfully!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update address: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _governorateController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _buildingController.dispose();

    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Address'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Enter your delivery information below.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    _buildTextField(
                      controller: _governorateController,
                      label: 'Governorate',
                      icon: Icons.location_city_outlined,
                    ),

                    _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_on_outlined,
                    ),

                    _buildTextField(
                      controller: _streetController,
                      label: 'Street Address',
                      icon: Icons.streetview_outlined,
                    ),

                    _buildTextField(
                      controller: _buildingController,
                      label: 'Building / Apartment',
                      icon: Icons.home_outlined,
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            _isSaving ? null : _saveAddress,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Address',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}