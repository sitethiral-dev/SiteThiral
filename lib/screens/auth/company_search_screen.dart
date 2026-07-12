import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'site_engineer_signup.dart';

class CompanySearchScreen extends StatefulWidget {
  const CompanySearchScreen({super.key});
  @override
  State<CompanySearchScreen> createState() => _CompanySearchScreenState();
}

class _CompanySearchScreenState extends State<CompanySearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A72),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A72), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Company தேடுங்கள்', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(color: const Color(0xFF2E3D90), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.2))),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Company name தேடுங்கள்',
                    hintStyle: TextStyle(color: Colors.white30),
                    prefixIcon: Icon(Icons.search, color: Color(0xFFF15A29)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'contractor').snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFF15A29)));
                    }
                    final docs = snap.data!.docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final name = (data['companyName'] ?? '').toString().toLowerCase();
                      return _query.isEmpty || name.contains(_query);
                    }).toList();

                    if (docs.isEmpty) {
                      return const Center(child: Text('Company kidaikala', style: TextStyle(color: Colors.white54)));
                    }

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final companyName = data['companyName'] ?? 'Unknown';
                        final location = data['location'] ?? '';
                        return Material(
                          color: const Color(0xFF2E3D90),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (_) => SiteEngineerSignupScreen(
                                  linkedCompanyId: docs[i].id,
                                  linkedCompanyName: companyName,
                                ),
                              ));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF15A29).withOpacity(0.15))),
                              child: Row(children: [
                                Container(width: 44, height: 44,
                                  decoration: BoxDecoration(color: const Color(0xFFF15A29).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.business, color: Color(0xFFF15A29), size: 22)),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(companyName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                  if (location.toString().isNotEmpty)
                                    Text(location, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                ])),
                                const Icon(Icons.arrow_forward_ios, color: Color(0xFFF15A29), size: 13),
                              ]),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}