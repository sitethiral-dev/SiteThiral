import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  final bool isLogin;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.verificationId,
    required this.isLogin,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _resendSeconds = 60;
  late String _verificationId; // mutable for resend

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
        return true;
      }
      return false;
    });
  }

  // ── REAL OTP VERIFY ──────────────────────────
  void _verifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('6-digit OTP போடு'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Firebase Auth verify
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final uid = result.user?.uid;
      if (uid == null || !mounted) return;

      // Step 2: Check Firestore — new user or existing?
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (doc.exists) {
        // ── EXISTING USER → go to their dashboard ──
        final role = doc.data()?['role'] ?? '';
        Widget destination;
        switch (role) {
          case 'worker':     destination = const WorkerDashboard();       break;
          case 'contractor': destination = const ContractorDashboard();   break;
          case 'homeowner':  destination = const HomeownerDashboard();    break;
          case 'engineer':   destination = const SiteEngineerDashboard(); break;
          default:           destination = const SignupRoleSelectionScreen();
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => destination),
          (route) => false,
        );
      } else {
        // ── NEW USER → role selection for signup ──
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignupRoleSelectionScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String message = 'OTP verify ஆகல, try again';
      if (e.code == 'invalid-verification-code') message = 'OTP தப்பா போட்ட, check பண்ணு';
      if (e.code == 'session-expired')           message = 'OTP expire aachu, resend பண்ணு';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  // ── REAL RESEND ───────────────────────────────
  void _resendOTP() async {
    setState(() => _resendSeconds = 60);
    _startResendTimer();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${widget.phone}',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resend failed: ${e.message}'), backgroundColor: Colors.red),
        );
      },
      codeSent: (String newVerificationId, _) {
        if (!mounted) return;
        setState(() => _verificationId = newVerificationId); // update for new OTP
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('புதுசா OTP அனுப்பினோம்! ✓'),
            backgroundColor: Color(0xFFF15A29),
          ),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 40),
              const Text('OTP Verify பண்ணுங்கள்',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                  color: Color(0xFFF15A29))),
              const SizedBox(height: 8),
              Text(
                '+91 ${widget.phone} க்கு code அனுப்பினோம்',
                style: const TextStyle(fontSize: 14, color: Colors.white54, height: 1.5),
              ),
              const SizedBox(height: 40),

              // OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => SizedBox(
                  width: 48, height: 56,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.bold, color: Colors.white),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFF2E3D90),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF15A29), width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                      if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      // Auto-submit when all 6 filled
                      final otp = _controllers.map((c) => c.text).join();
                      if (otp.length == 6) _verifyOTP();
                    },
                  ),
                )),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF15A29),
                    foregroundColor: const Color(0xFF1C2A72),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                    ? const SizedBox(width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1C2A72)))
                    : const Text('Verify & Continue'),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: _resendSeconds > 0
                  ? Text('Resend OTP in ${_resendSeconds}s',
                      style: const TextStyle(fontSize: 13, color: Colors.white38))
                  : GestureDetector(
                      onTap: _resendOTP,
                      child: const Text('Resend OTP',
                        style: TextStyle(fontSize: 13,
                          color: Color(0xFFF15A29), fontWeight: FontWeight.bold)),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}