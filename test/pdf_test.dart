import 'package:flutter_test/flutter_test.dart';
import 'package:gps/core/database/app_database.dart';
import 'package:gps/core/utils/kpk_register_helper.dart';
import 'package:gps/modules/pdf_reports/pdf_generator_service.dart';

void main() {
  test('PDF reports generate offline successfully with correct bytes & eligible days calculation', () async {
    final school = School(
      id: 'sch_1',
      name: 'GPS Gulbahar No. 1 Peshawar',
      code: 'EMIS-12405',
      academicYearStart: '2026-04-01',
      academicYearEnd: '2027-03-31',
      createdAt: 0,
      updatedAt: 0,
      revision: 1,
    );

    final schoolClass = ClassesData(
      id: 'cls_1',
      schoolId: 'sch_1',
      name: 'Class 1 (اول)',
      numericLevel: 1,
      createdAt: 0,
      updatedAt: 0,
      revision: 1,
    );

    final section = Section(
      id: 'sec_1',
      schoolId: 'sch_1',
      classId: 'cls_1',
      name: 'Section A',
      createdAt: 0,
      updatedAt: 0,
      revision: 1,
    );

    final students = [
      Student(
        id: 'std_1',
        schoolId: 'sch_1',
        classId: 'cls_1',
        sectionId: 'sec_1',
        admissionNumber: 'KPK-2026-001',
        rollNumber: '1',
        fullName: 'Muhammad Haris Khan',
        fatherOrGuardianName: 'Asfandyar Khan',
        gender: 'male',
        admissionDate: '2026-04-01',
        status: 'active',
        qrToken: 'KPK_QR_1',
        isVaccinated: false,
        isDeleted: false,
        createdAt: 0,
        updatedAt: 0,
        revision: 1,
      ),
      Student(
        id: 'std_2',
        schoolId: 'sch_1',
        classId: 'cls_1',
        sectionId: 'sec_1',
        admissionNumber: 'KPK-2026-002',
        rollNumber: '2',
        fullName: 'Fatima Bibi',
        fatherOrGuardianName: 'Zahid Ullah',
        gender: 'female',
        admissionDate: '2026-10-15', // Mid-month admission
        status: 'active',
        qrToken: 'KPK_QR_2',
        isVaccinated: false,
        isDeleted: false,
        createdAt: 0,
        updatedAt: 0,
        revision: 1,
      ),
    ];

    final records = [
      AttendanceRecord(
        id: 'att_1',
        schoolId: 'sch_1',
        studentId: 'std_1',
        classId: 'cls_1',
        sectionId: 'sec_1',
        date: '2026-10-20',
        status: 'present',
        departureTime: 'S1:P|S2:P',
        markedByUserId: 'usr_1',
        markingMethod: 'manual',
        idempotencyKey: 'k1',
        createdAt: 0,
        updatedAt: 0,
        revision: 1,
      ),
      AttendanceRecord(
        id: 'att_2',
        schoolId: 'sch_1',
        studentId: 'std_2',
        classId: 'cls_1',
        sectionId: 'sec_1',
        date: '2026-10-20',
        status: 'absent',
        departureTime: 'S1:A|S2:A',
        markedByUserId: 'usr_1',
        markingMethod: 'manual',
        idempotencyKey: 'k2',
        createdAt: 0,
        updatedAt: 0,
        revision: 1,
      ),
    ];

    final startDate = DateTime(2026, 10, 1);
    final endDate = DateTime(2026, 10, 31);

    // Verify enrollment-date-aware eligible instructional days calculation
    final std1Days = PdfGeneratorService.calculateEligibleInstructionalDays(
      startDate: startDate,
      endDate: endDate,
      holidayDateKeys: {'2026-10-09'},
      studentAdmissionDate: students[0].admissionDate,
    );
    final std2Days = PdfGeneratorService.calculateEligibleInstructionalDays(
      startDate: startDate,
      endDate: endDate,
      holidayDateKeys: {'2026-10-09'},
      studentAdmissionDate: students[1].admissionDate,
    );
    expect(std2Days < std1Days, true);

    // Verify 28, 29, 30, 31-day months & KP E&SED Gazetted Holidays
    expect(KpkMonthlySummary.daysInMonth(2026, 2), 28); // Feb 2026 (non-leap)
    expect(KpkMonthlySummary.daysInMonth(2028, 2), 29); // Feb 2028 (leap year)
    expect(KpkMonthlySummary.daysInMonth(2026, 11), 30); // Nov 2026 (30 days)
    expect(KpkMonthlySummary.daysInMonth(2026, 5), 31); // May 2026 (31 days)

    final holidayKeys = KpkGazettedHolidays.official2026Holidays.map((h) => h.date).toSet();
    expect(holidayKeys.contains('2026-02-05'), true); // Kashmir Solidarity Day
    expect(holidayKeys.contains('2026-03-23'), true); // Pakistan Day & Eid-ul-Fitr
    expect(holidayKeys.contains('2026-05-28'), true); // Youm-e-Takbeer & Eid-ul-Azha
    expect(holidayKeys.contains('2026-06-17'), true); // 1st Muharram KPK Holiday

    // Feb 2026: 28 calendar days, 4 Sundays (Feb 1, 8, 15, 22), 1 Holiday (Feb 5 Kashmir Day) -> 23 Working Days (46 Sessions)
    final febSummary = KpkMonthlySummary.compute(
      students: [students.first],
      records: const [],
      holidayDateKeys: holidayKeys,
      startDate: DateTime(2026, 2, 1),
      endDate: DateTime(2026, 2, 28),
    );
    expect(febSummary.totalCalendarDays, 28);
    expect(febSummary.sundaysCount, 4);
    expect(febSummary.holidaysCount, 1);
    expect(febSummary.workingDays, 23);
    expect(febSummary.totalSchoolSessions, 46);

    // Malakand Summer Zone Winter Break (Jan 1 - Jan 15, 2026): 15 calendar days - 2 Sundays (Jan 4, 11) = 13 non-Sunday closure dates
    final malakandWinterBreak = KpkGazettedHolidays.expandDateRange(
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 1, 15),
      description: 'KP E&SED Winter Vacation (Summer Zone)',
    );
    expect(malakandWinterBreak.length, 13);

    // 1. Test Class Register
    final bytesRegister = await PdfGeneratorService.generateReport(
      type: ReportType.classRegister,
      school: school,
      schoolClass: schoolClass,
      section: section,
      students: students,
      attendanceRecords: records,
      holidays: [],
      startDate: startDate,
      endDate: endDate,
    );
    expect(bytesRegister.isNotEmpty, true);
    expect(bytesRegister.length > 500, true);

    // 2. Test Monthly Matrix
    final bytesMatrix = await PdfGeneratorService.generateReport(
      type: ReportType.monthlyMatrix,
      school: school,
      schoolClass: schoolClass,
      section: section,
      students: students,
      attendanceRecords: records,
      holidays: [],
      startDate: startDate,
      endDate: endDate,
    );
    expect(bytesMatrix.isNotEmpty, true);

    // 3. Test Individual Student
    final bytesStudent = await PdfGeneratorService.generateReport(
      type: ReportType.individualStudent,
      school: school,
      schoolClass: schoolClass,
      section: section,
      students: students,
      attendanceRecords: records,
      holidays: [],
      startDate: startDate,
      endDate: endDate,
      specificStudent: students.first,
    );
    expect(bytesStudent.isNotEmpty, true);

    // 4. Test Daily Sheet
    final bytesDaily = await PdfGeneratorService.generateReport(
      type: ReportType.dailySheet,
      school: school,
      schoolClass: schoolClass,
      section: section,
      students: students,
      attendanceRecords: records,
      holidays: [],
      startDate: DateTime(2026, 10, 20),
      endDate: DateTime(2026, 10, 20),
    );
    expect(bytesDaily.isNotEmpty, true);

    // 5. Test KPK Administrative Summary
    final bytesAdminSummary = await PdfGeneratorService.generateReport(
      type: ReportType.administrativeSummary,
      school: school,
      schoolClass: schoolClass,
      section: section,
      students: students,
      attendanceRecords: records,
      holidays: [],
      startDate: startDate,
      endDate: endDate,
    );
    expect(bytesAdminSummary.isNotEmpty, true);

    // 6. Test Official KPK School Leaving & Character Certificate (SLC / سرٹیفکیٹ داخل خارج)
    TestWidgetsFlutterBinding.ensureInitialized();
    final bytesSlc = await PdfGeneratorService.generateReport(
      type: ReportType.schoolLeavingCertificate,
      school: school,
      schoolClass: schoolClass,
      section: section,
      students: students,
      attendanceRecords: records,
      holidays: [],
      startDate: startDate,
      endDate: endDate,
      specificStudent: students.first,
      customSlcNumber: 'SLC-2026-001',
      customFileNumber: '01/DK-2026',
      customLeavingDate: '07-11-2026',
      customLeavingReason: 'Promoted to Class 6th / تبدیلی مدرسہ',
      customPromotedStatus: 'PROMOTED / کامیاب',
      customConduct: 'EXCELLENT / GOOD',
      isDuplicateSlc: false,
    );
    expect(bytesSlc.isNotEmpty, true);
    expect(bytesSlc.length > 5000, true);

    // 7. Test Official KPK Primary School Monthly Performance Goshwara (ماہانہ گوشوارہ)
    final bytesGoshwara = await PdfGeneratorService.generateReport(
      type: ReportType.monthlyGoshwara,
      school: school,
      schoolClass: schoolClass,
      section: section,
      students: students,
      attendanceRecords: records,
      holidays: [],
      startDate: startDate,
      endDate: endDate,
      adminClassSummaries: [
        const ClassSummaryRow(
          className: 'Class 1',
          sectionName: 'A',
          enrolledCount: 45,
          presentCount: 40,
          absentCount: 5,
          lateCount: 0,
          leaveCount: 0,
          unmarkedCount: 0,
          attendancePercentage: 88.9,
        ),
      ],
      goshwaraTeachers: [
        {
          'sno': 1,
          'name': 'Muhammad Tariq',
          'father': 'Abdul Qayyum',
          'post': 'PST',
          'personal_no': '00124890',
          'cnic': '15302-1234567-1',
          'dob': '15-04-1988',
          'acad': 'M.A',
          'prof': 'B.Ed',
          'appt': '01-09-2012',
          'school_date': '15-08-2018',
          'bps': '14',
          'scale_date': '01-07-2016',
          'pay': '68,500',
          'type': 'Perm',
          'village': 'Gulbahar',
          'tehsil': 'Peshawar City',
          'district': 'Peshawar',
          'phone': '0300-1234567',
        },
      ],
    );
    expect(bytesGoshwara.isNotEmpty, true);
    expect(bytesGoshwara.length > 5000, true);

    // 8. Test Multi-Teacher KPK Primary School Goshwara (> 6 teachers triggers multi-page layout)
    final multiTeachers = List.generate(
      10,
      (i) => {
        'sno': i + 1,
        'name': 'Teacher ${i + 1}',
        'father': 'Father ${i + 1}',
        'post': i == 0 ? 'PSHT' : 'PST',
        'personal_no': '0012489$i',
        'cnic': '15302-123456$i-1',
        'dob': '15-04-1988',
        'acad': 'M.A',
        'prof': 'B.Ed',
        'appt': '01-09-2012',
        'school_date': '15-08-2018',
        'bps': i == 0 ? '15' : '14',
        'scale_date': '01-07-2016',
        'pay': '68,500',
        'type': 'Perm',
        'village': 'Gulbahar',
        'tehsil': 'Peshawar City',
        'district': 'Peshawar',
        'phone': '0300-123456$i',
      },
    );

    final bytesMultiGoshwara = await PdfGeneratorService.generateReport(
      type: ReportType.monthlyGoshwara,
      school: school,
      schoolClass: schoolClass,
      section: section,
      students: students,
      attendanceRecords: records,
      holidays: [],
      startDate: startDate,
      endDate: endDate,
      goshwaraTeachers: multiTeachers,
    );
    expect(bytesMultiGoshwara.isNotEmpty, true);
    expect(bytesMultiGoshwara.length > bytesGoshwara.length, true);
  });
}

