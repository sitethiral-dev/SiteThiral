import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/login_signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SiteThiralApp());
}

class SiteThiralApp extends StatelessWidget {
  const SiteThiralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiteThiral',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080C10),
      ),
      home: const SplashScreen(),
    );
  }
}

// ═══════════════════════════════════════════
// SPLASH SCREEN
// ═══════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginSignupScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 100, height: 100, decoration: BoxDecoration(color: const Color(0xFF7ECFB3), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.construction, size: 50, color: Color(0xFF080C10))),
            const SizedBox(height: 24),
            const Text('SiteThiral', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF7ECFB3), letterSpacing: 2)),
            const SizedBox(height: 8),
            const Text('Construction Labour Hiring Platform', style: TextStyle(fontSize: 14, color: Color(0xFFD4A857), letterSpacing: 1)),
            const SizedBox(height: 40),
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7ECFB3))),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// ROLE SELECTION SCREEN
// ═══════════════════════════════════════════
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text('I am a...', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Select your role to continue', style: TextStyle(fontSize: 14, color: Colors.white60)),
              const SizedBox(height: 48),
              _RoleCard(icon: Icons.construction, title: 'Worker', subtitle: 'Find construction jobs\nnear you', tamilText: 'தொழிலாளி', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerDashboard()))),
              const SizedBox(height: 16),
              _RoleCard(icon: Icons.business_center, title: 'Contractor', subtitle: 'Hire skilled workers\nfor your projects', tamilText: 'ஒப்பந்தக்காரர்', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContractorDashboard()))),
              const SizedBox(height: 16),
              _RoleCard(icon: Icons.home, title: 'Homeowner', subtitle: 'Get your home work\ndone by experts', tamilText: 'வீட்டுடையார்', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeownerDashboard()))),
              const SizedBox(height: 16),
              _RoleCard(icon: Icons.engineering, title: 'Site Engineer', subtitle: 'Manage sites &\ncoordinate workers', tamilText: 'தள பொறியாளர்', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SiteEngineerDashboard()))),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tamilText;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.tamilText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2))),
        child: Row(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.15), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: const Color(0xFF7ECFB3), size: 28)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 8),
              Text(tamilText, style: const TextStyle(fontSize: 12, color: Color(0xFFD4A857))),
            ]),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54, height: 1.4)),
          ])),
          const Icon(Icons.arrow_forward_ios, color: Color(0xFF7ECFB3), size: 16),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// WORKER DASHBOARD
