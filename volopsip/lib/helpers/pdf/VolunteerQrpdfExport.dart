import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr/qr.dart';
import 'package:pdf/pdf.dart';   
import 'package:volopsip/models/volunteer.dart';

class VolunteerQrPdfExport {
  static Future<void> export(List<Volunteer> volunteers) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (context) {
          return [
            pw.Wrap(
              spacing: 20,
              runSpacing: 20,
              children: volunteers.map((v) {
                return pw.Container(
                  width: 120,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      // QR code from UUID
                      pw.BarcodeWidget(
                        data: v.uuid,
                        barcode: pw.Barcode.qrCode(),
                        width: 80,
                        height: 80,
                      ),
                      pw.SizedBox(height: 8),
                      // Full name
                      pw.Text(
                        '${v.lastName}, ${v.firstName}',
                        style: pw.TextStyle(
                          color: PdfColors.black,   
                          fontSize: 18,
                          font: pw.Font.helvetica(),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}