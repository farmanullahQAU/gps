import 'package:drift/drift.dart';

/// Extended KPK E&SED School Settings Model & Monthly Performance Goshwara Specifications
class SchoolSettingsModel {
  final String schoolId;
  final String schoolType; // 'GPS' (Boys) | 'GGPS' (Girls) | 'GCMPS'
  final String district; // e.g. 'Peshawar', 'Dir Upper', 'Swat', etc.
  final String tehsil;
  final String circleOffice; // ASDEO Circle / Sub-division
  final String unionCouncil;
  final String climateZone; // 'summer_zone' | 'winter_zone'
  final String openingTime; // HH:mm
  final String closingTime; // HH:mm
  final String lateCutoffTime; // HH:mm
  final String headTeacherName;
  final String deoName;
  final String circleSdeoName; // نام سرکل SDEO
  final String centerInchargeName; // نام سنٹر انچارج
  final String goshwaraNo; // گوشوارہ نمبر
  final String naConstituency; // قومی اسمبلی حلقہ (e.g. NA-5)
  final String pkConstituency; // صوبائی اسمبلی حلقہ (e.g. PK-12)
  final String ltrcCenter; // LTRC / سنٹر
  final int sanctionedPostsPsht; // کل منظور شدہ اسامیاں PSHT (1)
  final int sanctionedPostsSpst; // SPST (4)
  final int sanctionedPostsPst; // PST (4)
  final int vacantPostsPst; // خالی اسامیاں PST (3)
  final int vacantPostsChowkidar; // خالی اسامیاں چوکیدار (1)
  final int classroomsInstructional; // تدریسی کمروں کی تعداد
  final int classroomsNonInstructional; // غیر تدریسی کمروں کی تعداد
  final String establishmentYear; // سالِ تعمیر / تاریخ اجراء
  final String constructionYear; // سالِ تعمیر
  final bool facilityElectricity; // بجلی
  final bool facilityWaterPipe; // پانی نلکا / پائپ
  final bool facilityWaterWell; // پانی کنواں / چشمہ
  final bool facilitySolar; // سولر پلانٹ
  final bool facilityBoundaryWall; // چاردیواری
  final bool facilityPlayArea; // پلے ایریا
  final bool facilityOffice; // دفتر
  final int facilityToiletCount; // تعداد گروپ لیٹرین
  final String ptcChairmanName; // چیئرمین کا نام
  final String ptcBankName; // بینک کا نام (e.g. HBL Akhagram)
  final String ptcAccountNo; // بینک اکاؤنٹ نمبر
  final String ptcSanctionDate; // تاریخ اجراء PTC
  final double fundTotalBudget; // اکاؤنٹ بیلنس (In PKR)
  final double fundTotalSpent; // خرچ شدہ رقم
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
    this.headTeacherName = 'Head Teacher',
    this.deoName = 'DEO Peshawar',
    this.circleSdeoName = '',
    this.centerInchargeName = '',
    this.goshwaraNo = '01',
    this.naConstituency = 'NA-5',
    this.pkConstituency = 'PK-12',
    this.ltrcCenter = 'Akhagram',
    this.sanctionedPostsPsht = 1,
    this.sanctionedPostsSpst = 4,
    this.sanctionedPostsPst = 4,
    this.vacantPostsPst = 0,
    this.vacantPostsChowkidar = 0,
    this.classroomsInstructional = 3,
    this.classroomsNonInstructional = 0,
    this.establishmentYear = '1976',
    this.constructionYear = '1987',
    this.facilityElectricity = true,
    this.facilityWaterPipe = true,
    this.facilityWaterWell = false,
    this.facilitySolar = true,
    this.facilityBoundaryWall = true,
    this.facilityPlayArea = false,
    this.facilityOffice = true,
    this.facilityToiletCount = 2,
    this.ptcChairmanName = '',
    this.ptcBankName = 'HBL',
    this.ptcAccountNo = '',
    this.ptcSanctionDate = '',
    this.fundTotalBudget = 0.0,
    this.fundTotalSpent = 0.0,
    this.workingDaysCsv = '1,2,3,4,5,6',
    this.updatedAt = 0,
    this.revision = 1,
  });

  double get fundRemainingBalance => (fundTotalBudget - fundTotalSpent).clamp(0.0, double.infinity);
  int get totalSanctionedPosts => sanctionedPostsPsht + sanctionedPostsSpst + sanctionedPostsPst;

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
      circleSdeoName: row.readNullable<String>('circle_sdeo_name') ?? '',
      centerInchargeName: row.readNullable<String>('center_incharge_name') ?? '',
      goshwaraNo: row.readNullable<String>('goshwara_no') ?? '01',
      naConstituency: row.readNullable<String>('na_constituency') ?? '',
      pkConstituency: row.readNullable<String>('pk_constituency') ?? '',
      ltrcCenter: row.readNullable<String>('ltrc_center') ?? '',
      sanctionedPostsPsht: row.readNullable<int>('sanctioned_posts_psht') ?? 1,
      sanctionedPostsSpst: row.readNullable<int>('sanctioned_posts_spst') ?? 4,
      sanctionedPostsPst: row.readNullable<int>('sanctioned_posts_pst') ?? 4,
      vacantPostsPst: row.readNullable<int>('vacant_posts_pst') ?? 0,
      vacantPostsChowkidar: row.readNullable<int>('vacant_posts_chowkidar') ?? 0,
      classroomsInstructional: row.readNullable<int>('classrooms_instructional') ?? 3,
      classroomsNonInstructional: row.readNullable<int>('classrooms_non_instructional') ?? 0,
      establishmentYear: row.readNullable<String>('establishment_year') ?? '',
      constructionYear: row.readNullable<String>('construction_year') ?? '',
      facilityElectricity: (row.readNullable<int>('facility_electricity') ?? 1) == 1,
      facilityWaterPipe: (row.readNullable<int>('facility_water_pipe') ?? 1) == 1,
      facilityWaterWell: (row.readNullable<int>('facility_water_well') ?? 0) == 1,
      facilitySolar: (row.readNullable<int>('facility_solar') ?? 1) == 1,
      facilityBoundaryWall: (row.readNullable<int>('facility_boundary_wall') ?? 1) == 1,
      facilityPlayArea: (row.readNullable<int>('facility_play_area') ?? 0) == 1,
      facilityOffice: (row.readNullable<int>('facility_office') ?? 1) == 1,
      facilityToiletCount: row.readNullable<int>('facility_toilet_count') ?? 2,
      ptcChairmanName: row.readNullable<String>('ptc_chairman_name') ?? '',
      ptcBankName: row.readNullable<String>('ptc_bank_name') ?? '',
      ptcAccountNo: row.readNullable<String>('ptc_account_no') ?? '',
      ptcSanctionDate: row.readNullable<String>('ptc_sanction_date') ?? '',
      fundTotalBudget: (row.readNullable<double>('fund_total_budget') ?? 0.0),
      fundTotalSpent: (row.readNullable<double>('fund_total_spent') ?? 0.0),
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
        'circle_sdeo_name': circleSdeoName,
        'center_incharge_name': centerInchargeName,
        'goshwara_no': goshwaraNo,
        'na_constituency': naConstituency,
        'pk_constituency': pkConstituency,
        'ltrc_center': ltrcCenter,
        'sanctioned_posts_psht': sanctionedPostsPsht,
        'sanctioned_posts_spst': sanctionedPostsSpst,
        'sanctioned_posts_pst': sanctionedPostsPst,
        'vacant_posts_pst': vacantPostsPst,
        'vacant_posts_chowkidar': vacantPostsChowkidar,
        'classrooms_instructional': classroomsInstructional,
        'classrooms_non_instructional': classroomsNonInstructional,
        'establishment_year': establishmentYear,
        'construction_year': constructionYear,
        'facility_electricity': facilityElectricity ? 1 : 0,
        'facility_water_pipe': facilityWaterPipe ? 1 : 0,
        'facility_water_well': facilityWaterWell ? 1 : 0,
        'facility_solar': facilitySolar ? 1 : 0,
        'facility_boundary_wall': facilityBoundaryWall ? 1 : 0,
        'facility_play_area': facilityPlayArea ? 1 : 0,
        'facility_office': facilityOffice ? 1 : 0,
        'facility_toilet_count': facilityToiletCount,
        'ptc_chairman_name': ptcChairmanName,
        'ptc_bank_name': ptcBankName,
        'ptc_account_no': ptcAccountNo,
        'ptc_sanction_date': ptcSanctionDate,
        'fund_total_budget': fundTotalBudget,
        'fund_total_spent': fundTotalSpent,
        'working_days_csv': workingDaysCsv,
        'updated_at': updatedAt,
        'revision': revision,
      };

  SchoolSettingsModel copyWith({
    String? schoolId,
    String? schoolType,
    String? district,
    String? tehsil,
    String? circleOffice,
    String? unionCouncil,
    String? climateZone,
    String? openingTime,
    String? closingTime,
    String? lateCutoffTime,
    String? headTeacherName,
    String? deoName,
    String? circleSdeoName,
    String? centerInchargeName,
    String? goshwaraNo,
    String? naConstituency,
    String? pkConstituency,
    String? ltrcCenter,
    int? sanctionedPostsPsht,
    int? sanctionedPostsSpst,
    int? sanctionedPostsPst,
    int? vacantPostsPst,
    int? vacantPostsChowkidar,
    int? classroomsInstructional,
    int? classroomsNonInstructional,
    String? establishmentYear,
    String? constructionYear,
    bool? facilityElectricity,
    bool? facilityWaterPipe,
    bool? facilityWaterWell,
    bool? facilitySolar,
    bool? facilityBoundaryWall,
    bool? facilityPlayArea,
    bool? facilityOffice,
    int? facilityToiletCount,
    String? ptcChairmanName,
    String? ptcBankName,
    String? ptcAccountNo,
    String? ptcSanctionDate,
    double? fundTotalBudget,
    double? fundTotalSpent,
    String? workingDaysCsv,
    int? updatedAt,
    int? revision,
  }) {
    return SchoolSettingsModel(
      schoolId: schoolId ?? this.schoolId,
      schoolType: schoolType ?? this.schoolType,
      district: district ?? this.district,
      tehsil: tehsil ?? this.tehsil,
      circleOffice: circleOffice ?? this.circleOffice,
      unionCouncil: unionCouncil ?? this.unionCouncil,
      climateZone: climateZone ?? this.climateZone,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      lateCutoffTime: lateCutoffTime ?? this.lateCutoffTime,
      headTeacherName: headTeacherName ?? this.headTeacherName,
      deoName: deoName ?? this.deoName,
      circleSdeoName: circleSdeoName ?? this.circleSdeoName,
      centerInchargeName: centerInchargeName ?? this.centerInchargeName,
      goshwaraNo: goshwaraNo ?? this.goshwaraNo,
      naConstituency: naConstituency ?? this.naConstituency,
      pkConstituency: pkConstituency ?? this.pkConstituency,
      ltrcCenter: ltrcCenter ?? this.ltrcCenter,
      sanctionedPostsPsht: sanctionedPostsPsht ?? this.sanctionedPostsPsht,
      sanctionedPostsSpst: sanctionedPostsSpst ?? this.sanctionedPostsSpst,
      sanctionedPostsPst: sanctionedPostsPst ?? this.sanctionedPostsPst,
      vacantPostsPst: vacantPostsPst ?? this.vacantPostsPst,
      vacantPostsChowkidar: vacantPostsChowkidar ?? this.vacantPostsChowkidar,
      classroomsInstructional: classroomsInstructional ?? this.classroomsInstructional,
      classroomsNonInstructional: classroomsNonInstructional ?? this.classroomsNonInstructional,
      establishmentYear: establishmentYear ?? this.establishmentYear,
      constructionYear: constructionYear ?? this.constructionYear,
      facilityElectricity: facilityElectricity ?? this.facilityElectricity,
      facilityWaterPipe: facilityWaterPipe ?? this.facilityWaterPipe,
      facilityWaterWell: facilityWaterWell ?? this.facilityWaterWell,
      facilitySolar: facilitySolar ?? this.facilitySolar,
      facilityBoundaryWall: facilityBoundaryWall ?? this.facilityBoundaryWall,
      facilityPlayArea: facilityPlayArea ?? this.facilityPlayArea,
      facilityOffice: facilityOffice ?? this.facilityOffice,
      facilityToiletCount: facilityToiletCount ?? this.facilityToiletCount,
      ptcChairmanName: ptcChairmanName ?? this.ptcChairmanName,
      ptcBankName: ptcBankName ?? this.ptcBankName,
      ptcAccountNo: ptcAccountNo ?? this.ptcAccountNo,
      ptcSanctionDate: ptcSanctionDate ?? this.ptcSanctionDate,
      fundTotalBudget: fundTotalBudget ?? this.fundTotalBudget,
      fundTotalSpent: fundTotalSpent ?? this.fundTotalSpent,
      workingDaysCsv: workingDaysCsv ?? this.workingDaysCsv,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
    );
  }
}
