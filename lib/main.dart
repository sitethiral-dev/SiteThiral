import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/auth/login_signup_screen.dart';
import 'screens/auth/worker_signup.dart';
import 'screens/auth/worker_type_screen.dart';
import 'screens/auth/client_type_screen.dart';
import 'screens/auth/contractor_signup.dart';
import 'screens/auth/homeowner_signup.dart';
import 'screens/auth/site_engineer_signup.dart';
import 'screens/auth/qs_admin_signup.dart';
import 'services/job_service.dart';
import 'services/pdf_export_service.dart';
import 'screens/jobs/post_job_screen.dart';
import 'screens/jobs/job_details_screen.dart';
import 'screens/jobs/edit_job_screen.dart';
import 'screens/homeowner/book_service_screen.dart';
import 'screens/homeowner/select_worker_screen.dart';
import 'screens/profile_edit/edit_worker_profile.dart';
import 'screens/profile_edit/edit_contractor_profile.dart';
import 'screens/profile_edit/edit_homeowner_profile.dart';
import 'screens/profile_edit/edit_site_engineer_profile.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/worker/booking_requests_screen.dart';
import 'package:vibration/vibration.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        scaffoldBackgroundColor: const Color(0xFF1C2A72),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
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
      if (!mounted) return;
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginSignupScreen()));
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!mounted) return;
      if (!doc.exists) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupRoleSelectionScreen()));
        return;
      }
      final role = doc.data()?['role'] ?? '';
      Widget dest;
      switch (role) {
        case 'worker':     dest = const WorkerDashboard();       break;
        case 'contractor': dest = const ContractorDashboard();   break;
        case 'homeowner':  dest = const HomeownerDashboard();    break;
        case 'engineer':   dest = const SiteEngineerDashboard(); break;
        case 'qs_admin':   dest = const QsAdminDashboard();      break;
        default:           dest = LoginSignupScreen();
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginSignupScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: const Color(0xFFF15A29), borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.construction, size: 50, color: Color(0xFF1C2A72)),
            ),
            const SizedBox(height: 24),
            const Text('SiteThiral',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFF15A29), letterSpacing: 2)),
            const SizedBox(height: 8),
            const Text('Construction Labour Hiring Platform',
              style: TextStyle(fontSize: 14, color: Color(0xFFD4A857), letterSpacing: 1)),
            const SizedBox(height: 40),
            const SizedBox(width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF15A29))),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// ROLE SELECTION
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
              _RoleCard(icon: Icons.construction, title: 'Worker', subtitle: 'Find construction jobs\nnear you', tamilText: 'தொழிலாளி',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkerDashboard()))),
              const SizedBox(height: 16),
              _RoleCard(icon: Icons.business_center, title: 'Contractor', subtitle: 'Hire skilled workers\nfor your projects', tamilText: 'ஒப்பந்தக்காரர்',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractorDashboard()))),
              const SizedBox(height: 16),
              _RoleCard(icon: Icons.home, title: 'Homeowner', subtitle: 'Get your home work\ndone by experts', tamilText: 'வீட்டுடையார்',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeownerDashboard()))),
              const SizedBox(height: 16),
              _RoleCard(icon: Icons.engineering, title: 'Site Engineer', subtitle: 'Manage sites &\ncoordinate workers', tamilText: 'தள பொறியாளர்',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiteEngineerDashboard()))),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// SIGNUP ROLE SELECTION (now with QS / Admin)
// ═══════════════════════════════════════════
class SignupRoleSelectionScreen extends StatelessWidget {
  const SignupRoleSelectionScreen({super.key});
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
              const Text('நான் ஒரு...', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Container(width: 40, height: 3,
                decoration: BoxDecoration(color: const Color(0xFFF15A29), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              const Text('உங்கள் role select பண்ணுங்கள்', style: TextStyle(fontSize: 14, color: Colors.white54)),
              const SizedBox(height: 32),
              Material(
                color: const Color(0xFFF15A29),
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkerTypeScreen())),
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.all(22),
                    child: Row(children: [
                      Container(width: 58, height: 58,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.construction, color: Colors.white, size: 30)),
                      const SizedBox(width: 18),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('நான் ஒரு தொழிலாளி', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C2A72))),
                        const SizedBox(height: 4),
                        Text('I\'m a Worker — வேலை தேடுறேன்', style: TextStyle(fontSize: 12, color: const Color(0xFF1C2A72).withOpacity(0.7))),
                      ])),
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFF1C2A72), size: 16),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: const Color(0xFF2E3D90),
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  splashColor: const Color(0xFFF15A29).withOpacity(0.15),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientTypeScreen())),
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.25))),
                    child: Row(children: [
                      Container(width: 58, height: 58,
                        decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.groups, color: Color(0xFFF15A29), size: 30)),
                      const SizedBox(width: 18),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('எனக்கு தொழிலாளி வேணும்', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text('I Need a Worker — hire பண்ணணும்', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      ])),
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFFF15A29), size: 16),
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

// ═══════════════════════════════════════════
// SHARED WIDGETS / HELPERS
// ═══════════════════════════════════════════
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, tamilText;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.tamilText, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2E3D90),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFFF15A29).withOpacity(0.15),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.18)),
          ),
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
            const SizedBox(width: 8),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_ios, color: Color(0xFFF15A29), size: 13),
            ),
          ]),
        ),
      ),
    );
  }
}

AppBar _buildDashboardAppBar(BuildContext context, bool mounted) {
  return AppBar(
    backgroundColor: const Color(0xFF1C2A72), elevation: 0,
    automaticallyImplyLeading: false,
    title: const Text('SiteThiral', style: TextStyle(color: Color(0xFFF15A29), fontWeight: FontWeight.bold, fontSize: 18)),
    actions: [
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white54, size: 20),
        tooltip: 'Logout',
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginSignupScreen()), (r) => false);
        },
      ),
    ],
  );
}

Widget _infoRow(IconData icon, String text) {
  return Row(children: [
    Icon(icon, color: const Color(0xFFF15A29), size: 18),
    const SizedBox(width: 10),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white70))),
  ]);
}

Widget _statCard(String value, String label, IconData icon) {
  return Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.1))),
    child: Column(children: [
      Icon(icon, color: const Color(0xFFF15A29), size: 20), const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.white38, height: 1.3)),
    ]),
  ));
}

Widget _emptyState(IconData icon, String message) {
  return Container(padding: const EdgeInsets.all(40), child: Center(child: Column(children: [
    Icon(icon, color: Colors.white24, size: 56),
    const SizedBox(height: 16),
    Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 14, height: 1.6)),
  ])));
}

