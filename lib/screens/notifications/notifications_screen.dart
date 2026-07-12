import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/job_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String type) {
    switch (type) {
      case 'new_applicant': return Icons.person_add_alt_1;
      case 'shortlisted':   return Icons.celebration_outlined;
      case 'rejected':      return Icons.info_outline;
      case 'completed':     return Icons.task_alt;
      case 'rating':        return Icons.star_outline;
      case 'qs_request':    return Icons.fact_check_outlined;
      case 'qs_approved':   return Icons.verified_outlined;
      case 'qs_rejected':   return Icons.cancel_outlined;
      case 'booking':       return Icons.home_repair_service_outlined;
      default:               return Icons.notifications_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'shortlisted':
      case 'completed':
      case 'rating':
      case 'qs_approved':
      case 'new_applicant':
      case 'booking':
        return const Color(0xFFF15A29);
      case 'rejected':
      case 'qs_rejected':
        return Colors.red;
      case 'qs_request':
        return const Color(0xFFD4A857);
      default:
        return const Color(0xFFF15A29);
    }
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'இப்போதுதான்';
    if (diff.inMinutes < 60) return '${diff.inMinutes}நி முன்பு';
    if (diff.inHours < 24) return '${diff.inHours}மணி முன்பு';
    if (diff.inDays < 7) return '${diff.inDays}நாள் முன்பு';
    final d = ts.toDate();
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A72),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => JobService.markAllNotificationsRead(),
            child: const Text('Mark all read', style: TextStyle(color: Color(0xFFF15A29), fontSize: 12)),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: JobService.getMyNotifications(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFF15A29)));
            }
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.notifications_none, color: Colors.white24, size: 64),
                    const SizedBox(height: 16),
                    const Text('இன்னும் notifications இல்லை',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 14)),
                  ]),
                ),
              );
            }

            final docs = snap.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final doc = docs[i];
                final data = doc.data() as Map<String, dynamic>;
                final type = data['type'] ?? 'default';
                final isRead = data['isRead'] ?? false;
                final c = _colorFor(type);

                return GestureDetector(
                  onTap: () {
                    if (!isRead) JobService.markNotificationRead(doc.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isRead ? const Color(0xFF2E3D90) : c.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isRead ? Colors.white12 : c.withOpacity(0.3)),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: c.withOpacity(0.15), shape: BoxShape.circle),
                        child: Icon(_iconFor(type), color: c, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(data['title'] ?? '',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                                color: isRead ? Colors.white70 : Colors.white))),
                            if (!isRead) Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          Text(data['message'] ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.white54, height: 1.4)),
                          const SizedBox(height: 6),
                          Text(_timeAgo(data['createdAt'] as Timestamp?),
                            style: const TextStyle(fontSize: 10, color: Colors.white30)),
                        ]),
                      ),
                    ]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}