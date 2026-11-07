import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/student_avatar.dart';
import '../students_controller.dart';

class StudentIdCardView extends StatefulWidget {
  final Student student;
  final String schoolName;
  final String className;
  final String sectionName;

  const StudentIdCardView({
    super.key,
    required this.student,
    required this.schoolName,
    required this.className,
    required this.sectionName,
  });

  @override
  State<StudentIdCardView> createState() => _StudentIdCardViewState();
}

class _StudentIdCardViewState extends State<StudentIdCardView> {
  late Student _currentStudent;

  @override
  void initState() {
    super.initState();
    _currentStudent = widget.student;
  }

  Future<void> _printIdCardPdf() async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Center(
          child: pw.Container(
            width: 260,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.green900, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.green900,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        widget.schoolName,
                        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'GOVT OF KHYBER PAKHTUNKHWA • E&SED',
                        style: pw.TextStyle(color: PdfColors.green100, fontSize: 7, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  _currentStudent.fullName,
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Father: ${_currentStudent.fatherOrGuardianName}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('Class: ${widget.className}', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Roll: ${_currentStudent.rollNumber ?? "-"}', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Adm: ${_currentStudent.admissionNumber}', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: _currentStudent.qrToken,
                  width: 110,
                  height: 110,
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'TOKEN: ${_currentStudent.qrToken}',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Session 2026-27', style: const pw.TextStyle(fontSize: 7.5)),
                    pw.Text('Head Teacher Stamp & Sign', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'KPK_IDCard_${_currentStudent.admissionNumber}.pdf'.replaceAll(' ', '_'),
    );
  }

  void _confirmRotateQr(BuildContext context) {
    final studentsCtrl = Get.find<StudentsController>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.security_update_warning_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Expanded(child: Text('Rotate & Revoke QR Code?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
          'This will generate a new cryptographic QR credential for ${_currentStudent.fullName} and permanently revoke the previous card (${_currentStudent.qrToken}).\n\nIf someone tries to scan the old card, the scanner will alert the teacher.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final updated = await studentsCtrl.rotateQrCode(_currentStudent);
              if (updated != null && mounted) {
                setState(() {
                  _currentStudent = updated;
                });
              }
            },
            child: const Text('Rotate QR & Revoke Old'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Student QR Identity Card'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Rotate / Replace Lost QR Code',
            onPressed: () => _confirmRotateQr(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 325,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF0F5132), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0F5132), Color(0xFF14532D)],
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            widget.schoolName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'GOVT OF KHYBER PAKHTUNKHWA • E&SED',
                            style: TextStyle(
                              color: Color(0xFF86EFAC),
                              fontSize: 8.5,
                              letterSpacing: 0.9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFD97706), width: 2.5),
                          ),
                        ),
                        StudentAvatar(
                          name: _currentStudent.fullName,
                          photoUrl: _currentStudent.photoUrl,
                          gender: _currentStudent.gender,
                          radius: 35,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        _currentStudent.fullName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Father: ${_currentStudent.fatherOrGuardianName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _cardBadge('CLASS', '${widget.className} (${widget.sectionName})'),
                          Container(width: 1, height: 26, color: Colors.grey.shade300),
                          _cardBadge('ROLL NO', _currentStudent.rollNumber ?? '-'),
                          Container(width: 1, height: 26, color: Colors.grey.shade300),
                          _cardBadge('ADMISSION', _currentStudent.admissionNumber),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: _currentStudent.qrToken,
                        version: QrVersions.auto,
                        size: 130.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF0F5132),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'OPAQUE CREDENTIAL: ${_currentStudent.qrToken}',
                      style: TextStyle(fontSize: 8, color: Colors.grey.shade600, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zero personal information encoded in QR payload',
                      style: TextStyle(fontSize: 8, color: Colors.teal.shade700, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SESSION', style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                              const Text('2026-2027 (KPK)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(width: 80, height: 1, color: Colors.grey.shade500),
                              const SizedBox(height: 2),
                              Text('HEAD TEACHER', style: TextStyle(fontSize: 8, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 325,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.print_rounded),
                  label: const Text('PRINT / EXPORT PDF ID CARD', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _printIdCardPdf,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 325,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber.shade900,
                    side: BorderSide(color: Colors.amber.shade800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.key_off_rounded, size: 18),
                  label: const Text('ROTATE LOST QR CREDENTIAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => _confirmRotateQr(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardBadge(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
