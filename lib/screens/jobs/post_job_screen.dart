import 'package:flutter/material.dart';
import '../../services/job_service.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});
  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _titleController      = TextEditingController();
  final _titleTamilController = TextEditingController();
  final _wageController       = TextEditingController();
  final _locationController   = TextEditingController();
  final _descController       = TextEditingController();
  bool _isUrgent  = false;
  bool _isLoading = false;
  String _selectedSkill = 'Mason • கொத்தனார்';

  final List<String> _skills = [
    'Mason • கொத்தனார்',
    'Carpenter • தச்சர்',
    'Electrician • மின்சாரி',
    'Painter • வர்ணக்காரர்',
    'Plumber • குழாய்காரர்',
    'Welder • வெல்டர்',
    'Helper • உதவியாளர்',
    'Steel Work • கம்பி வேலை',
    'Tile Work • டைல் வேலை',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _titleTamilController.dispose();
    _wageController.dispose();
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _postJob() async {
    if (_titleController.text.isEmpty ||
        _wageController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('எல்லா details-உம் போடுங்கள்!'),
        backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await JobService.postJob(
        title:       _titleController.text.trim(),
        titleTamil:  _titleTamilController.text.trim(),
        skill:       _selectedSkill,
        wage:        '₹${_wageController.text.trim()}/day',
        location:    _locationController.text.trim(),
        description: _descController.text.trim(),
        isUrgent:    _isUrgent,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Job posted! ✓'), backgroundColor: Color(0xFFF15A29)));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error! Try again.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A72), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Post a Job', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A857).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4A857).withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.work_outline, color: Color(0xFFD4A857), size: 28),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('வேலை பதிவு', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD4A857))),
                  Text('Post a new job opening', style: TextStyle(fontSize: 12, color: Colors.white54)),
                ]),
              ]),
            ),
            const SizedBox(height: 24),
            _label('Job Title • வேலை தலைப்பு'),
            const SizedBox(height: 8),
            _textField(_titleController, 'e.g. Mason Required', Icons.title),
            const SizedBox(height: 16),
            _label('Tamil Title (Optional)'),
            const SizedBox(height: 8),
            _textField(_titleTamilController, 'e.g. கொத்தனார் தேவை', Icons.translate),
            const SizedBox(height: 16),
            _label('Required Skill • தேவையான தொழில்'),
            const SizedBox(height: 8),
            _dropdown(),
            const SizedBox(height: 16),
            _label('Daily Wage • தினசரி கூலி (₹)'),
            const SizedBox(height: 8),
            _textField(_wageController, 'e.g. 800', Icons.currency_rupee, isNumber: true),
            const SizedBox(height: 16),
            _label('Work Location • வேலை இடம்'),
            const SizedBox(height: 8),
            _textField(_locationController, 'e.g. Chennai, Tambaram', Icons.location_on_outlined),
            const SizedBox(height: 16),
            _label('Description (Optional)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
              child: TextField(
                controller: _descController, maxLines: 3,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Job details, requirements, timings...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16)),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isUrgent ? const Color(0xFFD4A857).withOpacity(0.4) : const Color(0xFFF15A29).withOpacity(0.2))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('Urgent Hiring?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 2),
                  Text('URGENT badge காட்டும்', style: TextStyle(fontSize: 12, color: Colors.white54)),
                ]),
                Switch(value: _isUrgent, onChanged: (v) => setState(() => _isUrgent = v), activeColor: const Color(0xFFD4A857)),
              ]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _postJob,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF15A29), foregroundColor: const Color(0xFF1C2A72),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1C2A72)))
                  : const Text('Job Post பண்ணு ✓'),
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
      decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
      child: TextField(
        controller: c, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFFF15A29), size: 20), border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSkill, isExpanded: true, dropdownColor: const Color(0xFF2E3D90),
          style: const TextStyle(fontSize: 15, color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFF15A29)),
          items: _skills.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: (v) => setState(() => _selectedSkill = v!)),
      ),
    );
  }
}