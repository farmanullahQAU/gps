import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:drift/native.dart';
import 'package:gps/core/database/app_database.dart';
import 'package:gps/data/repositories/auth_repository.dart';
import 'package:gps/modules/auth/auth_controller.dart';
import 'package:gps/modules/auth/views/login_view.dart';

void main() {
  testWidgets('App renders login view when unauthenticated', (WidgetTester tester) async {
    Get.testMode = true;
    final db = AppDatabase(NativeDatabase.memory());
    final authRepo = AuthRepository(db);
    Get.put(AuthController(authRepo));

    await tester.pumpWidget(MaterialApp(home: LoginView()));
    await tester.pump();

    expect(find.text('School Attendance Portal'), findsOneWidget);
    expect(find.text('Smart Attendance & Student Management'), findsOneWidget);
    expect(find.text('SIGN IN TO PORTAL'), findsOneWidget);

    Get.reset();
    await db.close();
  });
}
