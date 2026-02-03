import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../providers/owner_auth_provider.dart';
import '../../../utils/constants.dart';

class AddHouseScreen extends StatefulWidget {
  final Map<String, dynamic>? house;
  const AddHouseScreen({super.key, this.house});

  @override
  State<AddHouseScreen> createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _houseType = 'apartment';
  bool _isLoading = false;
  final List<String> _types = ['apartment', 'villa', 'single house', 'other'];

  @override
  void initState() {
    super.initState();
    if (widget.house != null) {
      _addressController.text = widget.house!['address'] ?? '';
      _priceController.text = widget.house!['price'].toString();
      _roomsController.text = (widget.house!['numberOfRooms'] ?? widget.house!['rooms'] ?? '').toString();
      _descriptionController.text = widget.house!['description'] ?? '';
      _houseType = widget.house!['houseType'] ?? 'apartment';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<OwnerAuthProvider>(context, listen: false);
    
    if (auth.owner == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Not authenticated'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
      return;
    }

    final isEditing = widget.house != null;

    try {
      final url = isEditing 
          ? '${ApiConstants.baseUrl}/landlords/houses/${widget.house!['_id']}'
          : '${ApiConstants.baseUrl}/landlords/houses';
      
      final data = {
        'address': _addressController.text.trim(),
        'price': num.tryParse(_priceController.text.replaceAll(',', '')) ?? 0,
        'numberOfRooms': int.tryParse(_roomsController.text) ?? 0,
        'houseType': _houseType,
        'description': _descriptionController.text.trim(),
      };

      final response = await (isEditing 
          ? http.put(Uri.parse(url), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${auth.owner!.token}'}, body: jsonEncode(data))
          : http.post(Uri.parse(url), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${auth.owner!.token}'}, body: jsonEncode(data)));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property saved successfully!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.statusCode}'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.house != null ? 'Edit Property' : 'List New Property', 
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('General Information'),
              const SizedBox(height: 16),
              _buildTextField(_addressController, 'Address', Icons.location_on_rounded, 'e.g. 123 Main St, City'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_priceController, 'Price / Month', Icons.attach_money_rounded, '2500', isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_roomsController, 'Bedrooms', Icons.king_bed_rounded, '3', isNumber: true)),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Property Type'),
              const SizedBox(height: 12),
              _buildDropdown(),
              const SizedBox(height: 24),
              _buildSectionHeader('Description'),
              const SizedBox(height: 12),
              _buildTextField(_descriptionController, 'Describe your property', null, 'Tell potential tenants about your property...', maxLines: 4),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text(
                        widget.house != null ? 'Update Listing' : 'Publish Listing', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData? icon, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppShadows.soft],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.primary, size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: AppColors.textLight.withOpacity(0.7)),
        ),
        validator: (v) => v!.isEmpty ? 'Field required' : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppShadows.soft],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _houseType,
        items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() => _houseType = v!),
        decoration: const InputDecoration(border: InputBorder.none),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textLight),
      ),
    );
  }
}
