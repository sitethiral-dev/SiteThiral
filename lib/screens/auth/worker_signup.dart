import 'package:flutter/material.dart';
import 'package:sitethiral/main.dart';
import 'package:sitethiral/screens/auth/user_service.dart';

class WorkerSignupScreen extends StatefulWidget {
  const WorkerSignupScreen({super.key});
  @override
  State<WorkerSignupScreen> createState() => _WorkerSignupScreenState();
}

class _WorkerSignupScreenState extends State<WorkerSignupScreen> {
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  final _locationController = TextEditingController();
  
  // ✅ FIXED — list-ல first item-ஐ exact-ஆ போடு
  String _selectedSkill = 'Mason • கொத்தனார்';
  String _selectedExp = '1 year';
  bool _isLoading = false;

  final List<String> _skills = [
    'Mason • கொத்தனார்',
    'Carpenter • தச்சர்',
    'Electrician • மின்சாரி',
    'Painter • வர்ணக்காரர்',
    'Plumber • குழாய்காரர்',
    'Welder • வெல்டர்',
    'Helper • உதவியாளர்',
    'Tile Work • டைல் வேலை',
    'Steel Work • கம்பி வேலை',
    'Fabrication • பேப்ரிகேஷன்',
  ];

  final List<String> _experiences = [
    '1 year', '2 years', '3 years', '4 years', '5 years',
    '6-8 years', '9-12 years', '12+ years',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A72),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Worker Profile Setup', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.construction, color: Color(0xFFF15A29), size: 28),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('தொழிலாளர் பதிவு', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
                    const Text('Worker Registration', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ]),
                ]),
              ),
              const SizedBox(height: 28),

              // Full Name
              _buildLabel('Full Name • முழு பெயர்'),
              const SizedBox(height: 8),
              _buildTextField(_nameController, 'Enter your full name', Icons.person_outline),
              const SizedBox(height: 20),

              // Skill
              _buildLabel('Skill • தொழில்'),
              const SizedBox(height: 8),
              _buildDropdown(_skills, _selectedSkill, (val) => setState(() => _selectedSkill = val!)),
              const SizedBox(height: 20),

              // Experience
              _buildLabel('Experience • அனுபவம்'),
              const SizedBox(height: 8),
              _buildDropdown(_experiences, _selectedExp, (val) => setState(() => _selectedExp = val!)),
              const SizedBox(height: 20),

              // Daily Rate
              _buildLabel('Daily Rate • தினசரி கூலி (₹)'),
              const SizedBox(height: 8),
              _buildTextField(_rateController, 'e.g. 800', Icons.currency_rupee, isNumber: true),
              const SizedBox(height: 20),

              // Location
              _buildLabel('Location • இருப்பிடம்'),
              const SizedBox(height: 8),
              _buildTextField(_locationController, 'e.g. Chennai, Tambaram', Icons.location_on_outlined),
              const SizedBox(height: 20),


              // Submit Button
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

  void _submitProfile() async {
  if (_nameController.text.isEmpty || _locationController.text.isEmpty || _rateController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('எல்லா details-உம் போடுங்கள்!'), backgroundColor: Colors.red));
    return;
  }

  setState(() => _isLoading = true);

  try {
    await UserService.saveWorkerProfile(
      name: _nameController.text.trim(),
      skill: _selectedSkill,
      experience: _selectedExp,
      dailyRate: _rateController.text.trim(),
      location: _locationController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WorkerDashboard()),
      (route) => false,
    );
  } catch (e) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error! Try again.'), backgroundColor: Colors.red));
  }
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

  Widget _buildDropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF2E3D90),
          style: const TextStyle(fontSize: 15, color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFF15A29)),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}