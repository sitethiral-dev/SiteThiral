import 'package:flutter/material.dart';
import 'homeowner_signup.dart';
import 'contractor_signup.dart';
import 'site_engineer_choice_screen.dart';
import 'qs_admin_signup.dart';

class ClientTypeScreen extends StatelessWidget {
  const ClientTypeScreen({super.key});
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
              const Text('நீங்க யாரு?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Container(width: 40, height: 3, decoration: BoxDecoration(color: const Color(0xFFF15A29), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              const Text('உங்கள் role select பண்ணுங்கள்', style: TextStyle(fontSize: 14, color: Colors.white54)),
              const SizedBox(height: 32),

              _typeCard(context, icon: Icons.home, title: 'Homeowner', tamilText: 'வீட்டுடையார்',
                subtitle: 'Home work book பண்ணலாம்',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeownerSignupScreen()))),
              const SizedBox(height: 14),
              _typeCard(context, icon: Icons.business_center, title: 'Company', tamilText: 'ஒப்பந்தக்காரர்',
                subtitle: 'Workers hire பண்ணலாம்',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractorSignupScreen()))),
              const SizedBox(height: 14),
              _typeCard(context, icon: Icons.engineering, title: 'Site Engineer', tamilText: 'தள பொறியாளர்',
                subtitle: 'Sites manage பண்ணலாம்',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiteEngineerChoiceScreen()))),
              const SizedBox(height: 14),
              _typeCard(context, icon: Icons.fact_check_outlined, title: 'QS / Admin', tamilText: 'நிர்வாகி',
                subtitle: 'Company data cross-verify பண்ணலாம்',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QsAdminSignupScreen()))),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeCard(BuildContext context, {required IconData icon, required String title, required String tamilText, required String subtitle, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFF2E3D90),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFFF15A29).withOpacity(0.15),
        onTap: onTap,
        child: Container(
          width: double.infinity, padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.18))),
          child: Row(children: [
            Container(width: 54, height: 54,
              decoration: BoxDecoration(color: const Color(0xFFF15A29), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 26)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(tamilText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFD4A857))),
                ),
              ]),
              const SizedBox(height: 5),
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