// ═══════════════════════════════════════════
class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});
  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _jobs = [
    {'title': 'Mason Required', 'tamilTitle': 'கொத்தனார் தேவை', 'company': 'Rajan Constructions', 'location': 'Chennai, Tambaram', 'wage': '₹800/day', 'urgent': true},
    {'title': 'Carpenter Needed', 'tamilTitle': 'தச்சர் தேவை', 'company': 'Sri Murugan Builders', 'location': 'Chennai, Porur', 'wage': '₹750/day', 'urgent': false},
    {'title': 'Electrician Wanted', 'tamilTitle': 'மின்சாரி தேவை', 'company': 'KK Infrastructure', 'location': 'Chennai, Ambattur', 'wage': '₹900/day', 'urgent': true},
    {'title': 'Painter Required', 'tamilTitle': 'வர்ணக்காரர் தேவை', 'company': 'Anbu Interiors', 'location': 'Chennai, Anna Nagar', 'wage': '₹650/day', 'urgent': false},
    {'title': 'Plumber Needed', 'tamilTitle': 'குழாய்காரர் தேவை', 'company': 'Metro Plumbing Works', 'location': 'Chennai, Velachery', 'wage': '₹700/day', 'urgent': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C10),
      appBar: AppBar(backgroundColor: const Color(0xFF080C10), elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: [_buildHomeTab(), _buildMyJobsTab(), _buildProfileTab()])),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: const Color(0xFF1A1F2E), border: Border(top: BorderSide(color: const Color(0xFF7ECFB3).withOpacity(0.15)))),
        child: BottomNavigationBar(currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), backgroundColor: Colors.transparent, selectedItemColor: const Color(0xFF7ECFB3), unselectedItemColor: Colors.white38, elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'My Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ]),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('வணக்கம்! 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
          const Text('Find Your Next Job', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.notifications_outlined, color: Color(0xFF7ECFB3), size: 22)),
      ]),
      const SizedBox(height: 20),
      Row(children: [_buildStatCard('12', 'Jobs\nNearby', Icons.location_on_outlined), const SizedBox(width: 12), _buildStatCard('3', 'Applied', Icons.send_outlined), const SizedBox(width: 12), _buildStatCard('₹750', 'Avg/Day', Icons.currency_rupee)]),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Available Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('See all', style: TextStyle(fontSize: 13, color: const Color(0xFF7ECFB3).withOpacity(0.8))),
      ]),
      const SizedBox(height: 16),
      ..._jobs.map((job) => _buildJobCard(job)).toList(),
    ]));
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Column(children: [Icon(icon, color: const Color(0xFF7ECFB3), size: 20), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.white38, height: 1.3))])));
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(16), border: Border.all(color: job['urgent'] ? const Color(0xFFD4A857).withOpacity(0.3) : const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(job['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Text(job['tamilTitle'], style: const TextStyle(fontSize: 12, color: Color(0xFFD4A857)))])),
          if (job['urgent']) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: const Text('URGENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD4A857)))),
        ]),
        const SizedBox(height: 10),
        Row(children: [const Icon(Icons.business, size: 13, color: Colors.white38), const SizedBox(width: 4), Text(job['company'], style: const TextStyle(fontSize: 12, color: Colors.white54)), const SizedBox(width: 12), const Icon(Icons.location_on, size: 13, color: Colors.white38), const SizedBox(width: 4), Text(job['location'], style: const TextStyle(fontSize: 12, color: Colors.white54))]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(job['wage'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7ECFB3)))),
          ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Applied for ${job['title']}!'), backgroundColor: const Color(0xFF7ECFB3))),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7ECFB3), foregroundColor: const Color(0xFF080C10), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            child: const Text('Apply')),
        ]),
      ]));
  }

  Widget _buildMyJobsTab() {
    return Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('My Applications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 20),
      _buildApplicationCard('Mason Required', 'Rajan Constructions', 'Under Review', const Color(0xFFD4A857)),
      const SizedBox(height: 12),
      _buildApplicationCard('Electrician Wanted', 'KK Infrastructure', 'Shortlisted', const Color(0xFF7ECFB3)),
      const SizedBox(height: 12),
      _buildApplicationCard('Plumber Needed', 'Metro Plumbing Works', 'Applied', Colors.white38),
    ]));
  }

  Widget _buildApplicationCard(String title, String company, String status, Color statusColor) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.work_outline, color: Color(0xFF7ECFB3), size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)), Text(company, style: const TextStyle(fontSize: 12, color: Colors.white54))])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor))),
      ]));
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      const SizedBox(height: 20),
      Container(width: 88, height: 88, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF7ECFB3), width: 2)), child: const Icon(Icons.person, color: Color(0xFF7ECFB3), size: 44)),
      const SizedBox(height: 16),
      const Text('Murugan K.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      const Text('Mason • 8 years experience', style: TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
      const SizedBox(height: 24),
      _buildProfileSection('Skills', ['Brick Laying', 'Plastering', 'Tile Work', 'Waterproofing']),
      const SizedBox(height: 16),
      _buildInfoRow(Icons.location_on_outlined, 'Chennai, Tamil Nadu'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.phone_outlined, '+91 98765 43210'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.badge_outlined, 'Aadhaar Verified ✓'),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR Certificate — Coming Soon!'), backgroundColor: Color(0xFF7ECFB3))),
        icon: const Icon(Icons.qr_code), label: const Text('My QR Certificate'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7ECFB3), foregroundColor: const Color(0xFF080C10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
    ]));
  }

  Widget _buildProfileSection(String title, List<String> items) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white60)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: items.map((item) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.3))), child: Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF7ECFB3))))).toList()),
      ]));
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(children: [Icon(icon, color: const Color(0xFF7ECFB3), size: 18), const SizedBox(width: 10), Text(text, style: const TextStyle(fontSize: 14, color: Colors.white70))]);
  }
}

