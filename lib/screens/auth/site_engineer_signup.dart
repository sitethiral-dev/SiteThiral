import 'package:flutter/material.dart';
import 'package:sitethiral/main.dart';
import 'package:sitethiral/screens/auth/user_service.dart';

class SiteEngineerSignupScreen extends StatefulWidget {
  final String? linkedCompanyId;
  final String? linkedCompanyName;
  const SiteEngineerSignupScreen({super.key, this.linkedCompanyId, this.linkedCompanyName});
  @override
  State<SiteEngineerSignupScreen> createState() => _SiteEngineerSignupScreenState();
}

class _SiteEngineerSignupScreenState extends State<SiteEngineerSignupScreen> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  String _selectedQualification = 'B.E. Civil';
  String _selectedSpecialization = 'Building Construction';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.linkedCompanyName != null) {
      _companyController.text = widget.linkedCompanyName!;
    }
  }

  final List<String> _qualifications = [
    'B.E. Civil', 'B.Tech Civil', 'Diploma Civil',
    'M.E. Structural', 'B.Arch', 'Other',
  ];

  final List<String> _specializations = [
    'Building Construction',
    'Road & Bridge',
    'Interior Design',
    'Structural Engineering',
    'Project Management',
    'Quality Control',
  ];

  void _submitProfile() async {
  if (_nameController.text.isEmpty ||
      _locationController.text.isEmpty ||
      _experienceController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('எல்லா details-உம் போடுங்கள்!'), backgroundColor: Colors.red));
    return;
  }

  setState(() => _isLoading = true);

  try {
    await UserService.saveSiteEngineerProfile(
  name: _nameController.text.trim(),
  qualification: _selectedQualification,
  specialization: _selectedSpecialization,
  experience: '', // ← empty
  company: _companyController.text.trim(),
  location: _locationController.text.trim(),
  license: _licenseController.text.trim(),
  linkedCompanyId: widget.linkedCompanyId,
  linkedCompanyName: widget.linkedCompanyName,
);

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SiteEngineerDashboard()),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Site Engineer Profile Setup',
            style: TextStyle(color: Colors.white, fontSize: 16)),
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
                  color: const Color(0xFFF15A29).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.engineering, color: Color(0xFFF15A29), size: 28),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('தள பொறியாளர் பதிவு',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
                    const Text('Site Engineer Registration',
                        style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ]),
                ]),
              ),
              const SizedBox(height: 28),

              // Name
              _buildLabel('Full Name • முழு பெயர்'),
              const SizedBox(height: 8),
              _buildTextField(_nameController, 'Enter your full name', Icons.person_outline),
              const SizedBox(height: 20),

              // Qualification
              _buildLabel('Qualification • கல்வித் தகுதி'),
              const SizedBox(height: 8),
              _buildDropdown(_qualifications, _selectedQualification,
                  (val) => setState(() => _selectedQualification = val!)),
              const SizedBox(height: 20),

              // Specialization
              _buildLabel('Specialization • நிபுணத்துவம்'),
              const SizedBox(height: 8),
              _buildDropdown(_specializations, _selectedSpecialization,
                  (val) => setState(() => _selectedSpecialization = val!)),
              const SizedBox(height: 20),

              // Company
              _buildLabel('Company Name • நிறுவனம் (Optional)'),
              const SizedBox(height: 8),
              _buildTextField(_companyController, 'e.g. KK Infrastructure', Icons.business_outlined),
              const SizedBox(height: 20),

              // Site Location
              _buildLabel('Current Site Location • தற்போதைய தள இருப்பிடம்'),
              const SizedBox(height: 8),
              _buildTextField(_locationController, 'e.g. Tambaram, Chennai', Icons.location_on_outlined),
              const SizedBox(height: 20),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF15A29),
                    foregroundColor: const Color(0xFF1C2A72),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1C2A72)))
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
    return Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70));
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon,
      {bool isNumber = false, int? maxLen}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E3D90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2)),
      ),
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
      decoration: BoxDecoration(
        color: const Color(0xFF2E3D90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2)),
      ),
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