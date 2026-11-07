import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../core/widgets/student_avatar.dart';
import '../../../data/repositories/student_repository.dart';

/// Highly Professional, Dedicated WhatsApp Parent Alert View
/// Features:
/// - Student Identity Header Card with live contact status
/// - Parent / Guardian WhatsApp phone input with one-tap database sync
/// - Segmented quick-template switcher (Absent Today, Late Arrival, Low Attendance / Chronic Alert)
/// - Interactive message composer with real-time variable substitutions
/// - Live WhatsApp-style chat bubble preview
/// - Quick template reset / customization mode
/// - Direct "Open in WhatsApp" launcher + clipboard copy fallback
class WhatsAppParentAlertView extends StatefulWidget {
  final Student student;
  final String className;
  final String schoolName;
  final String initialType;
  final String? dateStr;
  final int? absentDays;
  final String? attendancePct;
  final VoidCallback? onPhoneUpdated;

  const WhatsAppParentAlertView({
    super.key,
    required this.student,
    required this.className,
    this.schoolName = 'Govt Primary School Gulbahar No. 1 Peshawar',
    this.initialType = 'absent',
    this.dateStr,
    this.absentDays,
    this.attendancePct,
    this.onPhoneUpdated,
  });

  @override
  State<WhatsAppParentAlertView> createState() => _WhatsAppParentAlertViewState();
}

class _WhatsAppParentAlertViewState extends State<WhatsAppParentAlertView> {
  late TextEditingController _phoneCtrl;
  late TextEditingController _messageCtrl;
  late TextEditingController _templateCtrl;

  late String _activeType;
  bool _isLoading = true;
  bool _isSavingPhone = false;
  bool _isCustomizingTemplate = false;