// ═══════════════════════════════════════════
// CONTRACTOR DASHBOARD
// ═══════════════════════════════════════════
class ContractorDashboard extends StatefulWidget {
  const ContractorDashboard({super.key});
  @override
  State<ContractorDashboard> createState() => _ContractorDashboardState();
}

class _ContractorDashboardState extends State<ContractorDashboard> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _workers = [
    {'name': 'Murugan K.', 'skill': 'Mason', 'tamilSkill': 'கொத்தனார்', 'location': 'Tambaram', 'wage': '₹800/day', 'verified': true, 'rating': '4.8'},
    {'name': 'Selvam R.', 'skill': 'Carpenter', 'tamilSkill': 'தச்சர்', 'location': 'Porur', 'wage': '₹750/day', 'verified': true, 'rating': '4.6'},
    {'name': 'Karthik M.', 'skill': 'Electrician', 'tamilSkill': 'மின்சாரி', 'location': 'Ambattur', 'wage': '₹900/day', 'verified': true, 'rating': '4.9'},
    {'name': 'Ravi S.', 'skill': 'Painter', 'tamilSkill': 'வர்ணக்காரர்', 'location': 'Anna Nagar', 'wage': '₹650/day', 'verified': false, 'rating': '4.2'},
    {'name': 'Anbu T.', 'skill': 'Plumber', 'tamilSkill': 'குழாய்காரர்', 'location': 'Velachery', 'wage': '₹700/day', 'verified': true, 'rating': '4.5'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C10),
      appBar: AppBar(backgroundColor: const Color(0xFF080C10), elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: [_buildHomeTab(), _buildMyProjectsTab(), _buildProfileTab()])),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: const Color(0xFF1A1F2E), border: Border(top: BorderSide(color: const Color(0xFF7ECFB3).withOpacity(0.15)))),
        child: BottomNavigationBar(currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), backgroundColor: Colors.transparent, selectedItemColor: const Color(0xFF7ECFB3), unselectedItemColor: Colors.white38, elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Workers'),
            BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Projects'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ]),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('வணக்கம்! 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
          const Text('Find Skilled Workers', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.notifications_outlined, color: Color(0xFF7ECFB3), size: 22)),
      ]),
      const SizedBox(height: 20),
      Row(children: [_buildStatCard('48', 'Workers\nAvailable', Icons.people_outline), const SizedBox(width: 12), _buildStatCard('3', 'Active\nProjects', Icons.construction_outlined), const SizedBox(width: 12), _buildStatCard('12', 'Hired\nTotal', Icons.handshake_outlined)]),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post a Job — Coming Soon!'), backgroundColor: Color(0xFF7ECFB3))),
        icon: const Icon(Icons.add_circle_outline), label: const Text('Post a Job'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7ECFB3), foregroundColor: const Color(0xFF080C10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Available Workers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), Text('See all', style: TextStyle(fontSize: 13, color: const Color(0xFF7ECFB3).withOpacity(0.8)))]),
      const SizedBox(height: 16),
      ..._workers.map((w) => _buildWorkerCard(w)).toList(),
    ]));
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Column(children: [Icon(icon, color: const Color(0xFF7ECFB3), size: 20), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.white38, height: 1.3))])));
  }

  Widget _buildWorkerCard(Map<String, dynamic> w) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.person, color: Color(0xFF7ECFB3), size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(w['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(width: 6), if (w['verified']) const Icon(Icons.verified, color: Color(0xFF7ECFB3), size: 14)]),
          Row(children: [Text(w['skill'], style: const TextStyle(fontSize: 12, color: Colors.white54)), const SizedBox(width: 4), Text('• ${w['tamilSkill']}', style: const TextStyle(fontSize: 12, color: Color(0xFFD4A857)))]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.star, color: Color(0xFFD4A857), size: 13), const SizedBox(width: 2), Text(w['rating'], style: const TextStyle(fontSize: 12, color: Colors.white54)), const SizedBox(width: 8), const Icon(Icons.location_on, size: 12, color: Colors.white38), const SizedBox(width: 2), Text(w['location'], style: const TextStyle(fontSize: 12, color: Colors.white54))]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(w['wage'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7ECFB3))),
          const SizedBox(height: 6),
          GestureDetector(onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hired ${w['name']}!'), backgroundColor: const Color(0xFF7ECFB3))),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF7ECFB3), borderRadius: BorderRadius.circular(8)), child: const Text('Hire', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF080C10))))),
        ]),
      ]));
  }

  Widget _buildMyProjectsTab() {
    return Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('My Projects', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 20),
      _buildProjectCard('Apartment Construction', 'Tambaram', 'In Progress', 3, const Color(0xFF7ECFB3)),
      const SizedBox(height: 12),
      _buildProjectCard('Villa Renovation', 'Anna Nagar', 'Planning', 5, const Color(0xFFD4A857)),
      const SizedBox(height: 12),
      _buildProjectCard('Office Interior', 'Porur', 'Completed', 2, Colors.white38),
    ]));
  }

  Widget _buildProjectCard(String title, String location, String status, int workers, Color statusColor) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)))]),
        const SizedBox(height: 8),
        Row(children: [const Icon(Icons.location_on, size: 13, color: Colors.white38), const SizedBox(width: 4), Text(location, style: const TextStyle(fontSize: 12, color: Colors.white54)), const SizedBox(width: 16), const Icon(Icons.people, size: 13, color: Colors.white38), const SizedBox(width: 4), Text('$workers workers', style: const TextStyle(fontSize: 12, color: Colors.white54))]),
      ]));
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      const SizedBox(height: 20),
      Container(width: 88, height: 88, decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4A857), width: 2)), child: const Icon(Icons.business_center, color: Color(0xFFD4A857), size: 44)),
      const SizedBox(height: 16),
      const Text('Rajan Constructions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      const Text('Contractor • Chennai', style: TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
      const SizedBox(height: 24),
      _buildInfoRow(Icons.location_on_outlined, 'Chennai, Tamil Nadu'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.phone_outlined, '+91 98765 43210'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.verified_outlined, 'GST Registered ✓'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.work_history_outlined, '15+ years in construction'),
    ]));
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(children: [Icon(icon, color: const Color(0xFF7ECFB3), size: 18), const SizedBox(width: 10), Text(text, style: const TextStyle(fontSize: 14, color: Colors.white70))]);
  }
}

