import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/job_service.dart';

// ═══════════════════════════════════════════
// WORKER — Incoming Booking Requests (Accept/Reject)
// No own AppBar — this is embedded as a tab inside WorkerDashboard.
// 60-second countdown per request; auto-expires if ignored.
// ═══════════════════════════════════════════
class BookingRequestsScreen extends StatelessWidget {
  const BookingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Booking Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Homeowner booking requests-க்கு 60 seconds-ல respond பண்ணுங்கள்',
              style: TextStyle(fontSize: 12, color: Colors.white38)),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: JobService.getPendingBookingsForWorker(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFF15A29)));
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.inbox_outlined, color: Colors.white24, size: 56),
                        const SizedBox(height: 16),
                        const Text('இப்போதைக்கு புதிய booking requests இல்லை',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.6)),
                      ]),
                    ),
                  );
                }

                final docs = snap.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) => _BookingCard(doc: docs[i]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _BookingCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  const _BookingCard({required this.doc});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    final data = widget.doc.data() as Map<String, dynamic>;
    final expiresAt = data['expiresAt'] as Timestamp?;
    if (expiresAt == null) return;

    void tick() {
      final remaining = expiresAt.toDate().difference(DateTime.now()).inSeconds;
      if (!mounted) return;
      setState(() => _secondsLeft = remaining > 0 ? remaining : 0);
      if (remaining <= 0) {
        _timer?.cancel();
        JobService.checkAndExpireBooking(widget.doc.id);
      }
    }

    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _respond(bool accept) async {
    setState(() => _acting = true);
    try {
      await JobService.respondToBooking(widget.doc.id, accept);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final serviceName = data['serviceName'] ?? 'Service';
    final homeownerName = data['homeownerName'] ?? 'Homeowner';
    final date = data['date'] ?? '';
    final time = data['time'] ?? '';
    final address = data['address'] ?? '';
    final description = data['description'] ?? '';
    final isUrgentLow = _secondsLeft <= 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3D90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgentLow ? Colors.redAccent.withOpacity(0.5) : const Color(0xFFF15A29).withOpacity(0.2),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(serviceName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isUrgentLow ? Colors.redAccent : const Color(0xFFF15A29)).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.timer_outlined, size: 14, color: isUrgentLow ? Colors.redAccent : const Color(0xFFF15A29)),
              const SizedBox(width: 4),
              Text('${_secondsLeft}s',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isUrgentLow ? Colors.redAccent : const Color(0xFFF15A29))),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.person, size: 15, color: Colors.white54),
          const SizedBox(width: 6),
          Text(homeownerName, style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white54),
          const SizedBox(width: 6),
          Text('$date • $time', style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ]),
        if (address.toString().isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: Colors.white54),
            const SizedBox(width: 6),
            Expanded(child: Text(address.toString(), style: const TextStyle(fontSize: 13, color: Colors.white70))),
          ]),
        ],
        if (description.toString().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(description.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.white38, fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: (_acting || _secondsLeft <= 0) ? null : () => _respond(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reject ✗'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: (_acting || _secondsLeft <= 0) ? null : () => _respond(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15A29),
                foregroundColor: const Color(0xFF1C2A72),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _acting
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1C2A72)))
                  : const Text('Accept ✓', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ]),
    );
  }
}