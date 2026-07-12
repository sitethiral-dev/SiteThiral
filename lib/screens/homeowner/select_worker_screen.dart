import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/job_service.dart';
import 'book_service_screen.dart';

// ═══════════════════════════════════════════
// SELECT WORKER — Homeowner picks who to book
// ═══════════════════════════════════════════
class SelectWorkerScreen extends StatelessWidget {
  final String serviceName;
  final String serviceNameTamil;
  final String skillKeyword; // e.g. "Plumber" — matched against worker's skill field

  const SelectWorkerScreen({
    super.key,
    required this.serviceName,
    required this.serviceNameTamil,
    required this.skillKeyword,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A72),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('Select $serviceName Worker', style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: JobService.getAllWorkers(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFF15A29)));
            }
            if (!snap.hasData) {
              return _empty();
            }
            final workers = snap.data!.docs.where((d) {
              final data = d.data() as Map<String, dynamic>;
              final skill = (data['skill'] ?? '').toString().toLowerCase();
              return skill.contains(skillKeyword.toLowerCase());
            }).toList();

            if (workers.isEmpty) {
              return _empty();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: workers.length,
              itemBuilder: (context, i) {
                final doc = workers[i];
                final data = doc.data() as Map<String, dynamic>;
                final rating = (data['rating'] ?? 0.0).toDouble();
                final totalJobs = data['totalJobs'] ?? 0;
                final isVerified = data['isVerified'] ?? false;
                final dailyRate = data['dailyRate'] ?? '';
                final location = data['location'] ?? '';
                final skill = data['skill'] ?? '';
                final phone = data['phone'] ?? '';
                final name = data['name'] ?? 'Worker';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3D90),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.1)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.person, color: Color(0xFFF15A29), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            if (isVerified) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), borderRadius: BorderRadius.circular(5)),
                                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.verified, color: Color(0xFFF15A29), size: 10),
                                  SizedBox(width: 2),
                                  Text('Verified', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
                                ]),
                              ),
                            ],
                          ]),
                          Text(skill.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFFD4A857))),
                          const SizedBox(height: 4),
                          if (totalJobs > 0)
                            Row(children: [
                              ...List.generate(5, (idx) => Icon(
                                idx < rating.round() ? Icons.star : Icons.star_border,
                                color: const Color(0xFFD4A857), size: 13)),
                              const SizedBox(width: 6),
                              Text('($totalJobs jobs)', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                            ])
                          else
                            const Text('New worker', style: TextStyle(fontSize: 11, color: Colors.white38)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      if (location.toString().isNotEmpty) ...[
                        const Icon(Icons.location_on, size: 13, color: Colors.white38),
                        const SizedBox(width: 4),
                        Expanded(child: Text(location.toString(), style: const TextStyle(fontSize: 12, color: Colors.white54))),
                      ],
                      if (dailyRate.toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('Rs.$dailyRate/day', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF15A29))),
                        ),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BookServiceScreen(
                            serviceName: serviceName,
                            serviceNameTamil: serviceNameTamil,
                            workerId: doc.id,
                            workerName: name.toString(),
                            workerPhone: phone.toString(),
                            workerSkill: skill.toString(),
                            workerDailyRate: dailyRate.toString(),
                          )));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF15A29),
                          foregroundColor: const Color(0xFF1C2A72),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Book இவரை ✓', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.person_search, color: Colors.white24, size: 56),
          const SizedBox(height: 16),
          Text('இப்போதைக்கு "$serviceName" worker இல்லை\nகொஞ்சம் wait பண்ணுங்கள்!',
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 14, height: 1.6)),
        ]),
      ),
    );
  }
}