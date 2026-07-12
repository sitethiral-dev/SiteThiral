import 'package:flutter/material.dart';
import '../../services/job_service.dart';

// ═══════════════════════════════════════════
// BATCH 4B — JOB DETAILS SCREEN
// ═══════════════════════════════════════════
class JobDetailsScreen extends StatelessWidget {
  final String jobId;
  final Map<String, dynamic> job;
  const JobDetailsScreen({super.key, required this.jobId, required this.job});

  @override
  Widget build(BuildContext context) {
    final isUrgent = job['isUrgent'] ?? false;
    return Scaffold(
      backgroundColor: const Color(0xFF080C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080C10),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Job Details', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(job['title'] ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    if ((job['titleTamil'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(job['titleTamil'].toString(),
                          style: const TextStyle(fontSize: 14, color: Color(0xFFD4A857))),
                      ),
                  ]),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A857).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                    child: const Text('URGENT',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD4A857))),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.15)),
              ),
              child: Column(children: [
                _detailRow(Icons.business, 'Company', job['companyName'] ?? '-'),
                const Divider(color: Colors.white12, height: 24),
                _detailRow(Icons.location_on_outlined, 'Location', job['location'] ?? '-'),
                const Divider(color: Colors.white12, height: 24),
                _detailRow(Icons.currency_rupee, 'Wage', job['wage'] ?? '-'),
                const Divider(color: Colors.white12, height: 24),
                _detailRow(Icons.construction, 'Skill Required', job['skill'] ?? '-'),
              ]),
            ),
            const SizedBox(height: 24),

            if ((job['description'] ?? '').toString().isNotEmpty) ...[
              const Text('Description • விவரம்',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF7ECFB3).withOpacity(0.1)),
                ),
                child: Text(job['description'].toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.6)),
              ),
              const SizedBox(height: 28),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await JobService.applyForJob(
                      jobId: jobId,
                      jobTitle: job['title'] ?? '',
                      contractorId: job['contractorId'] ?? '',
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Applied! ✓ Contractor-ku notification போச்சு'),
                        backgroundColor: Color(0xFF7ECFB3)));
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ECFB3),
                  foregroundColor: const Color(0xFF080C10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Apply Now ✓'),
              ),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: const Color(0xFF7ECFB3), size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
      ),
    ]);
  }
}