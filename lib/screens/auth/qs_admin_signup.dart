import 'package:flutter/material.dart';
import 'package:sitethiral/main.dart';
import 'package:sitethiral/screens/auth/user_service.dart';

class QsAdminSignupScreen extends StatefulWidget {
  const QsAdminSignupScreen({super.key});
  @override
  State<QsAdminSignupScreen> createState() => _QsAdminSignupScreenState();
}

class _QsAdminSignupScreenState extends State<QsAdminSignupScreen> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  String _selectedRoleTitle = 'QS (Quantity Surveyor)';
  bool _isLoading = false;

  final List<String> _roleTitles = ['QS (Quantity Surveyor)', 'Admin'];

  void _submitProfile() async {
    if (_nameController.text.isEmpty || _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('பெயர் மற்றும் Company name போடுங்கள்!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await UserService.saveQsAdminProfile(
        name: _nameController.text.trim(),
        roleTitle: _selectedRoleTitle,
        requestedCompany: _companyController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const QsAdminDashboard()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error! Try again.'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080C10),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('QS / Admin Setup', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                  const Icon(Icons.fact_check_outlined, color: Color(0xFF7ECFB3), size: 28),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('QS / Admin பதிவு', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7ECFB3))),
                    Text('Company data cross-verify பண்ணும் role', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ]),
                ]),
              ),
              const SizedBox(height: 28),

              // Name
              _buildLabel('Full Name • முழு பெயர்'),
              const SizedBox(height: 8),
              _buildTextField(_nameController, 'Enter your full name', Icons.person_outline),
              const SizedBox(height: 20),

              // Role Title
              _buildLabel('Role Title • பதவி'),
              const SizedBox(height: 8),
              _buildDropdown(_roleTitles, _selectedRoleTitle, (val) => setState(() => _selectedRoleTitle = val!)),
              const SizedBox(height: 20),

              // Company
              _buildLabel('Company Name • நிறுவன பெயர்'),
              const SizedBox(height: 8),
              _buildTextField(_companyController, 'e.g. Rajan Constructions', Icons.business_outlined),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A857).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD4A857).withOpacity(0.2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('⚠️ Contractor register பண்ணின company name-ஓட',
                    style: TextStyle(fontSize: 11, color: Color(0xFFD4A857), fontWeight: FontWeight.bold)),
                  Text('EXACT-ஆ match ஆகணும் (spelling correct-ஆ check பண்ணுங்கள்)',
                    style: TextStyle(fontSize: 11, color: Color(0xFFD4A857))),
                  SizedBox(height: 6),
                  Text('Contractor உங்கள் request approve பண்ணும் வரை wait பண்ணணும்.',
                    style: TextStyle(fontSize: 11, color: Colors.white54)),
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
                      : const Text('Request Send பண்ணு ✓'),
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2))),
      child: TextField(
        controller: controller,
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
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2))),
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