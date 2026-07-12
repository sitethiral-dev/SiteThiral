import 'package:flutter/material.dart';
import 'package:sitethiral/main.dart';
import 'package:sitethiral/screens/auth/user_service.dart';

class HomeownerSignupScreen extends StatefulWidget {
  const HomeownerSignupScreen({super.key});
  @override
  State<HomeownerSignupScreen> createState() => _HomeownerSignupScreenState();
}

class _HomeownerSignupScreenState extends State<HomeownerSignupScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  bool _receiptEnabled = false;
  bool _isLoading = false;
  String _selectedPropertyType = '1 BHK';

  final List<String> _propertyTypes = [
    '1 BHK', '2 BHK', '3 BHK', '4 BHK',
    'Independent House', 'Villa', 'Commercial',
  ];

  void _submitProfile() async {
  if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('பெயர் மற்றும் இருப்பிடம் போடுங்கள்!'), backgroundColor: Colors.red));
    return;
  }

  setState(() => _isLoading = true);

  try {
    await UserService.saveHomeownerProfile(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      propertyType: _selectedPropertyType,
      receiptEnabled: _receiptEnabled,
      email: _emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeownerDashboard()),
      (route) => false,
    );
  } catch (e) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error! Try again.'), backgroundColor: Colors.red));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080C10),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Homeowner Profile Setup', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7ECFB3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.home, color: Color(0xFF7ECFB3), size: 28),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('வீட்டுடையார் பதிவு', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7ECFB3))),
                    const Text('Homeowner Registration', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ]),
                ]),
              ),
              const SizedBox(height: 28),

              // Name
              _buildLabel('Full Name • முழு பெயர்'),
              const SizedBox(height: 8),
              _buildTextField(_nameController, 'Enter your name', Icons.person_outline),
              const SizedBox(height: 20),

              // Location
              _buildLabel('Location • இருப்பிடம்'),
              const SizedBox(height: 8),
              _buildTextField(_locationController, 'e.g. Anna Nagar, Chennai', Icons.location_on_outlined),
              const SizedBox(height: 20),

              // Property Type
              _buildLabel('Property Type • சொத்து வகை'),
              const SizedBox(height: 8),
              _buildDropdown(_propertyTypes, _selectedPropertyType, (val) => setState(() => _selectedPropertyType = val!)),
              const SizedBox(height: 24),

              // Receipt Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2)),
                ),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Receipt வேணுமா?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 2),
                      const Text('Email-la receipt அனுப்பலாம்', style: TextStyle(fontSize: 12, color: Colors.white54)),
                    ]),
                    Switch(
                      value: _receiptEnabled,
                      onChanged: (val) => setState(() => _receiptEnabled = val),
                      activeColor: const Color(0xFF7ECFB3),
                    ),
                  ]),

                  if (_receiptEnabled) ...[
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'your@email.com', Icons.email_outlined),
                    const SizedBox(height: 8),
                    const Text('✓ Service complete ஆனா receipt email வரும்', style: TextStyle(fontSize: 11, color: Color(0xFF7ECFB3))),
                  ],
                ]),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7ECFB3),
                    foregroundColor: const Color(0xFF080C10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF080C10)))
                      : const Text('Profile Save பண்ணு ✓'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70));
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF7ECFB3), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1F2E),
          style: const TextStyle(fontSize: 15, color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7ECFB3)),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}