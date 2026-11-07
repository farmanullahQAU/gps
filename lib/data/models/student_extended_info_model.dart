import 'dart:convert';
import 'package:drift/drift.dart';

/// Extended KPK Student Metadata (Form-B, Father CNIC, Leaving/SLC Date, Free Textbooks, Revoked QR History)
class StudentExtendedInfoModel {
  final String studentId;
  final String? studentBForm;
  final String? fatherCnic;
  final String? motherName;
  final String? domicileDistrict;
  final String? leavingDate; // YYYY-MM-DD
  final String? leavingReason;
  final String? slcNumber; // School Leaving Certificate No
  final bool freeBooksIssued;
  final bool isVaccinated;
  final String? vaccineFirstDoseDate;
  final String? vaccineSecondDoseDate;
  final List<String> revokedQrTokens;
  final int updatedAt;
  final int revision;

  const StudentExtendedInfoModel({
    required this.studentId,
    this.studentBForm,
    this.fatherCnic,
    this.motherName,
    this.domicileDistrict,
    this.leavingDate,
    this.leavingReason,
    this.slcNumber,
    this.freeBooksIssued = true,
    this.isVaccinated = false,
    this.vaccineFirstDoseDate,
    this.vaccineSecondDoseDate,
    this.revokedQrTokens = const [],
    this.updatedAt = 0,
    this.revision = 1,
  });

  factory StudentExtendedInfoModel.fromRow(QueryRow row) {
    final rawTokens = row.readNullable<String>('previous_qr_tokens_json') ?? '[]';
    List<String> parsedTokens = [];
    try {
      parsedTokens = (jsonDecode(rawTokens) as List).map((e) => e.toString()).toList();
    } catch (_) {}

    return StudentExtendedInfoModel(
      studentId: row.readNullable<String>('student_id') ?? '',
      studentBForm: row.readNullable<String>('student_b_form'),
      fatherCnic: row.readNullable<String>('father_cnic'),
      motherName: row.readNullable<String>('mother_name'),
      domicileDistrict: row.readNullable<String>('domicile_district'),
      leavingDate: row.readNullable<String>('leaving_date'),
      leavingReason: row.readNullable<String>('leaving_reason'),
      slcNumber: row.readNullable<String>('slc_number'),
      freeBooksIssued: (row.readNullable<int>('free_books_issued') ?? 1) == 1,
      isVaccinated: (row.readNullable<int>('is_vaccinated') ?? 0) == 1,
      vaccineFirstDoseDate: row.readNullable<String>('vaccine_first_dose_date'),
      vaccineSecondDoseDate: row.readNullable<String>('vaccine_second_dose_date'),
      revokedQrTokens: parsedTokens,
      updatedAt: row.readNullable<int>('updated_at') ?? 0,
      revision: row.readNullable<int>('revision') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'student_b_form': studentBForm,
        'father_cnic': fatherCnic,
        'mother_name': motherName,
        'domicile_district': domicileDistrict,
        'leaving_date': leavingDate,
        'leaving_reason': leavingReason,
        'slc_number': slcNumber,
        'free_books_issued': freeBooksIssued ? 1 : 0,
        'is_vaccinated': isVaccinated ? 1 : 0,
        'vaccine_first_dose_date': vaccineFirstDoseDate,
        'vaccine_second_dose_date': vaccineSecondDoseDate,
        'previous_qr_tokens_json': revokedQrTokens,
        'updated_at': updatedAt,
        'revision': revision,
      };
}
