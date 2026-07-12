import 'package:flutter/material.dart';
import 'worker_signup.dart';

class WorkerTypeScreen extends StatelessWidget {
  const WorkerTypeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A72), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text('எப்படி வேலை\nபண்ணுவீங்க?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
              const SizedBox(height: 8),
              Container(width: 40, height: 3, decoration: BoxDecoration(color: const Color(0xFFF15A29), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              const Text('உங்க வேலை type select பண்ணுங்கள்', style: TextStyle(fontSize: 14, color: Colors.white54)),
              const SizedBox(height: 32),

              _typeCard(context, icon: Icons.person_outline, title: 'Daily Wage Worker',
                subtitle: 'தனியா, தினசரி கூலிக்கு வேலை பண்ணுறவங்க',
                workerType: 'daily_wage'),
              const SizedBox(height: 14),
              _typeCard(context, icon: Icons.groups_outlined, title: 'Group Workers',
                subtitle: 'டீம் ஆ சேர்ந்து வேலை பண்ணுறவங்க',
                workerType: 'group'),
              const SizedBox(height: 14),
              _typeCard(context, icon: Icons.home_work_outlined, title: 'Accommodation Worker',
                subtitle: 'தங்குமிடம் கொடுக்கும் இடத்துல வேலை பண்ணுறவங்க',
                workerType: 'accommodation'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required String workerType}) {
    return Material(
      color: const Color(0xFF2E3D90),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFFF15A29).withOpacity(0.15),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerSignupScreen(workerType: workerType))),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.18))),
          child: Row(children: [
            Container(width: 54, height: 54,
              decoration: BoxDecoration(color: const Color(0xFFF15A29), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 26)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54, height: 1.3)),
            ])),
            Container(width: 30, height: 30,
              decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_ios, color: Color(0xFFF15A29), size: 13)),
          ]),
        ),
      ),
    );
  }
}