// ═══════════════════════════════════════════
// HOMEOWNER DASHBOARD
// ═══════════════════════════════════════════
class HomeownerDashboard extends StatefulWidget {
  const HomeownerDashboard({super.key});
  @override
  State<HomeownerDashboard> createState() => _HomeownerDashboardState();
}

class _HomeownerDashboardState extends State<HomeownerDashboard> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _services = [
    {'name': 'Plumbing', 'tamilName': 'குழாய் பணி', 'icon': Icons.plumbing, 'price': '₹500 onwards'},
    {'name': 'Electrical', 'tamilName': 'மின் பணி', 'icon': Icons.electrical_services, 'price': '₹400 onwards'},
    {'name': 'Painting', 'tamilName': 'வர்ணம்', 'icon': Icons.format_paint, 'price': '₹12/sqft'},
    {'name': 'Carpentry', 'tamilName': 'தச்சு பணி', 'icon': Icons.carpenter, 'price': '₹600 onwards'},
    {'name': 'Masonry', 'tamilName': 'கொத்து பணி', 'icon': Icons.construction, 'price': '₹800/day'},
    {'name': 'Interior', 'tamilName': 'உள்அலங்காரம்', 'icon': Icons.design_services, 'price': '₹1500 onwards'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C10),
      appBar: AppBar(backgroundColor: const Color(0xFF080C10), elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: [_buildHomeTab(), _buildMyRequestsTab(), _buildProfileTab()])),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: const Color(0xFF1A1F2E), border: Border(top: BorderSide(color: const Color(0xFF7ECFB3).withOpacity(0.15)))),
        child: BottomNavigationBar(currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), backgroundColor: Colors.transparent, selectedItemColor: const Color(0xFF7ECFB3), unselectedItemColor: Colors.white38, elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Services'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'My Requests'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ]),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('வணக்கம்! 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
          const Text('What do you need?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.notifications_outlined, color: Color(0xFF7ECFB3), size: 22)),
      ]),
      const SizedBox(height: 20),
      Container(width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFF7ECFB3).withOpacity(0.3), const Color(0xFF080C10)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Get your home fixed!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 4), const Text('Trusted workers • Fair price • Tamil Nadu', style: TextStyle(fontSize: 12, color: Colors.white60))])),
      const SizedBox(height: 24),
      const Text('Our Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 16),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3, children: _services.map((s) => _buildServiceCard(s)).toList()),
    ]));
  }

  Widget _buildServiceCard(Map<String, dynamic> s) {
    return GestureDetector(onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s['name']} — Booking Coming Soon!'), backgroundColor: const Color(0xFF7ECFB3))),
      child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Icon(s['icon'], color: const Color(0xFF7ECFB3), size: 28), const SizedBox(height: 8), Text(s['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), Text(s['tamilName'], style: const TextStyle(fontSize: 11, color: Color(0xFFD4A857))), const SizedBox(height: 4), Text(s['price'], style: const TextStyle(fontSize: 11, color: Colors.white38))])));
  }

  Widget _buildMyRequestsTab() {
    return Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('My Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 20),
      _buildRequestCard('Plumbing Fix', 'Kitchen sink leak', 'Worker Assigned', const Color(0xFF7ECFB3)),
      const SizedBox(height: 12),
      _buildRequestCard('Wall Painting', 'Living room - 400 sqft', 'Pending', const Color(0xFFD4A857)),
      const SizedBox(height: 12),
      _buildRequestCard('Electrical Work', 'Fan installation x3', 'Completed', Colors.white38),
    ]));
  }

  Widget _buildRequestCard(String title, String desc, String status, Color statusColor) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.home_repair_service, color: Color(0xFF7ECFB3), size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)), Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white54))])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor))),
      ]));
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      const SizedBox(height: 20),
      Container(width: 88, height: 88, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF7ECFB3), width: 2)), child: const Icon(Icons.home, color: Color(0xFF7ECFB3), size: 44)),
      const SizedBox(height: 16),
      const Text('Priya S.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      const Text('Homeowner • Chennai', style: TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
      const SizedBox(height: 24),
      _buildInfoRow(Icons.location_on_outlined, 'Anna Nagar, Chennai'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.phone_outlined, '+91 98765 43210'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.home_outlined, '3 BHK Apartment'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.star_outline, '4 completed requests'),
    ]));
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(children: [Icon(icon, color: const Color(0xFF7ECFB3), size: 18), const SizedBox(width: 10), Text(text, style: const TextStyle(fontSize: 14, color: Colors.white70))]);
  }
}

