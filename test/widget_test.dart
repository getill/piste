import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp_intro/main.dart';

void main() {
  testWidgets('Affiche les deux candidatures et les commandes du TP 1', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Piste'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.text('Développeur Flutter junior'), findsOneWidget);
    expect(find.text('Atelier Mobile · Envoyée'), findsOneWidget);
    expect(find.text('Développeuse web en alternance'), findsOneWidget);
    expect(find.text('Studio Numérique · Entretien'), findsOneWidget);
    expect(find.text('Ajouter'), findsOneWidget);
    expect(find.text('Bilan'), findsOneWidget);

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    expect(
      find.text('Le formulaire sera réalisé dans un prochain TP.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Bilan'));
    await tester.pumpAndSettle();
    expect(
      find.text('Le bilan sera réalisé dans un prochain TP.'),
      findsOneWidget,
    );
  });

  testWidgets('Reste lisible et défilant sur un petit écran', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.text('Développeur Flutter junior').hitTestable(),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -120));
    await tester.pumpAndSettle();
    expect(
      find.text('Développeuse web en alternance').hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
