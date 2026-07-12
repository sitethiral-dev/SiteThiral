import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobService {
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static String get _uid => _auth.currentUser?.uid ?? '';

  static const int bookingResponseSeconds = 60;

  // ══════════════════════════════════════════
  // NOTIFICATION CENTER (Option B - Batch D)
  // ══════════════════════════════════════════

  static Future<void> _createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    if (userId.isEmpty) return;
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getMyNotifications() {
    return _db.collection('notifications')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  static Stream<QuerySnapshot> getUnreadNotifications() {
    return _db.collection('notifications')
        .where('userId', isEqualTo: _uid)
        .where('isRead', isEqualTo: false)
        .snapshots();
  }

  static Future<void> markNotificationRead(String notifId) async {
    await _db.collection('notifications').doc(notifId).update({'isRead': true});
  }

  static Future<void> markAllNotificationsRead() async {
    final unread = await _db.collection('notifications')
        .where('userId', isEqualTo: _uid)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in unread.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  // ── POST A JOB (Contractor) ──────────────────
  static Future<void> postJob({
    required String title,
    required String titleTamil,
    required String skill,
    required String wage,
    required String location,
    required String description,
    required bool isUrgent,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final userDoc = await _db.collection('users').doc(_uid).get();
    final companyName = userDoc.data()?['companyName'] ?? 'Unknown Company';
    await _db.collection('jobs').add({
      'title': title,
      'titleTamil': titleTamil,
      'skill': skill,
      'wage': wage,
      'location': location,
      'description': description,
      'isUrgent': isUrgent,
      'companyName': companyName,
      'contractorId': _uid,
      'status': 'open',
      'applicants': [],
      'postedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getOpenJobs() {
    return _db.collection('jobs')
        .where('status', isEqualTo: 'open')
        .orderBy('postedAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getMyJobs() {
    return _db.collection('jobs')
        .where('contractorId', isEqualTo: _uid)
        .orderBy('postedAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getMyApplicants() {
    return _db.collection('applications')
        .where('contractorId', isEqualTo: _uid)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  static Future<void> applyForJob({
    required String jobId,
    required String jobTitle,
    required String contractorId,
  }) async {
    final userDoc = await _db.collection('users').doc(_uid).get();
    final workerName     = userDoc.data()?['name']      ?? 'Unknown';
    final workerSkill    = userDoc.data()?['skill']     ?? '';
    final workerPhone    = userDoc.data()?['phone']     ?? '';
    final workerDailyRate = userDoc.data()?['dailyRate'] ?? '0';

    final contractorDoc = await _db.collection('users').doc(contractorId).get();
    final contractorPhone = contractorDoc.data()?['phone']       ?? '';
    final companyName     = contractorDoc.data()?['companyName'] ?? '';

    await _db.collection('applications').add({
      'jobId': jobId,
      'jobTitle': jobTitle,
      'workerId': _uid,
      'workerName': workerName,
      'workerSkill': workerSkill,
      'workerPhone': workerPhone,
      'workerDailyRate': workerDailyRate,
      'contractorId': contractorId,
      'contractorPhone': contractorPhone,
      'companyName': companyName,
      'status': 'pending',
      'appliedAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('jobs').doc(jobId).update({
      'applicants': FieldValue.arrayUnion([_uid]),
    });

    await _createNotification(
      userId: contractorId,
      title: 'New Applicant! 👋',
      message: '$workerName applied for "$jobTitle"',
      type: 'new_applicant',
    );
  }

  static Stream<QuerySnapshot> getMyApplications() {
    return _db.collection('applications')
        .where('workerId', isEqualTo: _uid)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (_uid.isEmpty) return null;
    final doc = await _db.collection('users').doc(_uid).get();
    return doc.data();
  }

  // ══════════════════════════════════════════
  // HOMEOWNER SERVICE BOOKING (now supports picking a specific worker)
  // ══════════════════════════════════════════
  static Future<void> bookService({
    required String serviceName,
    required String serviceNameTamil,
    required String date,
    required String time,
    required String address,
    required String description,
    String? workerId,
    String? workerName,
    String? workerPhone,
  }) async {
    final userDoc = await _db.collection('users').doc(_uid).get();
    final homeownerName  = userDoc.data()?['name']  ?? 'Unknown';
    final homeownerPhone = userDoc.data()?['phone'] ?? '';

    await _db.collection('service_requests').add({
      'homeownerId': _uid,
      'homeownerName': homeownerName,
      'homeownerPhone': homeownerPhone,
      'serviceName': serviceName,
      'serviceNameTamil': serviceNameTamil,
      'date': date,
      'time': time,
      'address': address,
      'description': description,
      'workerId': workerId ?? '',
      'workerName': workerName ?? '',
      'workerPhone': workerPhone ?? '',
      'status': (workerId != null && workerId.isNotEmpty) ? 'requested' : 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
      'expiresAt': (workerId != null && workerId.isNotEmpty)
          ? Timestamp.fromDate(DateTime.now().add(const Duration(seconds: bookingResponseSeconds)))
          : null,
    });

    if (workerId != null && workerId.isNotEmpty) {
      await _createNotification(
        userId: workerId,
        title: 'New Booking Request! 🏠',
        message: '$homeownerName உங்களை "$serviceName"-க்கு book பண்ணிருக்காங்க ($date, $time). Call: +91 $homeownerPhone',
        type: 'booking',
      );
    }
  }

  static Stream<QuerySnapshot> getMyServiceRequests() {
    return _db.collection('service_requests')
        .where('homeownerId', isEqualTo: _uid)
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  // Homeowner browses all workers — UI filters client-side by skill keyword
  static Stream<QuerySnapshot> getAllWorkers() {
    return _db.collection('users').where('role', isEqualTo: 'worker').snapshots();
  }

  // ══════════════════════════════════════════
  // BOOKING STATUS FLOW (NEW)
  // requested → accepted/rejected/expired → payment_pending
  //   → in_progress → completed/cancelled
  // ══════════════════════════════════════════

  // Worker sees bookings waiting for their Accept/Reject
  static Stream<QuerySnapshot> getPendingBookingsForWorker() {
    return _db.collection('service_requests')
        .where('workerId', isEqualTo: _uid)
        .where('status', isEqualTo: 'requested')
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  // Homeowner watches a single booking's live status
  static Stream<DocumentSnapshot> watchBooking(String bookingId) {
    return _db.collection('service_requests').doc(bookingId).snapshots();
  }

  // Homeowner sees all their bookings (any status)
  static Stream<QuerySnapshot> getMyBookings() {
    return _db.collection('service_requests')
        .where('homeownerId', isEqualTo: _uid)
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  // Worker Accepts or Rejects within the response window
  static Future<void> respondToBooking(String bookingId, bool accept) async {
    final doc = await _db.collection('service_requests').doc(bookingId).get();
    final data = doc.data();
    if (data == null) return;

    // Guard: don't let a stale accept/reject fire after expiry
    final expiresAt = data['expiresAt'] as Timestamp?;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt.toDate())) {
      await _db.collection('service_requests').doc(bookingId).update({'status': 'expired'});
      return;
    }

    final newStatus = accept ? 'accepted' : 'rejected';
    await _db.collection('service_requests').doc(bookingId).update({'status': newStatus});

    final homeownerId = data['homeownerId'] as String? ?? '';
    final serviceName = data['serviceName'] as String? ?? 'Service';
    final workerDoc = await _db.collection('users').doc(_uid).get();
    final workerName = workerDoc.data()?['name'] ?? 'Worker';

    await _createNotification(
      userId: homeownerId,
      title: accept ? 'Booking Accepted! ✓' : 'Booking Declined',
      message: accept
          ? '$workerName உங்கள் "$serviceName" booking-ஐ accept பண்ணிருக்காங்க'
          : '$workerName இந்த booking-ஐ ஏற்கவில்லை. வேறு worker தேடுங்கள்.',
      type: accept ? 'booking_accepted' : 'booking_rejected',
    );
  }

  // Called when the 60-sec window has passed and worker never responded
  static Future<void> checkAndExpireBooking(String bookingId) async {
    final doc = await _db.collection('service_requests').doc(bookingId).get();
    final data = doc.data();
    if (data == null) return;
    if (data['status'] != 'requested') return; // already responded

    final expiresAt = data['expiresAt'] as Timestamp?;
    if (expiresAt == null || DateTime.now().isBefore(expiresAt.toDate())) return;

    await _db.collection('service_requests').doc(bookingId).update({'status': 'expired'});

    final homeownerId = data['homeownerId'] as String? ?? '';
    final serviceName = data['serviceName'] as String? ?? 'Service';
    await _createNotification(
      userId: homeownerId,
      title: 'Booking Expired ⏱️',
      message: 'Worker respond பண்ணல. "$serviceName"-க்கு வேறு worker தேடுங்கள்.',
      type: 'booking_expired',
    );
  }

  // STUB: skips real Razorpay for now — moves accepted → payment_pending → in_progress
  // Replace the body of this with a real Razorpay charge once KYC is live.
  static Future<void> confirmBookingPaymentStub(String bookingId) async {
    await _db.collection('service_requests').doc(bookingId).update({
      'status': 'in_progress',
      'paymentStatus': 'stub_skipped', // mark clearly so we know it's fake data
    });
  }

  // Homeowner marks the work finished
  static Future<void> completeBooking(String bookingId) async {
    final doc = await _db.collection('service_requests').doc(bookingId).get();
    final data = doc.data();
    if (data == null) return;

    await _db.collection('service_requests').doc(bookingId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });

    final workerId = data['workerId'] as String? ?? '';
    if (workerId.isNotEmpty) {
      await _db.collection('users').doc(workerId).update({
        'totalJobs': FieldValue.increment(1),
      });
      await _createNotification(
        userId: workerId,
        title: 'Booking Completed! ✓',
        message: 'Work complete ஆச்சுனு homeowner confirm பண்ணிருக்காங்க. Rate பண்ணுங்கள்!',
        type: 'booking_completed',
      );
    }
  }

  // Homeowner or worker cancels before completion
  static Future<void> cancelBooking(String bookingId, String cancelledByRole) async {
    final doc = await _db.collection('service_requests').doc(bookingId).get();
    final data = doc.data();
    if (data == null) return;

    await _db.collection('service_requests').doc(bookingId).update({'status': 'cancelled'});

    final notifyUserId = cancelledByRole == 'homeowner'
        ? (data['workerId'] as String? ?? '')
        : (data['homeownerId'] as String? ?? '');
    if (notifyUserId.isNotEmpty) {
      await _createNotification(
        userId: notifyUserId,
        title: 'Booking Cancelled',
        message: 'இந்த booking cancel ஆகிடுச்சு.',
        type: 'booking_cancelled',
      );
    }
  }

  // ══════════════════════════════════════════
  // SITE ENGINEER — REAL DATA
  // ══════════════════════════════════════════
  static Stream<QuerySnapshot> getSitesByCompany(String company) {
    return _db.collection('jobs')
        .where('companyName', isEqualTo: company)
        .orderBy('postedAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getShortlistedWorkersByCompany(String company) {
    return _db.collection('applications')
        .where('companyName', isEqualTo: company)
        .where('status', isEqualTo: 'shortlisted')
        .snapshots();
  }

  static String _todayStr() {
    final t = DateTime.now();
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }

  static Future<void> markAttendance({
    required String jobId,
    required String workerId,
    required String workerName,
    required String companyName,
    required String status,
  }) async {
    final docId = '${jobId}_${workerId}_${_todayStr()}';
    await _db.collection('attendance').doc(docId).set({
      'jobId': jobId,
      'workerId': workerId,
      'workerName': workerName,
      'companyName': companyName,
      'date': _todayStr(),
      'status': status,
      'markedBy': _uid,
      'markedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<DocumentSnapshot> getAttendanceStatus(String jobId, String workerId) {
    final docId = '${jobId}_${workerId}_${_todayStr()}';
    return _db.collection('attendance').doc(docId).snapshots();
  }

  static Stream<QuerySnapshot> getTodayAttendance(String companyName) {
    return _db.collection('attendance')
        .where('companyName', isEqualTo: companyName)
        .where('date', isEqualTo: _todayStr())
        .snapshots();
  }

  // ══════════════════════════════════════════
  // EDIT / CLOSE JOB + MARK COMPLETED (NEW - Batch A)
  // ══════════════════════════════════════════

  // Contractor edits an existing job
  static Future<void> updateJob({
    required String jobId,
    required String title,
    required String titleTamil,
    required String skill,
    required String wage,
    required String location,
    required String description,
    required bool isUrgent,
  }) async {
    await _db.collection('jobs').doc(jobId).update({
      'title': title,
      'titleTamil': titleTamil,
      'skill': skill,
      'wage': wage,
      'location': location,
      'description': description,
      'isUrgent': isUrgent,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Close or reopen a job. status = 'open' or 'closed'
  static Future<void> setJobStatus(String jobId, String status) async {
    await _db.collection('jobs').doc(jobId).update({'status': status});
  }

  // Contractor shortlists/rejects an applicant — also notifies the worker
  static Future<void> updateApplicationStatus(String applicationId, String newStatus) async {
    final appDoc = await _db.collection('applications').doc(applicationId).get();
    final data = appDoc.data();

    await _db.collection('applications').doc(applicationId).update({'status': newStatus});

    if (data == null) return;
    final workerId = data['workerId'] as String? ?? '';
    final jobTitle = data['jobTitle'] as String? ?? '';
    final companyName = data['companyName'] as String? ?? 'Contractor';

    if (newStatus == 'shortlisted') {
      await _createNotification(
        userId: workerId,
        title: 'Shortlisted! 🎉',
        message: '$companyName shortlisted you for "$jobTitle"',
        type: 'shortlisted',
      );
    } else if (newStatus == 'rejected') {
      await _createNotification(
        userId: workerId,
        title: 'Application Update',
        message: '$companyName-ல "$jobTitle" application accept ஆகல',
        type: 'rejected',
      );
    }
  }

  // Contractor marks a shortlisted application as job-completed.
  // Also bumps worker totalJobs (+auto-verify) and contractor totalHired.
  static Future<void> markApplicationCompleted(String applicationId) async {
    final appDoc = await _db.collection('applications').doc(applicationId).get();
    final data = appDoc.data();
    if (data == null) return;

    await _db.collection('applications').doc(applicationId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });

    final workerId = data['workerId'] as String?;
    final contractorId = data['contractorId'] as String?;
    final jobTitle = data['jobTitle'] as String? ?? '';
    final companyName = data['companyName'] as String? ?? 'Contractor';

    if (workerId != null && workerId.isNotEmpty) {
      await _db.collection('users').doc(workerId).update({
        'totalJobs': FieldValue.increment(1),
        'isVerified': true, // earned by completing a real job through the platform
      });
      await _createNotification(
        userId: workerId,
        title: 'Job Completed! ✓',
        message: '"$jobTitle" ($companyName) complete ஆச்சு. Rate பண்ணுங்கள்!',
        type: 'completed',
      );
    }
    if (contractorId != null && contractorId.isNotEmpty) {
      await _db.collection('users').doc(contractorId).update({
        'totalHired': FieldValue.increment(1),
      });
    }
  }

  // ══════════════════════════════════════════
  // RATING & REVIEW SYSTEM (Batch B)
  // ══════════════════════════════════════════

  // Deterministic doc id so a person can only rate once per application
  // (re-submitting just overwrites their own earlier rating).
  static String _ratingDocId(String applicationId, String fromUserId) => '${applicationId}_$fromUserId';

  static Future<void> submitRating({
    required String toUserId,
    required String applicationId,
    required int rating,
    String review = '',
  }) async {
    final fromUserId = _uid;
    final fromDoc = await _db.collection('users').doc(fromUserId).get();
    final fromName = fromDoc.data()?['name'] ?? fromDoc.data()?['companyName'] ?? 'Someone';

    await _db.collection('ratings').doc(_ratingDocId(applicationId, fromUserId)).set({
      'fromUserId': fromUserId,
      'fromName': fromName,
      'toUserId': toUserId,
      'applicationId': applicationId,
      'rating': rating,
      'review': review,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Recompute the target's average rating from all their ratings
    final allRatings = await _db.collection('ratings').where('toUserId', isEqualTo: toUserId).get();
    final values = allRatings.docs.map((d) => (d.data()['rating'] as num).toDouble()).toList();
    final avg = values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;

    await _db.collection('users').doc(toUserId).update({
      'rating': avg,
      'totalRatings': values.length,
    });

    await _createNotification(
      userId: toUserId,
      title: 'New Rating! ⭐',
      message: '$fromName rated you $rating stars',
      type: 'rating',
    );
  }

  // Check if the current user already rated this application (avoids duplicate prompt)
  static Future<bool> hasRatedApplication(String applicationId) async {
    final doc = await _db.collection('ratings').doc(_ratingDocId(applicationId, _uid)).get();
    return doc.exists;
  }

  // ══════════════════════════════════════════
  // WAGE / PAYROLL TRACKING (Batch B)
  // Reads this month's attendance for a company and
  // groups it per worker: present/absent/late counts
  // + payable amount (present+late days x dailyRate).
  // ══════════════════════════════════════════
  static Future<List<Map<String, dynamic>>> getMonthlyPayroll(String company) async {
    final now = DateTime.now();
    final startStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final nextMonth = now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
    final endStr = '${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}-01';

    final snap = await _db.collection('attendance')
        .where('companyName', isEqualTo: company)
        .where('date', isGreaterThanOrEqualTo: startStr)
        .where('date', isLessThan: endStr)
        .get();

    final Map<String, Map<String, dynamic>> grouped = {};
    for (final doc in snap.docs) {
      final d = doc.data();
      final wId = d['workerId'] as String? ?? '';
      final wName = d['workerName'] as String? ?? '';
      final status = d['status'] as String? ?? '';
      grouped.putIfAbsent(wId, () => {'workerId': wId, 'workerName': wName, 'present': 0, 'absent': 0, 'late': 0});
      if (status == 'present') grouped[wId]!['present'] = (grouped[wId]!['present'] as int) + 1;
      if (status == 'absent') grouped[wId]!['absent'] = (grouped[wId]!['absent'] as int) + 1;
      if (status == 'late') grouped[wId]!['late'] = (grouped[wId]!['late'] as int) + 1;
    }

    // Fetch each worker's daily rate to compute payable amount
    final List<Map<String, dynamic>> result = [];
    for (final entry in grouped.values) {
      final workerId = entry['workerId'] as String;
      double rate = 0;
      if (workerId.isNotEmpty) {
        final userDoc = await _db.collection('users').doc(workerId).get();
        rate = double.tryParse((userDoc.data()?['dailyRate'] ?? '0').toString()) ?? 0;
      }
      final payableDays = (entry['present'] as int) + (entry['late'] as int);
      result.add({
        ...entry,
        'dailyRate': rate,
        'payableDays': payableDays,
        'totalPayable': payableDays * rate,
      });
    }
    return result;
  }

  // ══════════════════════════════════════════
  // QS / ADMIN — TEAM MANAGEMENT
  // ══════════════════════════════════════════

  // Contractor: see who requested to join their company
  static Stream<QuerySnapshot> getPendingQsRequests(String company) {
    return _db.collection('users')
        .where('role', isEqualTo: 'qs_admin')
        .where('requestedCompany', isEqualTo: company)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Contractor: see approved team members under their company
  static Stream<QuerySnapshot> getApprovedQsTeam(String company) {
    return _db.collection('users')
        .where('role', isEqualTo: 'qs_admin')
        .where('requestedCompany', isEqualTo: company)
        .where('status', isEqualTo: 'approved')
        .snapshots();
  }

  // Contractor approves with chosen permission level: 'full' or 'attendance_only'
  static Future<void> approveQsRequest(String userId, String permissionLevel) async {
    await _db.collection('users').doc(userId).update({
      'status': 'approved',
      'permissionLevel': permissionLevel,
      'approvedBy': _uid,
      'approvedAt': FieldValue.serverTimestamp(),
    });
    await _createNotification(
      userId: userId,
      title: 'Approved! ✓',
      message: 'உங்கள் request approve ஆச்சு — ${permissionLevel == 'full' ? 'Full Access' : 'Attendance Only'} கிடைச்சுது',
      type: 'qs_approved',
    );
  }

  static Future<void> rejectQsRequest(String userId) async {
    await _db.collection('users').doc(userId).update({
      'status': 'rejected',
    });
    await _createNotification(
      userId: userId,
      title: 'Request Update',
      message: 'உங்கள் join request accept ஆகல',
      type: 'qs_rejected',
    );
  }

  // Contractor can revoke an already-approved QS/Admin's access
  static Future<void> revokeQsAccess(String userId) async {
    await _db.collection('users').doc(userId).update({
      'status': 'rejected',
      'permissionLevel': null,
    });
  }
  // ══════════════════════════════════════════
  // WORKER AVAILABILITY TOGGLE
  // ══════════════════════════════════════════
  static Future<void> setWorkerAvailability(bool isAvailable) async {
    await _db.collection('users').doc(_uid).update({'isAvailable': isAvailable});
  }
}