// ═══════════════════════════════════════════
// SITE ENGINEER DASHBOARD
// ═══════════════════════════════════════════
class SiteEngineerDashboard extends StatefulWidget {
  const SiteEngineerDashboard({super.key});
  @override
  State<SiteEngineerDashboard> createState() => _SiteEngineerDashboardState();
}

class _SiteEngineerDashboardState extends State<SiteEngineerDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C10),
      appBar: AppBar(backgroundColor: const Color(0xFF080C10), elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: [_buildHomeTab(), _buildSitesTab(), _buildProfileTab()])),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: const Color(0xFF1A1F2E), border: Border(top: BorderSide(color: const Color(0xFF7ECFB3).withOpacity(0.15)))),
        child: BottomNavigationBar(currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), backgroundColor: Colors.transparent, selectedItemColor: const Color(0xFF7ECFB3), unselectedItemColor: Colors.white38, elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.location_city_outlined), activeIcon: Icon(Icons.location_city), label: 'My Sites'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ]),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('வணக்கம்! 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
          const Text('Site Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.notifications_outlined, color: Color(0xFF7ECFB3), size: 22)),
      ]),
      const SizedBox(height: 20),
      Row(children: [
        _buildStatCard('3', 'Active\nSites', Icons.location_city_outlined),
        const SizedBox(width: 12),
        _buildStatCard('24', 'Workers\nOn Site', Icons.people_outline),
        const SizedBox(width: 12),
        _buildStatCard('2', 'Pending\nIssues', Icons.warning_amber_outlined),
      ]),
      const SizedBox(height: 24),
      const Text('Today\'s Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 16),
      _buildAttendanceCard('Murugan K.', 'Mason', 'Present', const Color(0xFF7ECFB3)),
      const SizedBox(height: 8),
      _buildAttendanceCard('Selvam R.', 'Carpenter', 'Present', const Color(0xFF7ECFB3)),
      const SizedBox(height: 8),
      _buildAttendanceCard('Ravi S.', 'Painter', 'Absent', Colors.red),
      const SizedBox(height: 8),
      _buildAttendanceCard('Anbu T.', 'Plumber', 'Late', const Color(0xFFD4A857)),
    ]));
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Column(children: [Icon(icon, color: const Color(0xFF7ECFB3), size: 20), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.white38, height: 1.3))])));
  }

  Widget _buildAttendanceCard(String name, String role, String status, Color statusColor) {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.person, color: Color(0xFF7ECFB3), size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), Text(role, style: const TextStyle(fontSize: 12, color: Colors.white54))])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor))),
      ]));
  }

  Widget _buildSitesTab() {
    return Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('My Sites', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 20),
      _buildSiteCard('Tambaram Apartment', 'Tambaram, Chennai', 'KK Infrastructure', 'In Progress', 8),
      const SizedBox(height: 12),
      _buildSiteCard('Anna Nagar Villa', 'Anna Nagar, Chennai', 'Rajan Constructions', 'Planning', 0),
      const SizedBox(height: 12),
      _buildSiteCard('Porur Office Complex', 'Porur, Chennai', 'Sri Murugan Builders', 'Completed', 16),
    ]));
  }

  Widget _buildSiteCard(String name, String location, String company, String status, int workers) {
    Color statusColor = status == 'In Progress' ? const Color(0xFF7ECFB3) : status == 'Planning' ? const Color(0xFFD4A857) : Colors.white38;
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor))),
        ]),
        const SizedBox(height: 8),
        Row(children: [const Icon(Icons.location_on, size: 12, color: Colors.white38), const SizedBox(width: 4), Text(location, style: const TextStyle(fontSize: 12, color: Colors.white54))]),
        const SizedBox(height: 4),
        Row(children: [const Icon(Icons.business, size: 12, color: Colors.white38), const SizedBox(width: 4), Text(company, style: const TextStyle(fontSize: 12, color: Colors.white54)), const SizedBox(width: 12), const Icon(Icons.people, size: 12, color: Colors.white38), const SizedBox(width: 4), Text('$workers workers', style: const TextStyle(fontSize: 12, color: Colors.white54))]),
      ]));
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      const SizedBox(height: 20),
      Container(width: 88, height: 88, decoration: BoxDecoration(color: const Color(0xFF7ECFB3).withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF7ECFB3), width: 2)), child: const Icon(Icons.engineering, color: Color(0xFF7ECFB3), size: 44)),
      const SizedBox(height: 16),
      const Text('Karthik S.E.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      const Text('Site Engineer • B.E. Civil', style: TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
      const SizedBox(height: 24),
      _buildInfoRow(Icons.location_on_outlined, 'Chennai, Tamil Nadu'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.phone_outlined, '+91 98765 43210'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.business_outlined, 'KK Infrastructure'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.work_history_outlined, '5 years experience'),
      const SizedBox(height: 10),
      _buildInfoRow(Icons.location_city_outlined, '3 active sites'),
    ]));
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(children: [Icon(icon, color: const Color(0xFF7ECFB3), size: 18), const SizedBox(width: 10), Text(text, style: const TextStyle(fontSize: 14, color: Colors.white70))]);
  }
}