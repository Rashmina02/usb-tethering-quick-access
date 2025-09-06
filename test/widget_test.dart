// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:usbtethering/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const TetheringApp());

    expect(find.text('USB Tethering Quick Access'), findsOneWidget);
    expect(find.text('ENABLE USB TETHERING'), findsOneWidget);
  });
}
