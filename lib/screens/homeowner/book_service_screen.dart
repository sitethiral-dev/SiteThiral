import 'package:flutter/material.dart';
import '../../services/job_service.dart';

// ═══════════════════════════════════════════
// BATCH 4D — BOOK SERVICE SCREEN
// ═══════════════════════════════════════════
class BookServiceScreen extends StatefulWidget {
  final String serviceName;
  final String serviceNameTamil;
  final String? workerId;
  final String? workerName;
  final String? workerPhone;
  final String? workerSkill;
  final String? workerDailyRate;
  const BookServiceScreen({
    super.key,
    required this.serviceName,
    required this.serviceNameTamil,
    this.workerId,
    this.workerName,
    this.workerPhone,
    this.workerSkill,
    this.workerDailyRate,
  });

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7ECFB3),
            surface: Color(0xFF1A1F2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7ECFB3),
            surface: Color(0xFF1A1F2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submit() async {
    if (_selectedDate == null || _selectedTime == null || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date, Time, Address போடுங்கள்!'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await JobService.bookService(
        serviceName: widget.serviceName,
        serviceNameTamil: widget.serviceNameTamil,
        date: '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
        time: _selectedTime!.format(context),
        address: _addressController.text.trim(),
        description: _descController.text.trim(),
        workerId: widget.workerId,
        workerName: widget.workerName,
        workerPhone: widget.workerPhone,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed! ✓'), backgroundColor: Color(0xFF7ECFB3)));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error! Try again.'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080C10),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
        title: Text('Book ${widget.serviceName}', style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7ECFB3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.home_repair_service, color: Color(0xFF7ECFB3), size: 28),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.serviceName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7ECFB3))),
                  Text(widget.serviceNameTamil, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                ]),
              ]),
            ),
            if ((widget.workerName ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A857).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4A857).withOpacity(0.3))),
                child: Row(children: [
                  Container(width: 40, height: 40,
                    decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Color(0xFFD4A857), size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Booking: ${widget.workerName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    if ((widget.workerSkill ?? '').isNotEmpty)
                      Text('${widget.workerSkill} • Rs.${widget.workerDailyRate}/day', style: const TextStyle(fontSize: 11, color: Color(0xFFD4A857))),
                  ])),
                ]),
              ),
            ],
            const SizedBox(height: 28),

            _label('Preferred Date • தேதி'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2))),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, color: Color(0xFF7ECFB3), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate == null
                      ? 'Date select பண்ணுங்கள்'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(fontSize: 15, color: _selectedDate == null ? Colors.white30 : Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            _label('Preferred Time • நேரம்'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2))),
                child: Row(children: [
                  const Icon(Icons.access_time, color: Color(0xFF7ECFB3), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTime == null ? 'Time select பண்ணுங்கள்' : _selectedTime!.format(context),
                    style: TextStyle(fontSize: 15, color: _selectedTime == null ? Colors.white30 : Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            _label('Address • முகவரி'),
            const SizedBox(height: 8),
            _textField(_addressController, 'e.g. 12, Anna Nagar, Chennai'),
            const SizedBox(height: 16),

            _label('Description (Optional)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2))),
              child: TextField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Issue details...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16)),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ECFB3),
                  foregroundColor: const Color(0xFF080C10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF080C10)))
                  : const Text('Book Now ✓'),
              ),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70));

  Widget _textField(TextEditingController c, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2))),
      child: TextField(
        controller: c,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }
}