import 'package:flutter/material.dart';
import 'package:sitethiral/main.dart';
import 'package:sitethiral/screens/auth/user_service.dart';

class ContractorSignupScreen extends StatefulWidget {
  const ContractorSignupScreen({super.key});
  @override
  State<ContractorSignupScreen> createState() => _ContractorSignupScreenState();
}

class _ContractorSignupScreenState extends State<ContractorSignupScreen> {
  final _companyNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _gstController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  // Employees list
  final List<Map<String, TextEditingController>> _employees = [];

  void _addEmployee() {
    setState(() {
      _employees.add({
        'name': TextEditingController(),
        'position': TextEditingController(),
        'mobile': TextEditingController(),
      });
    });
  }

  void _removeEmployee(int index) {
    setState(() => _employees.removeAt(index));
  }

  void _submitProfile() async {
  if (_companyNameController.text.isEmpty ||
      _ownerNameController.text.isEmpty ||
      _locationController.text.isEmpty ||
      _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('எல்லா details-உம் போடுங்கள்!'), backgroundColor: Colors.red));
    return;
  }
  if (_passwordController.text != _confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password match ஆகல!'), backgroundColor: Colors.red));
    return;
  }

  setState(() => _isLoading = true);

  try {
    List<Map<String, String>> employeeList = _employees.map((emp) => {
      'name': emp['name']!.text,
      'position': emp['position']!.text,
      'mobile': emp['mobile']!.text,
    }).toList();

    await UserService.saveContractorProfile(
      companyName: _companyNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      gst: _gstController.text.trim(),
      location: _locationController.text.trim(),
      password: _passwordController.text,
      employees: employeeList,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ContractorDashboard()),
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
      backgroundColor: const Color(0xFF1C2A72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A72),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Contractor Profile Setup', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD4A857).withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.business_center, color: Color(0xFFD4A857), size: 28),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('ஒப்பந்தக்காரர் பதிவு', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4A857))),
                    const Text('Contractor Registration', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ]),
                ]),
              ),
              const SizedBox(height: 28),

              // Company Name
              _buildLabel('Company Name • நிறுவன பெயர்'),
              const SizedBox(height: 8),
              _buildTextField(_companyNameController, 'e.g. Rajan Constructions', Icons.business_outlined),
              const SizedBox(height: 20),

              // Owner Name
              _buildLabel('Owner Name • உரிமையாளர் பெயர்'),
              const SizedBox(height: 8),
              _buildTextField(_ownerNameController, 'Enter owner full name', Icons.person_outline),
              const SizedBox(height: 20),

              // GST Number
              _buildLabel('GST Number (Optional)'),
              const SizedBox(height: 8),
              _buildTextField(_gstController, 'e.g. 33XXXXX1234X1ZX', Icons.receipt_outlined, maxLen: 15),
              const SizedBox(height: 20),

              // Location
              _buildLabel('Company Location • இருப்பிடம்'),
              const SizedBox(height: 8),
              _buildTextField(_locationController, 'e.g. Chennai, Tamil Nadu', Icons.location_on_outlined),
              const SizedBox(height: 20),

              // Password
              _buildLabel('Admin Password • கடவுச்சொல்'),
              const SizedBox(height: 8),
              _buildPasswordField(_passwordController, 'Create a strong password'),
              const SizedBox(height: 12),
              _buildPasswordField(_confirmPasswordController, 'Confirm password'),
              const SizedBox(height: 8),
              const Text('இந்த password-ஐ employees மாத்திக்கலாம் 🔒', style: TextStyle(fontSize: 11, color: Colors.white38)),
              const SizedBox(height: 28),

              // Employees Section
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Employees • ஊழியர்கள்', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                GestureDetector(
                  onTap: _addEmployee,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.3))),
                    child: Row(children: const [Icon(Icons.add, color: Color(0xFFF15A29), size: 16), SizedBox(width: 4), Text('Add', style: TextStyle(color: Color(0xFFF15A29), fontSize: 13, fontWeight: FontWeight.bold))]),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              if (_employees.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('+ Add பண்ணி employees சேர்க்கலாம்', style: TextStyle(color: Colors.white38, fontSize: 13))),
                ),

              ..._employees.asMap().entries.map((entry) {
                int i = entry.key;
                var emp = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.15))),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Employee ${i + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
                      GestureDetector(onTap: () => _removeEmployee(i), child: const Icon(Icons.close, color: Colors.red, size: 18)),
                    ]),
                    const SizedBox(height: 10),
                    _buildTextField(emp['name']!, 'Employee Name', Icons.person_outline),
                    const SizedBox(height: 8),
                    _buildTextField(emp['position']!, 'Position (e.g. Supervisor)', Icons.work_outline),
                    const SizedBox(height: 8),
                    _buildTextField(emp['mobile']!, 'Mobile Number', Icons.phone_outlined, isNumber: true, maxLen: 10),
                  ]),
                );
              }).toList(),

              const SizedBox(height: 28),

              // Submit
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF15A29),
                    foregroundColor: const Color(0xFF1C2A72),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1C2A72)))
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, int? maxLen}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLength: maxLen,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFFF15A29), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
      child: TextField(
        controller: controller,
        obscureText: !_showPassword,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFF15A29), size: 20),
          suffixIcon: IconButton(
            icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 20),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}