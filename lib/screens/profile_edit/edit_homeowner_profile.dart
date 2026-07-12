import 'package:flutter/material.dart';
import 'package:sitethiral/screens/auth/user_service.dart';

class EditHomeownerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditHomeownerProfileScreen({super.key, required this.profile});

  @override
  State<EditHomeownerProfileScreen> createState() => _EditHomeownerProfileScreenState();
}

class _EditHomeownerProfileScreenState extends State<EditHomeownerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  bool _receiptEnabled = false;
  bool _isLoading = false;
  String _selectedPropertyType = '1 BHK';

  final List<String> _propertyTypes = [
    '1 BHK', '2 BHK', '3 BHK', '4 BHK',
    'Independent House', 'Villa', 'Commercial',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile['name'] ?? '');
    _locationController = TextEditingController(text: widget.profile['location'] ?? '');
    _emailController = TextEditingController(text: widget.profile['email'] ?? '');
    _receiptEnabled = widget.profile['receiptEnabled'] ?? false;
    final existingType = widget.profile['propertyType'] ?? '';
    if (_propertyTypes.contains(existingType)) _selectedPropertyType = existingType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('பெயர் மற்றும் இருப்பிடம் போடுங்கள்!'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await UserService.updateHomeownerProfile(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        propertyType: _selectedPropertyType,
        receiptEnabled: _receiptEnabled,
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated! ✓'), backgroundColor: Color(0xFFF15A29)));
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
      backgroundColor: const Color(0xFF1C2A72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A72), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Full Name • முழு பெயர்'),
            const SizedBox(height: 8),
            _textField(_nameController, 'Enter your name', Icons.person_outline),
            const SizedBox(height: 20),
            _label('Location • இருப்பிடம்'),
            const SizedBox(height: 8),
            _textField(_locationController, 'e.g. Anna Nagar, Chennai', Icons.location_on_outlined),
            const SizedBox(height: 20),
            _label('Property Type • சொத்து வகை'),
            const SizedBox(height: 8),
            _dropdown(_propertyTypes, _selectedPropertyType, (v) => setState(() => _selectedPropertyType = v!)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('Receipt வேணுமா?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 2),
                    Text('Email-la receipt அனுப்பலாம்', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  ]),
                  Switch(value: _receiptEnabled, onChanged: (v) => setState(() => _receiptEnabled = v), activeColor: const Color(0xFFF15A29)),
                ]),
                if (_receiptEnabled) ...[
                  const SizedBox(height: 16),
                  _textField(_emailController, 'your@email.com', Icons.email_outlined),
                ],
              ]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF15A29), foregroundColor: const Color(0xFF1C2A72),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1C2A72)))
                    : const Text('Save Changes ✓'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70));

  Widget _textField(TextEditingController c, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
      child: TextField(
        controller: c,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFFF15A29), size: 20),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }

  Widget _dropdown(List<String> items, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true, dropdownColor: const Color(0xFF2E3D90),
          style: const TextStyle(fontSize: 15, color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFF15A29)),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}