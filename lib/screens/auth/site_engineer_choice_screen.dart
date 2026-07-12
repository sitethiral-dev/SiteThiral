import 'package:flutter/material.dart';
import 'site_engineer_signup.dart';
import 'company_search_screen.dart';

class SiteEngineerChoiceScreen extends StatelessWidget {
  const SiteEngineerChoiceScreen({super.key});
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
              const Text('Company details\nஎப்படி கொடுப்பீங்க?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
              const SizedBox(height: 8),
              Container(width: 40, height: 3, decoration: BoxDecoration(color: const Color(0xFFF15A29), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),

              Material(
                color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: const Color(0xFFF15A29).withOpacity(0.15),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanySearchScreen())),
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.18))),
                    child: Row(children: [
                      Container(width: 54, height: 54,
                        decoration: BoxDecoration(color: const Color(0xFFF15A29), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.search, color: Colors.white, size: 26)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Already registered Company', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('App-ல already irukura company-a search pண்ணி link pண்ணு', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      ])),
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFFF15A29), size: 13),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Material(
                color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: const Color(0xFFF15A29).withOpacity(0.15),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiteEngineerSignupScreen())),
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.18))),
                    child: Row(children: [
                      Container(width: 54, height: 54,
                        decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.edit_note, color: Color(0xFFF15A29), size: 26)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Independent / New Company', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Company details நானே type பண்ணுறேன்', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      ])),
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFFF15A29), size: 13),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}