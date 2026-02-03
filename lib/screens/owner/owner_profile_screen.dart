import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/owner_auth_provider.dart';
import '../role_selection_screen.dart';
import '../../utils/constants.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _nationalIdController;
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final owner = Provider.of<OwnerAuthProvider>(context, listen: false).owner;
    _nameController = TextEditingController(text: owner?.name ?? '');
    _emailController = TextEditingController(text: owner?.email ?? '');
    _phoneController = TextEditingController(text: owner?.phoneNumber ?? '');
    _addressController = TextEditingController(text: owner?.address ?? '');
    _nationalIdController = TextEditingController(text: owner?.nationalID ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<OwnerAuthProvider>(context, listen: false);
    final success = await auth.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      nationalID: _nationalIdController.text.trim(),
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<OwnerAuthProvider>(context);
    final owner = auth.owner;

    if (owner == null) return Center(child: CircularProgressIndicator(color: AppColors.primary));

    return Column(
      children: [
        AppBar(
          title: Text('Account Settings', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(owner),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Personal Information'),
                        const SizedBox(height: 16),
                        _buildTextField(_nameController, 'Full Name', Icons.person_outline_rounded, 'Your name'),
                        const SizedBox(height: 16),
                        _buildTextField(_emailController, 'Email Address', Icons.email_outlined, 'your@email.com', isEmail: true),
                        const SizedBox(height: 16),
                        _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, '+1 234 567 890', isPhone: true),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('Business Details'),
                        const SizedBox(height: 16),
                        _buildTextField(_addressController, 'Office Address', Icons.location_on_outlined, 'Street, City, Country'),
                        const SizedBox(height: 16),
                        _buildTextField(_nationalIdController, 'National ID / License', Icons.badge_outlined, 'ID Number'),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader('Security'),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: auth.isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {
                              auth.logout();
                              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.logout_rounded, color: Colors.red),
                            label: const Text('Logout Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(dynamic owner) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        gradient: AppGradients.main,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassWhite.withOpacity(0.2),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.white,
              child: Text(
                owner.name[0].toUpperCase(),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            owner.name,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Landlord Account',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String hint, {bool isEmail = false, bool isPhone = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppShadows.soft],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: AppColors.textLight.withOpacity(0.7)),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Field required';
          if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Invalid email';
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppShadows.soft],
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'New Password',
          hintText: 'Leave blank to keep current',
          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20, color: AppColors.textLight),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: AppColors.textLight.withOpacity(0.7)),
        ),
        validator: (v) {
          if (v != null && v.isNotEmpty && v.length < 6) return 'Too short';
          return null;
        },
      ),
    );
  }
}
