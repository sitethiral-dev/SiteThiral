import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sitethiral/screens/auth/otp_screen.dart';

// ═══════════════════════════════════════════
// LOGIN / SIGNUP SCREEN
// ═══════════════════════════════════════════
class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});
  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true; // true = Login, false = Signup

  void _sendOTP() async {
    String phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valid 10-digit number போடு'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        setState(() => _isLoading = false);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        String msg = 'Error. Try again.';
        if (e.code == 'invalid-phone-number') msg = 'Invalid number.';
        if (e.code == 'too-many-requests') msg = 'Too many requests.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phone: phone,
              verificationId: verificationId,
              isLogin: _isLogin,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C10),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Logo
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: const Color(0xFF7ECFB3), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.construction, size: 40, color: Color(0xFF080C10)),
              ),
              const SizedBox(height: 24),
              const Text('SiteThiral', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF7ECFB3), letterSpacing: 1)),
              const SizedBox(height: 4),
              const Text('Construction Labour Hiring Platform', style: TextStyle(fontSize: 13, color: Color(0xFFD4A857))),
              const SizedBox(height: 48),

              // Login / Signup Toggle
              Container(
                decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isLogin ? const Color(0xFF7ECFB3) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Login', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                              color: _isLogin ? const Color(0xFF080C10) : Colors.white54)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isLogin ? const Color(0xFF7ECFB3) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Sign Up', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                              color: !_isLogin ? const Color(0xFF080C10) : Colors.white54)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Phone Input
              Text(
                _isLogin ? 'உங்கள் Mobile Number போடுங்கள்' : 'Register பண்ண Number போடுங்கள்',
                style: const TextStyle(fontSize: 13, color: Colors.white54),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0xFF2A3040)))),
                      child: const Text('+91', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 18, color: Colors.white, letterSpacing: 2),
                        decoration: const InputDecoration(
                          hintText: '98765 43210',
                          hintStyle: TextStyle(color: Colors.white30, letterSpacing: 2),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        maxLength: 10,
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7ECFB3),
                    foregroundColor: const Color(0xFF080C10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF080C10)))
                      : Text(_isLogin ? 'Login — OTP அனுப்பு' : 'Sign Up — OTP அனுப்பு'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _isLogin ? 'புதியவரா? Sign Up பண்ணுங்கள்' : 'Already registered? Login பண்ணுங்கள்',
                  style: const TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ),
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Workers • Contractors • Homeowners • Site Engineers',
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.2), letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}