// ── BATCH D: Tappable bell — navigates to Notification Center, badge = unread count ──
Widget _bellIcon(BuildContext context) {
  return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
    child: StreamBuilder<QuerySnapshot>(
      stream: JobService.getUnreadNotifications(),
      builder: (context, snap) {
        final count = snap.hasData ? snap.data!.docs.length : 0;
        if (count > 0) {
          Vibration.hasVibrator().then((has) {
            if (has == true) Vibration.vibrate(duration: 200);
          });
        }
        return Stack(clipBehavior: Clip.none, children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.notifications_outlined, color: Color(0xFFF15A29), size: 22)),
          if (count > 0)
            Positioned(
              right: -4, top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1C2A72), width: 2)),
                child: Text('$count', textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
        ]);
      },
    ),
  );
}

// Reusable read-only attendance row (used by QS/Admin viewer)
Widget _readonlyAttendanceRow(Map<String, dynamic> worker) {
  final jobId      = worker['jobId']      ?? '';
  final workerId    = worker['workerId']   ?? '';
  final workerName  = worker['workerName'] ?? '';
  final workerSkill = worker['workerSkill'] ?? '';

  return StreamBuilder<DocumentSnapshot>(
    stream: JobService.getAttendanceStatus(jobId, workerId),
    builder: (context, snap) {
      String status = 'not_marked';
      if (snap.hasData && snap.data!.exists) {
        final data = snap.data!.data() as Map<String, dynamic>?;
        status = data?['status'] ?? 'not_marked';
      }
      final Color sc = status == 'present' ? const Color(0xFFF15A29)
        : status == 'absent' ? Colors.red
        : status == 'late' ? const Color(0xFFD4A857)
        : Colors.white24;
      final String label = status == 'present' ? 'Present'
        : status == 'absent' ? 'Absent'
        : status == 'late' ? 'Late' : 'Not Marked';

      return Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: sc.withOpacity(0.2))),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.person, color: Color(0xFFF15A29), size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(workerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(workerSkill, style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: sc.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sc))),
        ]),
      );
    },
  );
}

// ── BATCH B: Star rating display (read-only) ──
Widget _starRow(double rating, {double size = 16}) {
  return Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) {
    final filled = i < rating.round();
    return Icon(filled ? Icons.star : Icons.star_border, color: const Color(0xFFD4A857), size: size);
  }));
}

// ── BATCH B: Verified badge ──
Widget _verifiedBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
    child: Row(mainAxisSize: MainAxisSize.min, children: const [
      Icon(Icons.verified, color: Color(0xFFF15A29), size: 12),
      SizedBox(width: 3),
      Text('Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
    ]),
  );
}

// ── BATCH B: Rate dialog — used by both Contractor (rate worker) and Worker (rate contractor) ──
Future<void> showRatingDialog(BuildContext context, {
  required String toUserId,
  required String applicationId,
  required String toName,
  required VoidCallback onDone,
}) async {
  int selected = 5;
  final reviewController = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSt) => Dialog(
        backgroundColor: const Color(0xFF2E3D90),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$toName-ஐ Rate பண்ணுங்கள்', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
              final starNum = i + 1;
              return GestureDetector(
                onTap: () => setSt(() => selected = starNum),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(starNum <= selected ? Icons.star : Icons.star_border, color: const Color(0xFFD4A857), size: 36)),
              );
            })),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF1C2A72), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
              child: TextField(
                controller: reviewController, maxLines: 2,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                decoration: const InputDecoration(hintText: 'Review (Optional)...', hintStyle: TextStyle(color: Colors.white30, fontSize: 12), border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54)))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(
                onPressed: () async {
                  await JobService.submitRating(toUserId: toUserId, applicationId: applicationId, rating: selected, review: reviewController.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                  onDone();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF15A29), foregroundColor: const Color(0xFF1C2A72), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)))),
            ]),
          ]),
        ),
      ),
    ),
  );
}

