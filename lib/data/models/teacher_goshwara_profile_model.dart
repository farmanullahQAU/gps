import 'package:drift/drift.dart';

/// Extended Teacher Profile for KPK Monthly Goshwara / School Performance Report
class TeacherGoshwaraProfile {
  final String userId;
  final String fatherName; // ولدیت
  final String personalNo; // پرسنل نمبر (e.g. 00459800 or 'Personal No. Not Yet Alloted')
  final String dob; // تاریخ پیدائش (e.g. 12-Oct-1986)
  final String academicQualification; // تعلیمی قابلیت (e.g. BA, B.Sc, M.Sc, M.Phil)
  final String professionalQualification; // پیشہ ورانہ قابلیت (e.g. PTC, B.Ed, M.Ed, Induction Training)
  final String appointmentDate; // تاریخ آغاز ملازمت (e.g. 19-Nov-2008)
  final String transferInDate; // تاریخ تبادلہ اسکول ہذا (e.g. 27-Mar-2026)
  final String currentBps; // موجودہ اسکیل (e.g. 15, 14, 12, 03)
  final String bpsAwardDate; // تاریخ موجودہ اسکیل لینے کی (e.g. 26-Mar-2026)
  final double basicPay; // بنیادی تنخواہ (In PKR, e.g. 59670)
  final String village; // گاؤں (e.g. باٹن, خویندو, شولڑی, کاڑکبنج, اخگرام)
  final String unionCouncil; // یونین کونسل / تحصیل (e.g. واڑی)
  final String district; // ضلع (e.g. دیر بالا)
  final String employmentType; // 'permanent' (مستقل) | 'fixed' (عارضی)
  final int updatedAt;
  final int revision;

  const TeacherGoshwaraProfile({
    required this.userId,
    this.fatherName = '',
    this.personalNo = '',
    this.dob = '',
    this.academicQualification = 'BA',
    this.professionalQualification = 'PTC / B.Ed',
    this.appointmentDate = '',
    this.transferInDate = '',
    this.currentBps = '14',
    this.bpsAwardDate = '',
    this.basicPay = 0.0,
    this.village = '',
    this.unionCouncil = '',
    this.district = 'Dir Upper',
    this.employmentType = 'permanent',
    this.updatedAt = 0,
    this.revision = 1,
  });

  bool get isPermanent => employmentType.toLowerCase() == 'permanent';

  factory TeacherGoshwaraProfile.fromRow(QueryRow row) {
    return TeacherGoshwaraProfile(
      userId: row.readNullable<String>('user_id') ?? '',
      fatherName: row.readNullable<String>('father_name') ?? '',
      personalNo: row.readNullable<String>('personal_no') ?? '',
      dob: row.readNullable<String>('dob') ?? '',
      academicQualification: row.readNullable<String>('academic_qualification') ?? '',
      professionalQualification: row.readNullable<String>('professional_qualification') ?? '',
      appointmentDate: row.readNullable<String>('appointment_date') ?? '',
      transferInDate: row.readNullable<String>('transfer_in_date') ?? '',
      currentBps: row.readNullable<String>('current_bps') ?? '14',
      bpsAwardDate: row.readNullable<String>('bps_award_date') ?? '',
      basicPay: row.readNullable<double>('basic_pay') ?? 0.0,
      village: row.readNullable<String>('village') ?? '',
      unionCouncil: row.readNullable<String>('union_council') ?? '',
      district: row.readNullable<String>('district') ?? 'Dir Upper',
      employmentType: row.readNullable<String>('employment_type') ?? 'permanent',
      updatedAt: row.readNullable<int>('updated_at') ?? 0,
      revision: row.readNullable<int>('revision') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'father_name': fatherName,
        'personal_no': personalNo,
        'dob': dob,
        'academic_qualification': academicQualification,
        'professional_qualification': professionalQualification,
        'appointment_date': appointmentDate,
        'transfer_in_date': transferInDate,
        'current_bps': currentBps,
        'bps_award_date': bpsAwardDate,
        'basic_pay': basicPay,
        'village': village,
        'union_council': unionCouncil,
        'district': district,
        'employment_type': employmentType,
        'updated_at': updatedAt,
        'revision': revision,
      };

  TeacherGoshwaraProfile copyWith({
    String? userId,
    String? fatherName,
    String? personalNo,
    String? dob,
    String? academicQualification,
    String? professionalQualification,
    String? appointmentDate,
    String? transferInDate,
    String? currentBps,
    String? bpsAwardDate,
    double? basicPay,
    String? village,
    String? unionCouncil,
    String? district,
    String? employmentType,
    int? updatedAt,
    int? revision,
  }) {
    return TeacherGoshwaraProfile(
      userId: userId ?? this.userId,
      fatherName: fatherName ?? this.fatherName,
      personalNo: personalNo ?? this.personalNo,
      dob: dob ?? this.dob,
      academicQualification: academicQualification ?? this.academicQualification,
      professionalQualification: professionalQualification ?? this.professionalQualification,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      transferInDate: transferInDate ?? this.transferInDate,
      currentBps: currentBps ?? this.currentBps,
      bpsAwardDate: bpsAwardDate ?? this.bpsAwardDate,
      basicPay: basicPay ?? this.basicPay,
      village: village ?? this.village,
      unionCouncil: unionCouncil ?? this.unionCouncil,
      district: district ?? this.district,
      employmentType: employmentType ?? this.employmentType,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
    );
  }
}
