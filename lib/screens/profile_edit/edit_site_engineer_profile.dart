import 'package:flutter/material.dart';
import 'package:sitethiral/screens/auth/user_service.dart';

class EditSiteEngineerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditSiteEngineerProfileScreen({super.key, required this.profile});

  @override
  State<EditSiteEngineerProfileScreen> createState() => _EditSiteEngineerProfileScreenState();
}

class _EditSiteEngineerProfileScreenState extends State<EditSiteEngineerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _locationController;
  late TextEditingController _licenseController;
  late TextEditingController _experienceController;
  String _selectedQualification = 'B.E. Civil';
  String _selectedSpecialization = 'Building Construction';
  bool _isLoading = false;

  final List<String> _qualifications = [
    'B.E. Civil', 'B.Tech Civil', 'Diploma Civil',
    'M.E. Structural', 'B.Arch', 'Other',
  ];

  final List<String> _specializations = [
    'Building Construction', 'Road & Bridge', 'Interior Design',
    'Structural Engineering', 'Project Management', 'Quality Control',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile['name'] ?? '');
    _companyController = TextEditingController(text: widget.profile['company'] ?? '');
    _locationController = TextEditingController(text: widget.profile['location'] ?? '');
    _licenseController = TextEditingController(text: widget.profile['license'] ?? '');
    _experienceController = TextEditingController(text: widget.profile['experience'] ?? '');
    final existingQual = widget.profile['qualification'] ?? '';
    if (_qualifications.contains(existingQual)) _selectedQualification = existingQual;
    final existingSpec = widget.profile['specialization'] ?? '';
    if (_specializations.contains(existingSpec)) _selectedSpecialization = existingSpec;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('எல்லா details-உம் போடுங்கள்!'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await UserService.updateSiteEngineerProfile(
        name: _nameController.text.trim(),
        qualification: _selectedQualification,
        specialization: _selectedSpecialization,
        experience: _experienceController.text.trim(),
        company: _companyController.text.trim(),
        location: _locationController.text.trim(),
        license: _licenseController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated! ✓'), backgroundColor: Color(0xFF7ECFB3)));
      Navigator.pop(context);
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
        backgroundColor: const Color(0xFF080C10), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Full Name • முழு பெயர்'),
            const SizedBox(height: 8),
            _textField(_nameController, 'Enter your full name', Icons.person_outline),
            const SizedBox(height: 20),
            _label('Qualification • கல்வித் தகுதி'),
            const SizedBox(height: 8),
            _dropdown(_qualifications, _selectedQualification, (v) => setState(() => _selectedQualification = v!)),
            const SizedBox(height: 20),
            _label('Specialization • நிபுணத்துவம்'),
            const SizedBox(height: 8),
            _dropdown(_specializations, _selectedSpecialization, (v) => setState(() => _selectedSpecialization = v!)),
            const SizedBox(height: 20),
            _label('Experience (years)'),
            const SizedBox(height: 8),
            _textField(_experienceController, 'e.g. 5', Icons.work_history_outlined, isNumber: true),
            const SizedBox(height: 20),
            _label('Company Name • நிறுவனம்'),
            const SizedBox(height: 8),
            _textField(_companyController, 'e.g. KK Infrastructure', Icons.business_outlined),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: const Text('⚠️ Company name மாத்தினா sites/workers data மாறிடும். கவனம்!',
                style: TextStyle(fontSize: 11, color: Color(0xFFD4A857))),
            ),
            const SizedBox(height: 20),
            _label('Current Site Location'),
            const SizedBox(height: 8),
            _textField(_locationController, 'e.g. Tambaram, Chennai', Icons.location_on_outlined),
            const SizedBox(height: 20),
            _label('Engineer License No. (Optional)'),
            const SizedBox(height: 8),
            _textField(_licenseController, 'e.g. TN/CE/2024/XXXXX', Icons.badge_outlined),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ECFB3), foregroundColor: const Color(0xFF080C10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF080C10)))
                    : const Text('Save Changes ✓'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70));

  Widget _textField(TextEditingController c, String hint, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2))),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF7ECFB3), size: 20),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }

  Widget _dropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true, dropdownColor: const Color(0xFF1A1F2E),
          style: const TextStyle(fontSize: 15, color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7ECFB3)),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}