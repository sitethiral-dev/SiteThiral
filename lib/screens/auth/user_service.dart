import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  static String get _uid   => _auth.currentUser!.uid;
  static String get _phone => _auth.currentUser?.phoneNumber ?? '';


  // ══════════════════════════════════════════
  // WORKER SAVE
  // ══════════════════════════════════════════
  // ══════════════════════════════════════════
  // WORKER ID GENERATOR — ST-2026-000001, ST-2026-000002...
  // Counter is GLOBAL and never resets (no duplicate numbers,
  // ever — even across years). The year shown is simply the
  // year that worker joined, purely for display/trust purposes.
  // Padded to 6 digits so it scales cleanly into lakhs.
  // ══════════════════════════════════════════
  static Future<String> _generateWorkerId() async {
    final joinYear = DateTime.now().year;
    final counterRef = _db.collection('counters').doc('workerId_global');
    final next = await _db.runTransaction<int>((txn) async {
      final snap = await txn.get(counterRef);
      final n = (snap.exists ? (snap.data()?['value'] as int? ?? 0) : 0) + 1;
      txn.set(counterRef, {'value': n}, SetOptions(merge: true));
      return n;
    });
    return 'ST-$joinYear-${next.toString().padLeft(6, '0')}';
  }
  static Future<void> saveWorkerProfile({
    required String name,
    required String skill,
    required String experience,
    required String dailyRate,
    required String location,
    String aadhaar = '',
    String workerType = 'daily_wage',
  }) async {
    await _db.collection('users').doc(_uid).set({
      'uid':         _uid,
      'phone':       _phone,
      'role':        'worker',
      'name':        name,
      'skill':       skill,
      'experience':  experience,
      'dailyRate':   dailyRate,
      'location':    location,
      'aadhaar':     aadhaar,
      'workerType':  workerType,
      'isVerified':  false,
      'isAvailable': true,
      'rating':      0.0,
      'totalJobs':   0,
      'createdAt':   FieldValue.serverTimestamp(),
      'updatedAt':   FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════
  // CONTRACTOR SAVE
  // ══════════════════════════════════════════
  static Future<void> saveContractorProfile({
    required String companyName,
    required String ownerName,
    required String gst,
    required String location,
    required String password,
    required List<Map<String, String>> employees,
  }) async {
    await _db.collection('users').doc(_uid).set({
      'uid':           _uid,
      'phone':         _phone,
      'role':          'contractor',
      'companyName':   companyName,
      'ownerName':     ownerName,
      'gst':           gst,
      'location':      location,
      'employees':     employees,
      'isVerified':    gst.isNotEmpty,
      'activeProjects': 0,
      'totalHired':    0,
      'createdAt':     FieldValue.serverTimestamp(),
      'updatedAt':     FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════
  // HOMEOWNER SAVE
  // ══════════════════════════════════════════
  static Future<void> saveHomeownerProfile({
    required String name,
    required String location,
    required String propertyType,
    required bool   receiptEnabled,
    required String email,
  }) async {
    await _db.collection('users').doc(_uid).set({
      'uid':            _uid,
      'phone':          _phone,
      'role':           'homeowner',
      'name':           name,
      'location':       location,
      'propertyType':   propertyType,
      'receiptEnabled': receiptEnabled,
      'email':          email,
      'totalRequests':  0,
      'createdAt':      FieldValue.serverTimestamp(),
      'updatedAt':      FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════
  // SITE ENGINEER SAVE
  // ══════════════════════════════════════════
  static Future<void> saveSiteEngineerProfile({
    required String name,
    required String qualification,
    required String specialization,
    required String experience,
    required String company,
    required String location,
    required String license,
  }) async {
    await _db.collection('users').doc(_uid).set({
      'uid':            _uid,
      'phone':          _phone,
      'role':           'engineer',
      'name':           name,
      'qualification':  qualification,
      'specialization': specialization,
      'experience':     experience,
      'company':        company,
      'location':       location,
      'license':        license,
      'isVerified':     license.isNotEmpty,
      'activeSites':    0,
      'createdAt':      FieldValue.serverTimestamp(),
      'updatedAt':      FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════
  // QS / ADMIN SAVE — NEW (requires Contractor approval)
  // ══════════════════════════════════════════
  static Future<void> saveQsAdminProfile({
    required String name,
    required String roleTitle,         // 'QS (Quantity Surveyor)' or 'Admin'
    required String requestedCompany,  // company they want to join
  }) async {
    await _db.collection('users').doc(_uid).set({
      'uid':              _uid,
      'phone':            _phone,
      'role':             'qs_admin',
      'name':             name,
      'roleTitle':        roleTitle,
      'requestedCompany': requestedCompany,
      'status':           'pending',
      'permissionLevel':  null,
      'createdAt':        FieldValue.serverTimestamp(),
      'updatedAt':        FieldValue.serverTimestamp(),
    });

    // Notify the matching contractor so they know to check the Team tab
    try {
      final match = await _db.collection('users')
          .where('role', isEqualTo: 'contractor')
          .where('companyName', isEqualTo: requestedCompany)
          .limit(1)
          .get();
      if (match.docs.isNotEmpty) {
        await _db.collection('notifications').add({
          'userId': match.docs.first.id,
          'title': 'QS/Admin Join Request',
          'message': '$name ($roleTitle) உங்கள் company-ல join பண்ண request பண்ணிருக்காங்க',
          'type': 'qs_request',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // best-effort — signup should not fail if this lookup has issues
    }
  }

  // ══════════════════════════════════════════
  // EDIT PROFILE — UPDATE METHODS (Batch A)
  // These use .update() and only touch editable fields,
  // so rating / totalJobs / createdAt / isVerified are preserved.
  // ══════════════════════════════════════════

  static Future<void> updateWorkerProfile({
    required String name,
    required String skill,
    required String experience,
    required String dailyRate,
    required String location,
  }) async {
    await _db.collection('users').doc(_uid).update({
      'name':       name,
      'skill':      skill,
      'experience': experience,
      'dailyRate':  dailyRate,
      'location':   location,
      'updatedAt':  FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateContractorProfile({
    required String companyName,
    required String ownerName,
    required String gst,
    required String location,
  }) async {
    await _db.collection('users').doc(_uid).update({
      'companyName': companyName,
      'ownerName':   ownerName,
      'gst':         gst,
      'location':    location,
      'isVerified':  gst.isNotEmpty,
      'updatedAt':   FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateHomeownerProfile({
    required String name,
    required String location,
    required String propertyType,
    required bool   receiptEnabled,
    required String email,
  }) async {
    await _db.collection('users').doc(_uid).update({
      'name':           name,
      'location':       location,
      'propertyType':   propertyType,
      'receiptEnabled': receiptEnabled,
      'email':          email,
      'updatedAt':      FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateSiteEngineerProfile({
    required String name,
    required String qualification,
    required String specialization,
    required String experience,
    required String company,
    required String location,
    required String license,
  }) async {
    await _db.collection('users').doc(_uid).update({
      'name':            name,
      'qualification':   qualification,
      'specialization':  specialization,
      'experience':       experience,
      'company':         company,
      'location':        location,
      'license':         license,
      'isVerified':      license.isNotEmpty,
      'updatedAt':       FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════
  // UTILS
  // ══════════════════════════════════════════
  static Future<String?> getRole() async {
    try {
      final doc = await _db.collection('users').doc(_uid).get();
      return doc.data()?['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> profileExists() async {
    try {
      final doc = await _db.collection('users').doc(_uid).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  static Future<void> signOut() => _auth.signOut();
}