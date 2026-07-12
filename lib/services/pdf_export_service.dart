import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  static const List<String> _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  // Builds and shows the PDF print/save dialog for a payroll report.
  // Works the same way on Web (browser print/save) and mobile (share sheet).
  static Future<void> exportPayroll({
    required String company,
    required List<Map<String, dynamic>> rows,
  }) async {
    final now = DateTime.now();
    final monthLabel = _months[now.month];
    final grandTotal = rows.fold<double>(0, (s, r) => s + (r['totalPayable'] as double));

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('SiteThiral',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.teal700)),
                      pw.Text('Payroll Report', style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Text('$monthLabel ${now.year}',
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(company, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey800)),
              pw.Divider(color: PdfColors.grey400, thickness: 1),
              pw.SizedBox(height: 16),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1.3),
                  2: pw.FlexColumnWidth(1.3),
                  3: pw.FlexColumnWidth(1.3),
                  4: pw.FlexColumnWidth(1.8),
                  5: pw.FlexColumnWidth(1.8),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.teal50),
                    children: [
                      _headerCell('Worker'),
                      _headerCell('Present'),
                      _headerCell('Late'),
                      _headerCell('Absent'),
                      _headerCell('Rate/Day'),
                      _headerCell('Payable'),
                    ],
                  ),
                  ...rows.map((r) {
                    final rate = (r['dailyRate'] as double);
                    final payable = (r['totalPayable'] as double);
                    return pw.TableRow(children: [
                      _cell(r['workerName'] ?? ''),
                      _cell('${r['present']}'),
                      _cell('${r['late']}'),
                      _cell('${r['absent']}'),
                      _cell('Rs.${rate.toStringAsFixed(0)}'),
                      _cell('Rs.${payable.toStringAsFixed(0)}'),
                    ]);
                  }),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.teal50,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text('Total Payable:  Rs.${grandTotal.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                ),
              ),

              pw.SizedBox(height: 40),
              pw.Divider(color: PdfColors.grey300),
              pw.Text(
                'Generated on ${now.day}/${now.month}/${now.year} at ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} via SiteThiral',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          );
        },
      ),
    );

    final fileName = 'payroll_${company.replaceAll(' ', '_')}_${monthLabel}_${now.year}.pdf';
    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: fileName,
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
    );
  }

  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }
}