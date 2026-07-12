import 'package:flutter/material.dart';
import 'package:sitethiral/screens/auth/user_service.dart';

class EditContractorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditContractorProfileScreen({super.key, required this.profile});

  @override
  State<EditContractorProfileScreen> createState() => _EditContractorProfileScreenState();
}

class _EditContractorProfileScreenState extends State<EditContractorProfileScreen> {
  late TextEditingController _companyNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _gstController;
  late TextEditingController _locationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.profile['companyName'] ?? '');
    _ownerNameController = TextEditingController(text: widget.profile['ownerName'] ?? '');
    _gstController = TextEditingController(text: widget.profile['gst'] ?? '');
    _locationController = TextEditingController(text: widget.profile['location'] ?? '');
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _ownerNameController.dispose();
    _gstController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_companyNameController.text.isEmpty || _ownerNameController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('எல்லா details-உம் போடுங்கள்!'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await UserService.updateContractorProfile(
        companyName: _companyNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        gst: _gstController.text.trim(),
        location: _locationController.text.trim(),
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
            _label('Company Name • நிறுவன பெயர்'),
            const SizedBox(height: 8),
            _textField(_companyNameController, 'e.g. Rajan Constructions', Icons.business_outlined),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: const Text('⚠️ Company name மாத்தினா Site Engineer / QS-க்கு link தப்பும். கவனம்!',
                style: TextStyle(fontSize: 11, color: Color(0xFFD4A857))),
            ),
            const SizedBox(height: 20),
            _label('Owner Name • உரிமையாளர் பெயர்'),
            const SizedBox(height: 8),
            _textField(_ownerNameController, 'Enter owner full name', Icons.person_outline),
            const SizedBox(height: 20),
            _label('GST Number (Optional)'),
            const SizedBox(height: 8),
            _textField(_gstController, 'e.g. 33XXXXX1234X1ZX', Icons.receipt_outlined),
            const SizedBox(height: 20),
            _label('Company Location • இருப்பிடம்'),
            const SizedBox(height: 8),
            _textField(_locationController, 'e.g. Chennai, Tamil Nadu', Icons.location_on_outlined),
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
}