  @override
  void initState() {
    super.initState();
    _activeType = widget.initialType;
    _phoneCtrl = TextEditingController();
    _messageCtrl = TextEditingController();
    _templateCtrl = TextEditingController();
    _loadInitialData();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    _templateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final studentRepo = Get.find<StudentRepository>();
      final parentContact = await studentRepo.getParentContact(widget.student.id);

      final phone = parentContact?.phoneNumber ?? '+923';
      _phoneCtrl.text = phone;

      final rawTemplate = await WhatsAppHelper.getTemplate(_activeType);
      _templateCtrl.text = rawTemplate;
      _messageCtrl.text = _renderCurrentMessage(rawTemplate);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _renderCurrentMessage(String rawTemplate) {
    return WhatsAppHelper.renderTemplate(
      rawTemplate,
      student: widget.student,
      className: widget.className,
      schoolName: widget.schoolName,
      dateStr: widget.dateStr,
      absentDays: widget.absentDays,
      attendancePct: widget.attendancePct,
    );
  }

  Future<void> _switchType(String newType) async {
    if (_activeType == newType) return;
    setState(() {
      _activeType = newType;
      _isLoading = true;
    });

    try {
      final rawTemplate = await WhatsAppHelper.getTemplate(newType);
      _templateCtrl.text = rawTemplate;
      _messageCtrl.text = _renderCurrentMessage(rawTemplate);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveParentPhone() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty || phone.length < 8) {
      Get.snackbar(
        'Invalid Number',
        'Please enter a valid WhatsApp mobile number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEF3C7),
        colorText: const Color(0xFF92400E),
      );
      return;
    }

    setState(() => _isSavingPhone = true);
    try {
      final studentRepo = Get.find<StudentRepository>();
      await studentRepo.updateStudent(
        existing: widget.student,
        classId: widget.student.classId,
        sectionId: widget.student.sectionId,
        admissionNumber: widget.student.admissionNumber,
        rollNumber: widget.student.rollNumber,
        fullName: widget.student.fullName,
        fatherOrGuardianName: widget.student.fatherOrGuardianName,
        gender: widget.student.gender,
        status: widget.student.status,
        parentPhone: phone,
      );
      widget.onPhoneUpdated?.call();
      Get.snackbar(
        'Phone Number Saved',
        'Updated guardian number for ${widget.student.fullName} to $phone.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF166534),
      );
    } finally {
      if (mounted) setState(() => _isSavingPhone = false);
    }
  }

  Future<void> _saveCustomTemplate() async {
    final tpl = _templateCtrl.text.trim();
    if (tpl.isEmpty) return;

    await WhatsAppHelper.saveTemplate(_activeType, tpl);
    _messageCtrl.text = _renderCurrentMessage(tpl);
    setState(() => _isCustomizingTemplate = false);

    Get.snackbar(
      'Template Saved',
      'Default ${_activeType.toUpperCase()} WhatsApp template saved successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFDCFCE7),
      colorText: const Color(0xFF166534),
    );
  }

  Future<void> _resetToDefaultTemplate() async {
    await WhatsAppHelper.resetTemplatesToDefault();
    final rawTemplate = await WhatsAppHelper.getTemplate(_activeType);
    _templateCtrl.text = rawTemplate;
    _messageCtrl.text = _renderCurrentMessage(rawTemplate);
    setState(() => _isCustomizingTemplate = false);

    Get.snackbar(
      'Templates Reset',
      'Reset all message templates to standard KPK school notifications.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _sendWhatsApp() async {
    final phone = _phoneCtrl.text.trim();
    final text = _messageCtrl.text.trim();
    await WhatsAppHelper.launchWhatsApp(phone: phone, message: text);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'WhatsApp Parent Alert',
          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Copy Message',
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _messageCtrl.text));
              Get.snackbar(
                'Copied',
                'Message text copied to clipboard.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.chat_rounded, size: 20),
            label: const Text(
              'Send Alert via WhatsApp',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            onPressed: _isLoading ? null : _sendWhatsApp,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
              children: [
                // 1. Student Identity Header Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      StudentAvatar(
                        name: s.fullName,
                        photoUrl: s.photoUrl,
                        gender: s.gender,
                        radius: 28,
                        badgeText: s.rollNumber,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Father / Guardian: ${s.fatherOrGuardianName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${widget.className} • Adm #${s.admissionNumber}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Guardian WhatsApp Phone Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Guardian Mobile / WhatsApp Number',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                                decoration: InputDecoration(
                                  hintText: '+923001234567',
                                  prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 18, color: Color(0xFF16A34A)),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryDark,
                                side: const BorderSide(color: AppColors.border, width: 1.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              icon: _isSavingPhone
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save_outlined, size: 17),
                              label: const Text('Save', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                              onPressed: _isSavingPhone ? null : _saveParentPhone,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Alert Type Segment Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Alert Type',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                        ),
                        InkWell(
                          onTap: () => setState(() => _isCustomizingTemplate = !_isCustomizingTemplate),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isCustomizingTemplate ? Icons.visibility_outlined : Icons.tune_rounded,
                                  size: 15,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isCustomizingTemplate ? 'View Message' : 'Customize Template',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _typePill(
                          id: 'absent',
                          label: 'Absent Today',
                          urdu: 'غیر حاضری',
                          icon: Icons.cancel_outlined,
                          color: AppColors.absent,
                        ),
                        const SizedBox(width: 8),
                        _typePill(
                          id: 'late',
                          label: 'Late Arrival',
                          urdu: 'تاخیر سے آمد',
                          icon: Icons.access_time_rounded,
                          color: AppColors.late,
                        ),
                        const SizedBox(width: 8),
                        _typePill(
                          id: 'chronic',
                          label: 'Low Attendance',
                          urdu: 'حاضری کی کمی',
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. Message Editor or Customizer
                if (_isCustomizingTemplate) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 16, color: Color(0xFF2563EB)),
                            SizedBox(width: 6),
                            Text(
                              'Edit Default Pattern',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Placeholders: {student_name}, {father_name}, {roll_no}, {class_name}, {date}, {school_name}, {absent_days}, {attendance_pct}',
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _templateCtrl,
                          maxLines: 6,
                          style: const TextStyle(fontSize: 12.5),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _resetToDefaultTemplate,
                              child: const Text('Reset Defaults', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Save Pattern', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              onPressed: _saveCustomTemplate,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF16A34A)),
                            SizedBox(width: 6),
                            Text(
                              'Message Preview (Editable Before Sending)',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // WhatsApp Chat Bubble Preview
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCF8C6).withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF86EFAC).withValues(alpha: 0.5)),
                          ),
                          child: TextField(
                            controller: _messageCtrl,
                            maxLines: 7,
                            style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF0F172A)),
                            decoration: const InputDecoration.collapsed(hintText: 'Type message...'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // 5. KPK E&SED Compliance Notice
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 18, color: Color(0xFF1D4ED8)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Direct parent communication complies with Khyber Pakhtunkhwa School Attendance Tracking Guidelines.',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _typePill({
    required String id,
    required String label,
    required String urdu,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _activeType == id;
    return Expanded(
      child: InkWell(
        onTap: () => _switchType(id),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : const Color(0xFF64748B)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? color : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                urdu,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
