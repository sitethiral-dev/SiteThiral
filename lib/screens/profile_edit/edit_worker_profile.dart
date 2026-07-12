import 'package:flutter/material.dart';
import 'package:sitethiral/screens/auth/user_service.dart';

class EditWorkerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditWorkerProfileScreen({super.key, required this.profile});

  @override
  State<EditWorkerProfileScreen> createState() => _EditWorkerProfileScreenState();
}

class _EditWorkerProfileScreenState extends State<EditWorkerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _rateController;
  late TextEditingController _locationController;
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile['name'] ?? '');
    _rateController = TextEditingController(text: widget.profile['dailyRate'] ?? '');
    _locationController = TextEditingController(text: widget.profile['location'] ?? '');
    final existingSkill = widget.profile['skill'] ?? '';
    if (_skills.contains(existingSkill)) _selectedSkill = existingSkill;
    final existingExp = widget.profile['experience'] ?? '';
    if (_experiences.contains(existingExp)) _selectedExp = existingExp;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_nameController.text.isEmpty || _locationController.text.isEmpty || _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('எல்லா details-உம் போடுங்கள்!'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await UserService.updateWorkerProfile(
        name: _nameController.text.trim(),
        skill: _selectedSkill,
        experience: _selectedExp,
        dailyRate: _rateController.text.trim(),
        location: _locationController.text.trim(),
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
            _label('Skill • தொழில்'),
            const SizedBox(height: 8),
            _dropdown(_skills, _selectedSkill, (v) => setState(() => _selectedSkill = v!)),
            const SizedBox(height: 20),
            _label('Experience • அனுபவம்'),
            const SizedBox(height: 8),
            _dropdown(_experiences, _selectedExp, (v) => setState(() => _selectedExp = v!)),
            const SizedBox(height: 20),
            _label('Daily Rate • தினசரி கூலி (₹)'),
            const SizedBox(height: 8),
            _textField(_rateController, 'e.g. 800', Icons.currency_rupee, isNumber: true),
            const SizedBox(height: 20),
            _label('Location • இருப்பிடம்'),
            const SizedBox(height: 8),
            _textField(_locationController, 'e.g. Chennai, Tambaram', Icons.location_on_outlined),
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