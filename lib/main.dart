import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/database/app_database.dart';
import 'core/localization/app_translations.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/attendance_repository.dart';
import 'data/repositories/student_repository.dart';
import 'data/repositories/sync_repository.dart';
import 'data/repositories/saas_repository.dart';
import 'modules/admin/admin_controller.dart';
import 'modules/auth/auth_controller.dart';
import 'modules/attendance/attendance_controller.dart';
import 'modules/sync/sync_controller.dart';
import 'modules/saas/saas_controller.dart';
import 'modules/qr_scanner/qr_scanner_controller.dart';
import 'modules/pdf_reports/pdf_reports_controller.dart';
import 'modules/students/students_controller.dart';
import 'modules/auth/views/login_view.dart';
import 'package:flutter/services.dart';
import 'modules/home/views/main_navigation_shell.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Cloud Messaging & Local Notifications
  await NotificationService.instance.init();

  // Edge-to-edge system navigation & status bar compliance for Android 14/15
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);


  // 1. Initialize SQLite Database
  final database = AppDatabase();

  // 2. Initialize Repositories
  final authRepo = AuthRepository(database);
  final syncRepo = SyncRepository(database, authRepo);
  final attendanceRepo = AttendanceRepository(database, syncRepository: syncRepo);
  final studentRepo = StudentRepository(database, syncRepository: syncRepo);
  final saasRepo = SaasRepository(db: database, authRepository: authRepo);

  // 3. Register Repositories and Controllers in GetX DI
  Get.put(database);
  Get.put(authRepo);
  Get.put(attendanceRepo);
  Get.put(studentRepo);
  Get.put(syncRepo);
  Get.put(saasRepo);

  Get.put(LocaleController());
  Get.put(AuthController(authRepo));
  Get.put(SyncController(syncRepo));
  Get.put(AttendanceController(
    attendanceRepository: attendanceRepo,
    studentRepository: studentRepo,
  ));
  Get.put(QrScannerController(
    studentRepository: studentRepo,
    attendanceRepository: attendanceRepo,
  ));
  Get.put(PdfReportsController(
    attendanceRepository: attendanceRepo,
    studentRepository: studentRepo,
  ));
  Get.put(StudentsController(studentRepo));
  Get.put(AdminController(
    studentRepository: studentRepo,
    attendanceRepository: attendanceRepo,
  ));
  Get.put(SaasController(saasRepository: saasRepo));

  // 4. Check cached session and pre-hydrate core controllers
  final cachedUser = await authRepo.getCachedUser();
  if (cachedUser != null) {
    Get.find<AuthController>().currentUser.value = cachedUser;
    await Get.find<AttendanceController>().loadClasses();
    await Get.find<AdminController>().loadAllAdminData();
    await Get.find<StudentsController>().loadStudents();
  }

  runApp(GPSAttendanceApp(initialLoggedIn: cachedUser != null));
}

class GPSAttendanceApp extends StatelessWidget {
  final bool initialLoggedIn;

  const GPSAttendanceApp({super.key, required this.initialLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GPS KPK Attendance',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppTheme.lightTheme,
      home: initialLoggedIn ? const MainNavigationShell() : LoginView(),
    );
  }
}