// ── BATCH B: Already-rated check widget — shows button or confirmation ──
Widget _rateOrDoneWidget(BuildContext context, {
  required String applicationId,
  required String toUserId,
  required String toName,
}) {
  return FutureBuilder<bool>(
    future: JobService.hasRatedApplication(applicationId),
    builder: (context, snap) {
      if (!snap.hasData) return const SizedBox(height: 36);
      if (snap.data == true) {
        return Container(width: double.infinity, padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Text('✓ Rate பண்ணிட்டீங்க, நன்றி!', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Color(0xFFD4A857))));
      }
      return SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () => showRatingDialog(context, toUserId: toUserId, applicationId: applicationId, toName: toName, onDone: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating submit ஆச்சு! நன்றி ✓'), backgroundColor: Color(0xFFF15A29)));
        }),
        icon: const Icon(Icons.star_outline, size: 16),
        label: const Text('Rate செய்யுங்கள்', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD4A857), side: BorderSide(color: const Color(0xFFD4A857).withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ));
    },
  );
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
  Map<String, dynamic>? _profile;
  String _searchQuery = '';
  String _filterSkill = 'All';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await JobService.getCurrentUserProfile();
    if (mounted) setState(() => _profile = p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: _buildDashboardAppBar(context, mounted),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: [_buildHomeTab(), const BookingRequestsScreen(), _buildMyJobsTab(), _buildProfileTab()])),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: const Color(0xFF2E3D90), border: Border(top: BorderSide(color: const Color(0xFFF15A29).withOpacity(0.15)))),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: Colors.transparent, selectedItemColor: const Color(0xFFF15A29), unselectedItemColor: Colors.white38, elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'My Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('வணக்கம்! 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
            Text('${_profile?['name'] ?? 'Worker'}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ])),
          _bellIcon(context),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2E3D90),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.15)),
          ),
          child: Row(children: [
            Icon(
              (_profile?['isAvailable'] ?? true) ? Icons.check_circle : Icons.pause_circle_outline,
              color: (_profile?['isAvailable'] ?? true) ? const Color(0xFFF15A29) : Colors.white38,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                (_profile?['isAvailable'] ?? true) ? 'Available for work' : 'Not available',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: (_profile?['isAvailable'] ?? true) ? Colors.white : Colors.white38),
              ),
            ),
            Switch(
              value: _profile?['isAvailable'] ?? true,
              activeColor: const Color(0xFFF15A29),
              onChanged: (val) async {
                await JobService.setWorkerAvailability(val);
                _loadProfile();
              },
            ),
          ]),
        ),
        const SizedBox(height: 20),
        // ── Search bar ──
        Container(
          decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.15))),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Title / location தேடுங்கள்...',
              hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
              prefixIcon: Icon(Icons.search, color: Color(0xFFF15A29), size: 20),
              border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
        const SizedBox(height: 10),
        // ── Skill filter chips ──
        SizedBox(
          height: 36,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final s in ['All', 'Mason', 'Carpenter', 'Electrician', 'Painter', 'Plumber', 'Welder', 'Helper'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filterSkill = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _filterSkill == s ? const Color(0xFFF15A29) : const Color(0xFF2E3D90),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF15A29).withOpacity(_filterSkill == s ? 1 : 0.2))),
                    child: Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _filterSkill == s ? const Color(0xFF1C2A72) : Colors.white60)),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Available Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: JobService.getOpenJobs(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFFF15A29))));
            }
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return _emptyState(Icons.work_off_outlined, 'இன்னும் jobs இல்லை\nகொஞ்சம் wait பண்ணுங்கள்!');
            }
            // client-side filter (search text + skill chip)
            final filtered = snap.data!.docs.where((d) {
              final job = d.data() as Map<String, dynamic>;
              final title = (job['title'] ?? '').toString().toLowerCase();
              final loc = (job['location'] ?? '').toString().toLowerCase();
              final skill = (job['skill'] ?? '').toString();
              final matchesSearch = _searchQuery.isEmpty || title.contains(_searchQuery) || loc.contains(_searchQuery);
              final matchesSkill = _filterSkill == 'All' || skill.toLowerCase().contains(_filterSkill.toLowerCase());
              return matchesSearch && matchesSkill;
            }).toList();
            if (filtered.isEmpty) {
              return _emptyState(Icons.search_off, 'இந்த search/filter-க்கு jobs இல்லை\nவேற skill/text try பண்ணுங்கள்!');
            }
            return Column(children: filtered.map((d) => _buildJobCard(d.id, d.data() as Map<String, dynamic>)).toList());
          },
        ),
      ]),
    );
  }

  Widget _buildJobCard(String jobId, Map<String, dynamic> job) {
    final isUrgent = job['isUrgent'] ?? false;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailsScreen(jobId: jobId, job: job))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isUrgent ? const Color(0xFFD4A857).withOpacity(0.3) : const Color(0xFFF15A29).withOpacity(0.1)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(job['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              if ((job['titleTamil'] ?? '').toString().isNotEmpty)
                Text(job['titleTamil'].toString(), style: const TextStyle(fontSize: 12, color: Color(0xFFD4A857))),
            ])),
            if (isUrgent) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: const Text('URGENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD4A857)))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.business, size: 13, color: Colors.white38), const SizedBox(width: 4),
            Expanded(child: Text(job['companyName'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white54))),
            const Icon(Icons.location_on, size: 13, color: Colors.white38), const SizedBox(width: 4),
            Text(job['location'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(job['wage'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF15A29)))),
            ElevatedButton(
              onPressed: () async {
                try {
                  await JobService.applyForJob(jobId: jobId, jobTitle: job['title'] ?? '', contractorId: job['contractorId'] ?? '');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applied! ✓'), backgroundColor: Color(0xFFF15A29)));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15A29), foregroundColor: const Color(0xFF1C2A72),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Apply', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
          ]),
        ]),
      ),
    );
  }

  Widget _buildMyJobsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: JobService.getMyApplications(),
      builder: (context, snap) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('My Applications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            if (!snap.hasData || snap.data!.docs.isEmpty)
              _emptyState(Icons.inbox_outlined, 'இன்னும் apply பண்ணல\nJobs tab போய் apply பண்ணுங்கள்!')
            else
              ...snap.data!.docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'pending';
                final Color sc = (status == 'shortlisted' || status == 'completed') ? const Color(0xFFF15A29)
                  : status == 'rejected' ? Colors.red : const Color(0xFFD4A857);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(14), border: Border.all(color: sc.withOpacity(0.2))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.work_outline, color: sc, size: 22)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(data['jobTitle'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(data['companyName'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          status == 'shortlisted' ? 'Shortlisted ✓'
                            : status == 'completed' ? 'Completed ✓'
                            : status == 'rejected' ? 'Rejected' : 'Pending',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sc))),
                    ]),
                    if (status == 'shortlisted' && (data['contractorPhone'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.phone, color: Color(0xFFF15A29), size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text('+91 ${data['contractorPhone']} - call பண்ணுங்கள்!',
                            style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold))),
                        ]),
                      ),
                    ],
                    if (status == 'completed') ...[
                      const SizedBox(height: 12),
                      _rateOrDoneWidget(context, applicationId: d.id, toUserId: data['contractorId'] ?? '', toName: data['companyName'] ?? 'Contractor'),
                    ],
                  ]),
                );
              }).toList(),
          ]),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    final name       = _profile?['name']      ?? 'Worker';
    final skill      = _profile?['skill']     ?? '';
    final location   = _profile?['location']  ?? '';
    final phone      = _profile?['phone']     ?? '';
    final rate       = _profile?['dailyRate'] ?? '';
    final rating     = (_profile?['rating'] ?? 0.0).toDouble();
    final totalJobs  = _profile?['totalJobs'] ?? 0;
    final isVerified = _profile?['isVerified'] ?? false;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(width: 88, height: 88,
          decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF15A29), width: 2)),
          child: const Icon(Icons.person, color: Color(0xFFF15A29), size: 44)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          if (isVerified) ...[const SizedBox(width: 8), _verifiedBadge()],
        ]),
        if (skill.isNotEmpty) Text(skill, style: const TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
        const SizedBox(height: 10),
        if (totalJobs > 0) Column(children: [
          _starRow(rating, size: 18),
          const SizedBox(height: 4),
          Text('${rating.toStringAsFixed(1)} • $totalJobs jobs completed', style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ]) else const Text('இன்னும் job complete ஆகல', style: TextStyle(fontSize: 12, color: Colors.white38)),
        const SizedBox(height: 24),
        if (location.isNotEmpty) ...[_infoRow(Icons.location_on_outlined, location), const SizedBox(height: 10)],
        if (phone.isNotEmpty) ...[_infoRow(Icons.phone_outlined, '+91 $phone'), const SizedBox(height: 10)],
        if (rate.isNotEmpty) _infoRow(Icons.currency_rupee, 'Rs.$rate / day'),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => EditWorkerProfileScreen(profile: _profile ?? {})));
            _loadProfile();
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFF15A29), side: const BorderSide(color: Color(0xFFF15A29)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
// CONTRACTOR DASHBOARD (now with Team tab)
// ═══════════════════════════════════════════
class ContractorDashboard extends StatefulWidget {
  const ContractorDashboard({super.key});
  @override
  State<ContractorDashboard> createState() => _ContractorDashboardState();
}

class _ContractorDashboardState extends State<ContractorDashboard> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _profile;
  String _applicantSearch = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await JobService.getCurrentUserProfile();
    if (mounted) setState(() => _profile = p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: _buildDashboardAppBar(context, mounted),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: [_buildHomeTab(), _buildApplicantsTab(), _buildTeamTab(), _buildProfileTab()])),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: const Color(0xFF2E3D90), border: Border(top: BorderSide(color: const Color(0xFFF15A29).withOpacity(0.15)))),
        child: BottomNavigationBar(currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), backgroundColor: Colors.transparent, selectedItemColor: const Color(0xFFF15A29), unselectedItemColor: Colors.white38, elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Applicants'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'Team'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ]),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('வணக்கம்! 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
            Text(_profile?['companyName'] ?? 'Contractor', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ])),
          _bellIcon(context),
        ]),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostJobScreen())),
            icon: const Icon(Icons.add_circle_outline), label: const Text('Post a Job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF15A29), foregroundColor: const Color(0xFF1C2A72),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 24),
        const Text('My Posted Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: JobService.getMyJobs(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFF15A29)));
            if (!snap.hasData || snap.data!.docs.isEmpty) return _emptyState(Icons.post_add, 'இன்னும் jobs post பண்ணல\nமேலே button click பண்ணுங்கள்!');
            return Column(children: snap.data!.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              final count = (data['applicants'] as List?)?.length ?? 0;
              final jobStatus = data['status'] ?? 'open';
              final isClosed = jobStatus == 'closed';
              return Container(
                margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(16), border: Border.all(color: isClosed ? Colors.white12 : const Color(0xFFF15A29).withOpacity(0.1))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Row(children: [
                      Expanded(child: Text(data['title'] ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isClosed ? Colors.white38 : Colors.white))),
                      if (isClosed) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6)), child: const Text('CLOSED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54))),
                    ])),
                    GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: count > 0 ? const Color(0xFFF15A29).withOpacity(0.15) : Colors.white12, borderRadius: BorderRadius.circular(8)),
                        child: Text('$count applied', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: count > 0 ? const Color(0xFFF15A29) : Colors.white38)))),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on, size: 13, color: Colors.white38), const SizedBox(width: 4),
                    Text(data['location'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                    const SizedBox(width: 12),
                    Text(data['wage'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFFF15A29), fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditJobScreen(jobId: d.id, job: data))),
                      icon: const Icon(Icons.edit_outlined, size: 14), label: const Text('Edit', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFF15A29), side: BorderSide(color: const Color(0xFFF15A29).withOpacity(0.4)), padding: const EdgeInsets.symmetric(vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () async {
                        await JobService.setJobStatus(d.id, isClosed ? 'open' : 'closed');
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isClosed ? 'Job reopened ✓' : 'Job closed ✓'), backgroundColor: const Color(0xFFF15A29)));
                      },
                      icon: Icon(isClosed ? Icons.refresh : Icons.lock_outline, size: 14),
                      label: Text(isClosed ? 'Reopen' : 'Close', style: const TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(foregroundColor: isClosed ? const Color(0xFFF15A29) : const Color(0xFFD4A857), side: BorderSide(color: (isClosed ? const Color(0xFFF15A29) : const Color(0xFFD4A857)).withOpacity(0.4)), padding: const EdgeInsets.symmetric(vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
                  ]),
                ]),
              );
            }).toList());
          },
        ),
      ]),
    );
  }

  Widget _buildApplicantsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: JobService.getMyApplicants(),
      builder: (context, snap) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Applicants', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            const Text('உங்கள் jobs-க்கு apply பண்ணவங்க', style: TextStyle(fontSize: 13, color: Colors.white38)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.15))),
              child: TextField(
                onChanged: (v) => setState(() => _applicantSearch = v.toLowerCase()),
                style: const TextStyle(fontSize: 14, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Worker name தேடுங்கள்...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Color(0xFFF15A29), size: 20),
                  border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(height: 16),
            if (!snap.hasData || snap.data!.docs.isEmpty)
              _emptyState(Icons.people_outline, 'இன்னும் applicants இல்லை\nWorkers உங்கள் jobs பாத்து apply பண்ணுவாங்க!')
            else
              ...(() {
                final filtered = snap.data!.docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final wname = (data['workerName'] ?? '').toString().toLowerCase();
                  return _applicantSearch.isEmpty || wname.contains(_applicantSearch);
                }).toList();
                if (filtered.isEmpty) {
                  return [_emptyState(Icons.search_off, 'இந்த பெயருக்கு applicant இல்லை')];
                }
                return filtered.map((d) {
                final data = d.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'pending';
                final Color sc = status == 'shortlisted' ? const Color(0xFFF15A29)
                  : status == 'completed' ? const Color(0xFFF15A29)
                  : status == 'rejected' ? Colors.red : const Color(0xFFD4A857);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(16), border: Border.all(color: sc.withOpacity(0.2))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.person, color: Color(0xFFF15A29), size: 26)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(data['workerName'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(data['workerSkill'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFFD4A857))),
                        Text('For: ${data['jobTitle'] ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                      ])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status == 'completed' ? 'completed ✓' : status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sc))),
                    ]),
                    if ((data['workerPhone'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(children: [const Icon(Icons.phone, size: 14, color: Colors.white38), const SizedBox(width: 6), Text('+91 ${data['workerPhone']}', style: const TextStyle(fontSize: 13, color: Colors.white70))]),
                    ],
                    const SizedBox(height: 12),
                    if (status == 'pending') Row(children: [
                      Expanded(child: OutlinedButton(
                        onPressed: () => _updateApplicationStatus(d.id, 'rejected'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Reject', style: TextStyle(fontSize: 13)))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(
                        onPressed: () => _updateApplicationStatus(d.id, 'shortlisted'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF15A29), foregroundColor: const Color(0xFF1C2A72), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Shortlist ✓', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))),
                    ]),
                    if (status == 'shortlisted') Column(children: [
                      Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Text('✓ Shortlisted - Worker-ku notification போச்சு', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFFF15A29)))),
                      const SizedBox(height: 10),
                      SizedBox(width: double.infinity, child: OutlinedButton.icon(
                        onPressed: () => _markJobCompleted(d.id, data['workerName'] ?? ''),
                        icon: const Icon(Icons.task_alt, size: 16),
                        label: const Text('Mark Job Completed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD4A857), side: BorderSide(color: const Color(0xFFD4A857).withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
                    ]),
                    if (status == 'completed') Column(children: [
                      Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Text('✓ Job Completed', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFFF15A29), fontWeight: FontWeight.bold))),
                      const SizedBox(height: 10),
                      _rateOrDoneWidget(context, applicationId: d.id, toUserId: data['workerId'] ?? '', toName: data['workerName'] ?? 'Worker'),
                    ]),
                  ]),
                );
              }).toList();
              })(),
          ]),
        );
      },
    );
  }

  void _markJobCompleted(String applicationId, String workerName) async {
    await JobService.markApplicationCompleted(applicationId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$workerName-ஓட job complete ஆச்சு ✓'), backgroundColor: const Color(0xFFF15A29)));
  }

  Future<void> _updateApplicationStatus(String docId, String newStatus) async {
    await JobService.updateApplicationStatus(docId, newStatus);
    if (!mounted) return;
    final msg = newStatus == 'shortlisted' ? 'Shortlisted! Worker notified ✓' : 'Rejected';
    final color = newStatus == 'shortlisted' ? const Color(0xFFF15A29) : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // ── NEW: TEAM TAB — QS/Admin approval management ──
  Widget _buildTeamTab() {
    final company = _profile?['companyName'] ?? '';
    if (company.isEmpty) {
      return Padding(padding: const EdgeInsets.all(20), child: _emptyState(Icons.groups_outlined, 'Company name profile-ல set ஆகல'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Team — QS / Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Company data பார்க்க request பண்ணினவங்க', style: TextStyle(fontSize: 13, color: Colors.white38)),
        const SizedBox(height: 20),

        const Text('Pending Requests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFD4A857))),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: JobService.getPendingQsRequests(company),
          builder: (context, snap) {
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12)),
                child: const Text('இன்னும் requests இல்லை', style: TextStyle(color: Colors.white38, fontSize: 13)));
            }
            return Column(children: snap.data!.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFD4A857).withOpacity(0.2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.fact_check_outlined, color: Color(0xFFD4A857), size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(data['name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(data['roleTitle'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFFD4A857))),
                    ])),
                  ]),
                  if ((data['phone'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(children: [const Icon(Icons.phone, size: 13, color: Colors.white38), const SizedBox(width: 6), Text('+91 ${data['phone']}', style: const TextStyle(fontSize: 12, color: Colors.white70))]),
                  ],
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () => _handleQsAction(d.id, 'reject'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Reject', style: TextStyle(fontSize: 11)))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(
                      onPressed: () => _handleQsAction(d.id, 'attendance_only'),
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD4A857), side: BorderSide(color: const Color(0xFFD4A857).withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Attendance Only', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 8),
                    Expanded(child: ElevatedButton(
                      onPressed: () => _handleQsAction(d.id, 'full'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF15A29), foregroundColor: const Color(0xFF1C2A72), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Full Access', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                  ]),
                ]),
              );
            }).toList());
          },
        ),
        const SizedBox(height: 28),

        const Text('Approved Team', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: JobService.getApprovedQsTeam(company),
          builder: (context, snap) {
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12)),
                child: const Text('இன்னும் team members இல்லை', style: TextStyle(color: Colors.white38, fontSize: 13)));
            }
            return Column(children: snap.data!.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              final perm = data['permissionLevel'] ?? 'attendance_only';
              return Container(
                margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.15))),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.verified_user, color: Color(0xFFF15A29), size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(data['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('${data['roleTitle'] ?? ''} - ${perm == 'full' ? 'Full Access' : 'Attendance Only'}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                  ])),
                  GestureDetector(
                    onTap: () => _revokeQs(d.id),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('Revoke', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red))),
                  ),
                ]),
              );
            }).toList());
          },
        ),
      ]),
    );
  }

  void _handleQsAction(String userId, String action) async {
    if (action == 'reject') {
      await JobService.rejectQsRequest(userId);
    } else {
      await JobService.approveQsRequest(userId, action);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(action == 'reject' ? 'Rejected' : 'Approved with ${action == 'full' ? 'Full' : 'Attendance Only'} access'),
      backgroundColor: action == 'reject' ? Colors.red : const Color(0xFFF15A29)));
  }

  void _revokeQs(String userId) async {
    await JobService.revokeQsAccess(userId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access revoked'), backgroundColor: Colors.red));
  }

  Widget _buildProfileTab() {
    final company    = _profile?['companyName'] ?? 'Company';
    final owner      = _profile?['ownerName']   ?? '';
    final location   = _profile?['location']    ?? '';
    final phone      = _profile?['phone']       ?? '';
    final gst        = _profile?['gst']         ?? '';
    final rating     = (_profile?['rating'] ?? 0.0).toDouble();
    final totalHired = _profile?['totalHired'] ?? 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(width: 88, height: 88, decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4A857), width: 2)), child: const Icon(Icons.business_center, color: Color(0xFFD4A857), size: 44)),
        const SizedBox(height: 16),
        Text(company, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        if (owner.isNotEmpty) Text('Contractor - $owner', style: const TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
        const SizedBox(height: 10),
        if (totalHired > 0) Column(children: [
          _starRow(rating, size: 18),
          const SizedBox(height: 4),
          Text('${rating.toStringAsFixed(1)} • $totalHired hired', style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ]) else const Text('இன்னும் job complete ஆகல', style: TextStyle(fontSize: 12, color: Colors.white38)),
        const SizedBox(height: 24),
        if (location.isNotEmpty) ...[_infoRow(Icons.location_on_outlined, location), const SizedBox(height: 10)],
        if (phone.isNotEmpty) ...[_infoRow(Icons.phone_outlined, '+91 $phone'), const SizedBox(height: 10)],
        if (gst.isNotEmpty) _infoRow(Icons.verified_outlined, 'GST: $gst'),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => EditContractorProfileScreen(profile: _profile ?? {})));
            _loadProfile();
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD4A857), side: const BorderSide(color: Color(0xFFD4A857)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
      ]),
    );
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
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await JobService.getCurrentUserProfile();
    if (mounted) setState(() => _profile = p);
  }

  final List<Map<String, dynamic>> _services = const [
    {'name': 'Plumbing', 'tamilName': 'குழாய் பணி', 'icon': Icons.plumbing, 'price': 'Rs.500 onwards', 'skillKeyword': 'Plumber'},
    {'name': 'Electrical', 'tamilName': 'மின் பணி', 'icon': Icons.electrical_services, 'price': 'Rs.400 onwards', 'skillKeyword': 'Electrician'},
    {'name': 'Painting', 'tamilName': 'வர்ணம்', 'icon': Icons.format_paint, 'price': 'Rs.12/sqft', 'skillKeyword': 'Painter'},
    {'name': 'Carpentry', 'tamilName': 'தச்சு பணி', 'icon': Icons.carpenter, 'price': 'Rs.600 onwards', 'skillKeyword': 'Carpenter'},
    {'name': 'Masonry', 'tamilName': 'கொத்து பணி', 'icon': Icons.construction, 'price': 'Rs.800/day', 'skillKeyword': 'Mason'},
    {'name': 'Interior', 'tamilName': 'உள்அலங்காரம்', 'icon': Icons.design_services, 'price': 'Rs.1500 onwards', 'skillKeyword': ''},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: _buildDashboardAppBar(context, mounted),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: [_buildHomeTab(), _buildRequestsTab(), _buildProfileTab()])),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: const Color(0xFF2E3D90), border: Border(top: BorderSide(color: const Color(0xFFF15A29).withOpacity(0.15)))),
        child: BottomNavigationBar(currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), backgroundColor: Colors.transparent, selectedItemColor: const Color(0xFFF15A29), unselectedItemColor: Colors.white38, elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Services'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Requests'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ]),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('வணக்கம்! 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
            Text(_profile?['name'] ?? 'Homeowner', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
          _bellIcon(context),
        ]),
        const SizedBox(height: 20),
        Container(width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFFF15A29).withOpacity(0.3), const Color(0xFF1C2A72)], begin: Alignment.centerLeft, end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Get your home fixed!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('${_profile?['propertyType'] ?? ''} - ${_profile?['location'] ?? 'Tamil Nadu'}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
          ])),
        const SizedBox(height: 24),
        const Text('Our Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Service click பண்ணி book பண்ணுங்கள்', style: TextStyle(fontSize: 12, color: Colors.white38)),
        const SizedBox(height: 16),
        _buildServicesGrid(),
      ]),
    );
  }

  Widget _buildServicesGrid() {
    final List<Widget> cards = _services.map((s) {
      return GestureDetector(
        onTap: () {
          final keyword = (s['skillKeyword'] as String?) ?? '';
          if (keyword.isNotEmpty) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => SelectWorkerScreen(
                serviceName: s['name'] as String,
                serviceNameTamil: s['tamilName'] as String,
                skillKeyword: keyword,
              )));
          } else {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => BookServiceScreen(serviceName: s['name'] as String, serviceNameTamil: s['tamilName'] as String)));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.1))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(s['icon'] as IconData, color: const Color(0xFFF15A29), size: 28),
            const SizedBox(height: 8),
            Text(s['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(s['tamilName'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFFD4A857))),
            const SizedBox(height: 4),
            Text(s['price'] as String, style: const TextStyle(fontSize: 11, color: Colors.white38)),
          ]),
        ),
      );
    }).toList();

    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
      children: cards,
    );
  }

  Widget _buildRequestsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: JobService.getMyServiceRequests(),
      builder: (context, snap) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('My Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            if (!snap.hasData || snap.data!.docs.isEmpty)
              _emptyState(Icons.list_alt_outlined, 'இன்னும் requests இல்லை\nServices tab போய் book பண்ணுங்கள்!')
            else
              ...snap.data!.docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'pending';
                final workerName = (data['workerName'] ?? '').toString();
                final workerPhone = (data['workerPhone'] ?? '').toString();
                final Color sc = status == 'completed' ? const Color(0xFFF15A29)
                  : status == 'in_progress' ? const Color(0xFFF15A29)
                  : status == 'accepted' ? const Color(0xFFD4A857)
                  : status == 'requested' ? Colors.blueAccent
                  : status == 'rejected' ? Colors.redAccent
                  : status == 'expired' ? Colors.orangeAccent
                  : status == 'cancelled' ? Colors.white38
                  : Colors.white38;
                final String statusLabel = status == 'completed' ? 'Completed ✓'
                  : status == 'in_progress' ? 'In Progress'
                  : status == 'accepted' ? 'Accepted ✓'
                  : status == 'requested' ? 'Waiting for Worker...'
                  : status == 'rejected' ? 'Rejected'
                  : status == 'expired' ? 'Expired ⏱️'
                  : status == 'cancelled' ? 'Cancelled'
                  : status;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.1))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.home_repair_service, color: Color(0xFFF15A29), size: 22)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(data['serviceName'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('${data['date'] ?? ''} - ${data['time'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      ])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sc))),
                    ]),
                    if (workerName.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFD4A857).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          const Icon(Icons.person, size: 14, color: Color(0xFFD4A857)),
                          const SizedBox(width: 6),
                          Expanded(child: Text('$workerName${workerPhone.isNotEmpty ? ' • +91 $workerPhone' : ''}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFFD4A857), fontWeight: FontWeight.bold))),
                        ]),
                      ),
                    ],
                  ]),
                );
              }).toList(),
          ]),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    final name     = _profile?['name']         ?? 'Homeowner';
    final location = _profile?['location']     ?? '';
    final phone    = _profile?['phone']        ?? '';
    final propType = _profile?['propertyType'] ?? '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(width: 88, height: 88, decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF15A29), width: 2)), child: const Icon(Icons.home, color: Color(0xFFF15A29), size: 44)),
        const SizedBox(height: 16),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        if (propType.isNotEmpty) Text('Homeowner - $propType', style: const TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
        const SizedBox(height: 24),
        if (location.isNotEmpty) ...[_infoRow(Icons.location_on_outlined, location), const SizedBox(height: 10)],
        if (phone.isNotEmpty) _infoRow(Icons.phone_outlined, '+91 $phone'),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => EditHomeownerProfileScreen(profile: _profile ?? {})));
            _loadProfile();
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFF15A29), side: const BorderSide(color: Color(0xFFF15A29)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
      ]),
    );
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
  Map<String, dynamic>? _profile;
  String _sitesSearch = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await JobService.getCurrentUserProfile();
    if (mounted) setState(() => _profile = p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: _buildDashboardAppBar(context, mounted),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: [_buildHomeTab(), _buildSitesTab(), _buildPayrollTab(), _buildProfileTab()])),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: const Color(0xFF2E3D90), border: Border(top: BorderSide(color: const Color(0xFFF15A29).withOpacity(0.15)))),
        child: BottomNavigationBar(currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), backgroundColor: Colors.transparent, selectedItemColor: const Color(0xFFF15A29), unselectedItemColor: Colors.white38, elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.location_city_outlined), activeIcon: Icon(Icons.location_city), label: 'My Sites'),
            BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), activeIcon: Icon(Icons.payments), label: 'Payroll'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ]),
      ),
    );
  }

  Widget _buildHomeTab() {
    final company = (_profile?['company'] ?? '').toString().trim();

    if (company.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('வணக்கம்! 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
              Text(_profile?['name'] ?? 'Site Engineer', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ]),
            _bellIcon(context),
          ]),
          const SizedBox(height: 40),
          _emptyState(Icons.business_outlined, 'Profile-ல Company name இல்லை.\nProfile setup-ல company name போடுங்கள்,\nஅப்போ sites/workers தெரியும்!'),
        ]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('வணக்கம்! 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
            Text(_profile?['name'] ?? 'Site Engineer', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ])),
          _bellIcon(context),
        ]),
        const SizedBox(height: 6),
        Text('Company: $company', style: const TextStyle(fontSize: 12, color: Color(0xFFD4A857))),
        const SizedBox(height: 20),

        StreamBuilder<QuerySnapshot>(
          stream: JobService.getSitesByCompany(company),
          builder: (context, sitesSnap) {
            final siteCount = sitesSnap.hasData ? sitesSnap.data!.docs.length : 0;
            return StreamBuilder<QuerySnapshot>(
              stream: JobService.getShortlistedWorkersByCompany(company),
              builder: (context, workersSnap) {
                final workerCount = workersSnap.hasData ? workersSnap.data!.docs.length : 0;
                return StreamBuilder<QuerySnapshot>(
                  stream: JobService.getTodayAttendance(company),
                  builder: (context, attSnap) {
                    final markedCount = attSnap.hasData ? attSnap.data!.docs.length : 0;
                    return Row(children: [
                      _statCard('$siteCount', 'Active\nSites', Icons.location_city_outlined),
                      const SizedBox(width: 12),
                      _statCard('$workerCount', 'Workers\nOn Site', Icons.people_outline),
                      const SizedBox(width: 12),
                      _statCard('$markedCount', 'Marked\nToday', Icons.check_circle_outline),
                    ]);
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),

        const Text("Today's Attendance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Shortlisted workers-க்கு attendance mark பண்ணுங்கள்', style: TextStyle(fontSize: 12, color: Colors.white38)),
        const SizedBox(height: 16),

        StreamBuilder<QuerySnapshot>(
          stream: JobService.getShortlistedWorkersByCompany(company),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFFF15A29))));
            }
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return _emptyState(Icons.people_outline, 'இன்னும் shortlisted workers இல்லை\nContractor workers shortlist பண்ணினா இங்க தெரியும்!');
            }
            return Column(children: snap.data!.docs.map((d) => _attendanceRow(d.data() as Map<String, dynamic>, company)).toList());
          },
        ),
      ]),
    );
  }

  Widget _attendanceRow(Map<String, dynamic> worker, String company) {
    final jobId      = worker['jobId']      ?? '';
    final workerId    = worker['workerId']   ?? '';
    final workerName  = worker['workerName'] ?? '';
    final workerSkill = worker['workerSkill'] ?? '';

    return StreamBuilder<DocumentSnapshot>(
      stream: JobService.getAttendanceStatus(jobId, workerId),
      builder: (context, snap) {
        String status = 'not_marked';
        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data() as Map<String, dynamic>?;
          status = data?['status'] ?? 'not_marked';
        }
        final Color sc = status == 'present' ? const Color(0xFFF15A29)
          : status == 'absent' ? Colors.red
          : status == 'late' ? const Color(0xFFD4A857)
          : Colors.white24;
        final String label = status == 'present' ? 'Present'
          : status == 'absent' ? 'Absent'
          : status == 'late' ? 'Late' : 'Not Marked';

        return Container(
          margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: sc.withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.person, color: Color(0xFFF15A29), size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(workerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(workerSkill, style: const TextStyle(fontSize: 12, color: Colors.white54)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: sc.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sc))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _attendBtn('Present', const Color(0xFFF15A29), () => JobService.markAttendance(jobId: jobId, workerId: workerId, workerName: workerName, companyName: company, status: 'present'))),
              const SizedBox(width: 8),
              Expanded(child: _attendBtn('Absent', Colors.red, () => JobService.markAttendance(jobId: jobId, workerId: workerId, workerName: workerName, companyName: company, status: 'absent'))),
              const SizedBox(width: 8),
              Expanded(child: _attendBtn('Late', const Color(0xFFD4A857), () => JobService.markAttendance(jobId: jobId, workerId: workerId, workerName: workerName, companyName: company, status: 'late'))),
            ]),
          ]),
        );
      },
    );
  }

  Widget _attendBtn(String label, Color c, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: c, side: BorderSide(color: c.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSitesTab() {
    final company = (_profile?['company'] ?? '').toString().trim();
    if (company.isEmpty) {
      return Padding(padding: const EdgeInsets.all(20), child: _emptyState(Icons.business_outlined, 'Profile-ல company name போடுங்கள்!'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: JobService.getSitesByCompany(company),
      builder: (context, snap) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('My Sites', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(company, style: const TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.15))),
                child: TextField(
                  onChanged: (v) => setState(() => _sitesSearch = v.toLowerCase()),
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Site title / location தேடுங்கள்...',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Color(0xFFF15A29), size: 20),
                    border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(height: 16),
              if (!snap.hasData || snap.data!.docs.isEmpty)
                _emptyState(Icons.location_city_outlined, '"$company"-க்கு இன்னும் sites இல்லை\nContractor jobs post பண்ணினா இங்க தெரியும்!')
              else
                ...(() {
                  final filtered = snap.data!.docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final title = (data['title'] ?? '').toString().toLowerCase();
                    final loc = (data['location'] ?? '').toString().toLowerCase();
                    return _sitesSearch.isEmpty || title.contains(_sitesSearch) || loc.contains(_sitesSearch);
                  }).toList();
                  if (filtered.isEmpty) return [_emptyState(Icons.search_off, 'இந்த search-க்கு sites இல்லை')];
                  return filtered.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final applicantCount = (data['applicants'] as List?)?.length ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.1))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text(data['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white))),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: const Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF15A29)))),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [const Icon(Icons.location_on, size: 12, color: Colors.white38), const SizedBox(width: 4), Text(data['location'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white54))]),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.people, size: 12, color: Colors.white38), const SizedBox(width: 4),
                        Text('$applicantCount applied', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                        const SizedBox(width: 12),
                        Text(data['wage'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFFF15A29), fontWeight: FontWeight.bold)),
                      ]),
                    ]),
                  );
                  }).toList();
                })(),
            ]),
          ),
        );
      },
    );
  }

  // ── BATCH B: PAYROLL TAB — present+late days x dailyRate, current month ──
  Widget _buildPayrollTab() {
    final company = (_profile?['company'] ?? '').toString().trim();
    if (company.isEmpty) {
      return Padding(padding: const EdgeInsets.all(20), child: _emptyState(Icons.payments_outlined, 'Profile-ல company name போடுங்கள்!'));
    }
    final now = DateTime.now();
    final monthLabel = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Payroll Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('$monthLabel ${now.year} • Present/Late days × Daily Rate', style: const TextStyle(fontSize: 12, color: Colors.white38)),
          const SizedBox(height: 20),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: JobService.getMonthlyPayroll(company),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFFF15A29))));
              }
              final rows = snap.data ?? [];
              if (rows.isEmpty) {
                return _emptyState(Icons.payments_outlined, 'இந்த மாசம் இன்னும் attendance mark பண்ணல');
              }
              final grandTotal = rows.fold<double>(0, (sum, r) => sum + (r['totalPayable'] as double));
              return Column(children: [
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.3))),
                  child: Column(children: [
                    const Text('Total Payable (இந்த மாசம்)', style: TextStyle(fontSize: 12, color: Colors.white54)),
                    const SizedBox(height: 4),
                    Text('Rs.${grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
                  ]),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () => PdfExportService.exportPayroll(company: company, rows: rows),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('Export PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4A857),
                      side: const BorderSide(color: Color(0xFFD4A857)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...rows.map((r) {
                  final present = r['present'] as int;
                  final absent = r['absent'] as int;
                  final late = r['late'] as int;
                  final payable = r['totalPayable'] as double;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.1))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(r['workerName'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Rs.${payable.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        _payrollChip('Present', present, const Color(0xFFF15A29)),
                        const SizedBox(width: 8),
                        _payrollChip('Late', late, const Color(0xFFD4A857)),
                        const SizedBox(width: 8),
                        _payrollChip('Absent', absent, Colors.red),
                      ]),
                    ]),
                  );
                }),
              ]);
            },
          ),
        ]),
      ),
    );
  }

  Widget _payrollChip(String label, int count, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text('$label: $count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c)),
    );
  }

  Widget _buildProfileTab() {
    final name   = _profile?['name']           ?? 'Site Engineer';
    final qual   = _profile?['qualification']  ?? '';
    final spec   = _profile?['specialization'] ?? '';
    final co     = _profile?['company']        ?? '';
    final loc    = _profile?['location']       ?? '';
    final phone  = _profile?['phone']          ?? '';
    final lic    = _profile?['license']        ?? '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(width: 88, height: 88, decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF15A29), width: 2)), child: const Icon(Icons.engineering, color: Color(0xFFF15A29), size: 44)),
        const SizedBox(height: 16),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        if (qual.isNotEmpty) Text('$qual - $spec', style: const TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
        const SizedBox(height: 24),
        if (co.isNotEmpty)  ...[_infoRow(Icons.business_outlined, co), const SizedBox(height: 10)],
        if (loc.isNotEmpty) ...[_infoRow(Icons.location_on_outlined, loc), const SizedBox(height: 10)],
        if (phone.isNotEmpty) ...[_infoRow(Icons.phone_outlined, '+91 $phone'), const SizedBox(height: 10)],
        if (lic.isNotEmpty) _infoRow(Icons.badge_outlined, 'License: $lic ✓'),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => EditSiteEngineerProfileScreen(profile: _profile ?? {})));
            _loadProfile();
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFF15A29), side: const BorderSide(color: Color(0xFFF15A29)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
// QS / ADMIN DASHBOARD (NEW)
// Shows waiting/rejected/approved states based on
// the request status set by the Contractor.
// ═══════════════════════════════════════════
class QsAdminDashboard extends StatefulWidget {
  const QsAdminDashboard({super.key});
  @override
  State<QsAdminDashboard> createState() => _QsAdminDashboardState();
}

class _QsAdminDashboardState extends State<QsAdminDashboard> {
  Map<String, dynamic>? _profile;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await JobService.getCurrentUserProfile();
    if (mounted) setState(() { _profile = p; _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(backgroundColor: Color(0xFF1C2A72), body: Center(child: CircularProgressIndicator(color: Color(0xFFF15A29))));
    }

    final status = _profile?['status'] ?? 'pending';

    if (status == 'pending') return _buildWaitingScreen();
    if (status == 'rejected') return _buildRejectedScreen();
    return _buildApprovedDashboard();
  }

  Widget _buildWaitingScreen() {
    final company = _profile?['requestedCompany'] ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: _buildDashboardAppBar(context, mounted),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.hourglass_top, color: Color(0xFFD4A857), size: 64),
            const SizedBox(height: 20),
            const Text('Approval-க்காக Wait பண்ணுங்கள்', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Text('"$company" contractor உங்கள் request approve பண்ணணும்',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.white54, height: 1.5)),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh), label: const Text('Refresh Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15A29), foregroundColor: const Color(0xFF1C2A72),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          ]),
        ),
      ),
    );
  }

  Widget _buildRejectedScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: _buildDashboardAppBar(context, mounted),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.cancel_outlined, color: Colors.red, size: 64),
            const SizedBox(height: 20),
            const Text('Request Reject ஆச்சு', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text('Contractor-ஐ contact பண்ணுங்கள்', style: TextStyle(fontSize: 14, color: Colors.white54)),
          ]),
        ),
      ),
    );
  }

  Widget _buildApprovedDashboard() {
    final company = (_profile?['requestedCompany'] ?? '').toString();
    final permission = _profile?['permissionLevel'] ?? 'attendance_only';
    final isFull = permission == 'full';

    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: _buildDashboardAppBar(context, mounted),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('வணக்கம்! 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                Text(_profile?['name'] ?? 'QS / Admin', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(isFull ? 'Full Access' : 'Attendance Only',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
              ),
            ]),
            const SizedBox(height: 6),
            Text(company, style: const TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
            const SizedBox(height: 20),

            if (isFull) ...[
              StreamBuilder<QuerySnapshot>(
                stream: JobService.getSitesByCompany(company),
                builder: (context, sitesSnap) {
                  final siteCount = sitesSnap.hasData ? sitesSnap.data!.docs.length : 0;
                  return StreamBuilder<QuerySnapshot>(
                    stream: JobService.getShortlistedWorkersByCompany(company),
                    builder: (context, workersSnap) {
                      final workerCount = workersSnap.hasData ? workersSnap.data!.docs.length : 0;
                      return StreamBuilder<QuerySnapshot>(
                        stream: JobService.getTodayAttendance(company),
                        builder: (context, attSnap) {
                          final markedCount = attSnap.hasData ? attSnap.data!.docs.length : 0;
                          return Row(children: [
                            _statCard('$siteCount', 'Active\nSites', Icons.location_city_outlined),
                            const SizedBox(width: 12),
                            _statCard('$workerCount', 'Workers\nBooked', Icons.people_outline),
                            const SizedBox(width: 12),
                            _statCard('$markedCount', 'Marked\nToday', Icons.check_circle_outline),
                          ]);
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Sites Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: JobService.getSitesByCompany(company),
                builder: (context, snap) {
                  if (!snap.hasData || snap.data!.docs.isEmpty) return _emptyState(Icons.location_city_outlined, 'இன்னும் sites இல்லை');
                  return Column(children: snap.data!.docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final applicantCount = (data['applicants'] as List?)?.length ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.1))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(data['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.white38), const SizedBox(width: 4),
                          Text(data['location'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                          const SizedBox(width: 12),
                          Text('$applicantCount applied', style: const TextStyle(fontSize: 12, color: Color(0xFFF15A29))),
                        ]),
                      ]),
                    );
                  }).toList());
                },
              ),
              const SizedBox(height: 24),

              const Text('Payroll Summary (இந்த மாசம்)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: JobService.getMonthlyPayroll(company),
                builder: (context, snap) {
                  final rows = snap.data ?? [];
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFF15A29)));
                  if (rows.isEmpty) return _emptyState(Icons.payments_outlined, 'இந்த மாசம் attendance இல்லை');
                  final grandTotal = rows.fold<double>(0, (s, r) => s + (r['totalPayable'] as double));
                  return Column(children: [
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.3))),
                      child: Column(children: [
                        const Text('Total Payable', style: TextStyle(fontSize: 11, color: Colors.white54)),
                        Text('Rs.${grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity, height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => PdfExportService.exportPayroll(company: company, rows: rows),
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                        label: const Text('Export PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD4A857),
                          side: const BorderSide(color: Color(0xFFD4A857)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...rows.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.1))),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(r['workerName'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Rs.${(r['totalPayable'] as double).toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
                      ]),
                    )),
                  ]);
                },
              ),
              const SizedBox(height: 24),
            ],

            const Text("Today's Attendance (View Only)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: JobService.getShortlistedWorkersByCompany(company),
              builder: (context, snap) {
                if (!snap.hasData || snap.data!.docs.isEmpty) return _emptyState(Icons.people_outline, 'இன்னும் shortlisted workers இல்லை');
                return Column(children: snap.data!.docs.map((d) => _readonlyAttendanceRow(d.data() as Map<String, dynamic>)).toList());
              },
            ),
          ]),
        ),
      ),
    );
  }
}