import 'package:drift/drift.dart';

/// Extended KPK E&SED School Settings Model
class SchoolSettingsModel {
  final String schoolId;
  final String schoolType; // 'GPS' (Boys) | 'GGPS' (Girls) | 'GCMPS'
  final String district; // e.g. 'Peshawar', 'Mardan', 'Swat', 'Abbottabad'
  final String tehsil;
  final String circleOffice; // ASDEO Circle
  final String unionCouncil;
  final String climateZone; // 'summer_zone' | 'winter_zone'
  final String openingTime; // HH:mm
  final String closingTime; // HH:mm
  final String lateCutoffTime; // HH:mm
  final String headTeacherName;
  final String deoName;
  final String workingDaysCsv; // '1,2,3,4,5,6' (Mon-Sat)
  final int updatedAt;
  final int revision;

  const SchoolSettingsModel({
    required this.schoolId,
    this.schoolType = 'GPS',
    this.district = 'Peshawar',
    this.tehsil = 'City Peshawar',
    this.circleOffice = 'ASDEO Circle City-I',
    this.unionCouncil = 'UC-12 Gulbahar',
    this.climateZone = 'summer_zone',
    this.openingTime = '08:00',
    this.closingTime = '13:30',
    this.lateCutoffTime = '08:15',
    this.headTeacherName = 'Head Teacher Muhammad Yousaf Khan',
    this.deoName = 'DEO (Male) Peshawar',
    this.workingDaysCsv = '1,2,3,4,5,6',
    this.updatedAt = 0,
    this.revision = 1,
  });

  factory SchoolSettingsModel.fromRow(QueryRow row) {
    return SchoolSettingsModel(
      schoolId: row.readNullable<String>('school_id') ?? '',
      schoolType: row.readNullable<String>('school_type') ?? 'GPS',
      district: row.readNullable<String>('district') ?? 'Peshawar',
      tehsil: row.readNullable<String>('tehsil') ?? 'City Peshawar',
      circleOffice: row.readNullable<String>('circle_office') ?? 'ASDEO Circle City-I',
      unionCouncil: row.readNullable<String>('union_council') ?? 'UC-12',
      climateZone: row.readNullable<String>('climate_zone') ?? 'summer_zone',
      openingTime: row.readNullable<String>('opening_time') ?? '08:00',
      closingTime: row.readNullable<String>('closing_time') ?? '13:30',
      lateCutoffTime: row.readNullable<String>('late_cutoff_time') ?? '08:15',
      headTeacherName: row.readNullable<String>('head_teacher_name') ?? 'Head Teacher',
      deoName: row.readNullable<String>('deo_name') ?? 'District Education Officer',
      workingDaysCsv: row.readNullable<String>('working_days_csv') ?? '1,2,3,4,5,6',
      updatedAt: row.readNullable<int>('updated_at') ?? 0,
      revision: row.readNullable<int>('revision') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'school_id': schoolId,
        'school_type': schoolType,
        'district': district,
        'tehsil': tehsil,
        'circle_office': circleOffice,
        'union_council': unionCouncil,
        'climate_zone': climateZone,
        'opening_time': openingTime,
        'closing_time': closingTime,
        'late_cutoff_time': lateCutoffTime,
        'head_teacher_name': headTeacherName,
        'deo_name': deoName,
        'working_days_csv': workingDaysCsv,
        'updated_at': updatedAt,
        'revision': revision,
      };
}
