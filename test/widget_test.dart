import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:camera_app2/main.dart';

void main() {
  testWidgets('Test bouton Prendre une photo présent', (WidgetTester tester) async {
    // Simule une caméra fictive
    final fakeCamera = CameraDescription(
      name: '0',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    );

    await tester.pumpWidget(MyApp(camera: fakeCamera));

    // Cherche le bouton "Prendre une photo"
    expect(find.text('Prendre une photo'), findsOneWidget);
  });
}
