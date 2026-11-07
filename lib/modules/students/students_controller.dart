import 'package:get/get.dart';
import '../../core/database/app_database.dart';
import '../../data/repositories/student_repository.dart';
import '../attendance/attendance_controller.dart';
import '../auth/auth_controller.dart';

class StudentsController extends GetxController {
  final StudentRepository studentRepository;

  StudentsController(this.studentRepository);

  final RxList<Student> students = <Student>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'active'.obs; // 'active' | 'all' | 'transferred' | 'graduated' | 'inactive'
  final Rx<Student?> selectedStudent = Rx<Student?>(null);
  final Rx<ParentContact?> selectedParent = Rx<ParentContact?>(null);

  void resetState() {
    students.clear();
    selectedStudent.value = null;
    selectedParent.value = null;
    searchQuery.value = '';
    statusFilter.value = 'active';
  }

  @override
  void onInit() {
    super.onInit();
    final attendanceCtrl = Get.find<AttendanceController>();
    ever(attendanceCtrl.selectedClass, (_) => loadStudents());
    ever(attendanceCtrl.selectedSection, (_) => loadStudents());
    loadStudents();
  }

  Future<void> loadStudents() async {
    final attendanceCtrl = Get.find<AttendanceController>();
    final authCtrl = Get.find<AuthController>();
    final cls = attendanceCtrl.selectedClass.value;
    final sec = attendanceCtrl.selectedSection.value;
    final schoolId = authCtrl.currentUser.value?.schoolId;
    if (schoolId == null || schoolId.isEmpty) {
      resetState();
      return;
    }

    isLoading.value = true;
    try {
      final list = await studentRepository.searchStudents(
        schoolId: schoolId,
        classId: cls?.id,
        sectionId: sec?.id,
        query: searchQuery.value,
        statusFilter: statusFilter.value,
      );
      students.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectStudent(Student student) async {
    selectedStudent.value = student;
    selectedParent.value = await studentRepository.getParentContact(student.id);
  }

  Future<bool> registerStudent({
    required String admissionNumber,
    String? rollNumber,
    required String fullName,
    required String fatherName,
    required String gender,
    String? dateOfBirth,
    String? admissionDate,
    required String parentPhone,
    String? studentCnic,
    String? studentBForm,
    String? fatherCnic,
    String? photoUrl,
    bool isVaccinated = false,
    String? vaccineFirstDoseDate,
    String? vaccineSecondDoseDate,
  }) async {
    final attendanceCtrl = Get.find<AttendanceController>();
    final authCtrl = Get.find<AuthController>();

    final cls = attendanceCtrl.selectedClass.value;
    final sec = attendanceCtrl.selectedSection.value;
    final schoolId = authCtrl.currentUser.value?.schoolId ?? 'sch_demo_gps_001';

    if (cls == null || sec == null) {
      Get.snackbar('Error', 'Please select a class and section first.');
      return false;
    }

    try {
      isLoading.value = true;
      final student = await studentRepository.createStudent(
        schoolId: schoolId,
        classId: cls.id,
        sectionId: sec.id,
        admissionNumber: admissionNumber,
        rollNumber: rollNumber,
        fullName: fullName,
        fatherOrGuardianName: fatherName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        admissionDate: admissionDate ?? DateTime.now().toIso8601String().substring(0, 10),
        parentPhone: parentPhone,
        studentCnic: studentCnic,
        studentBForm: studentBForm,
        fatherCnic: fatherCnic,
        photoUrl: photoUrl,
        isVaccinated: isVaccinated,
        vaccineFirstDoseDate: vaccineFirstDoseDate,
        vaccineSecondDoseDate: vaccineSecondDoseDate,
      );

      await loadStudents();
      await attendanceCtrl.loadStudentsAndAttendance();
      Get.snackbar('Student Enrolled', 'Student ${student.fullName} registered with secure QR credential.');
      return true;
    } catch (e) {
      Get.snackbar('Enrollment Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateExistingStudent({
    required Student existing,
    required String classId,
    required String sectionId,
    required String admissionNumber,
    String? rollNumber,
    required String fullName,
    required String fatherName,
    required String gender,
    String? dateOfBirth,
    required String status,
    String? parentPhone,
    String? studentCnic,
    String? studentBForm,
    String? fatherCnic,
    String? photoUrl,
    bool? isVaccinated,
    String? vaccineFirstDoseDate,
    String? vaccineSecondDoseDate,
    String? slcNumber,
  }) async {
    final attendanceCtrl = Get.find<AttendanceController>();
    try {
      isLoading.value = true;
      await studentRepository.updateStudent(
        existing: existing,
        classId: classId,
        sectionId: sectionId,
        admissionNumber: admissionNumber,
        rollNumber: rollNumber,
        fullName: fullName,
        fatherOrGuardianName: fatherName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        status: status,
        parentPhone: parentPhone,
        studentCnic: studentCnic,
        studentBForm: studentBForm,
        fatherCnic: fatherCnic,
        photoUrl: photoUrl,
        isVaccinated: isVaccinated,
        vaccineFirstDoseDate: vaccineFirstDoseDate,
        vaccineSecondDoseDate: vaccineSecondDoseDate,
        slcNumber: slcNumber,
      );
      await loadStudents();
      await attendanceCtrl.loadStudentsAndAttendance();
      Get.snackbar('Student Updated', 'Updated record for $fullName (historical attendance preserved).');
      return true;
    } catch (e) {
      Get.snackbar('Update Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Student?> rotateQrCode(Student student) async {
    final attendanceCtrl = Get.find<AttendanceController>();
    try {
      isLoading.value = true;
      final updated = await studentRepository.rotateStudentQrToken(student);
      selectedStudent.value = updated;
      await loadStudents();
      await attendanceCtrl.loadStudentsAndAttendance();
      Get.snackbar(
        'QR Credential Rotated',
        'Issued new QR token for ${updated.fullName}. Previous card token is now revoked.',
      );
      return updated;
    } catch (e) {
      Get.snackbar('Rotation Failed', e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> importStudentsFromCsv(String csvContent) async {
    final attendanceCtrl = Get.find<AttendanceController>();
    final authCtrl = Get.find<AuthController>();
    final cls = attendanceCtrl.selectedClass.value;
    final sec = attendanceCtrl.selectedSection.value;
    final schoolId = authCtrl.currentUser.value?.schoolId ?? 'sch_demo_gps_001';

    try {
      isLoading.value = true;
      final count = await studentRepository.bulkImportCsv(
        schoolId: schoolId,
        classId: cls?.id,
        sectionId: sec?.id,
        csvContent: csvContent,
      );
      await loadStudents();
      await attendanceCtrl.loadStudentsAndAttendance();
      Get.snackbar(
        'Excel / CSV Import Complete',
        'Successfully imported and enrolled $count student(s).',
        snackPosition: SnackPosition.BOTTOM,
      );
      return count;
    } finally {
      isLoading.value = false;
    }
  }

  /// 1-Tap populate 30 sample students across Class 1 to 5 (6 per class)
  Future<int> populateSampleStudents() async {
    final authCtrl = Get.find<AuthController>();
    final attendanceCtrl = Get.find<AttendanceController>();
    final schoolId = authCtrl.currentUser.value?.schoolId ?? 'sch_demo_gps_001';

    try {
      isLoading.value = true;
      final count = await studentRepository.populateSampleRosterForSchool(schoolId);
      await loadStudents();
      await attendanceCtrl.loadStudentsAndAttendance();
      Get.snackbar(
        'Sample Roster Populated',
        'Enrolled $count sample students across Classes 1 to 5 with full profiles and QR credentials.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return count;
    } finally {
      isLoading.value = false;
    }
  }
}
