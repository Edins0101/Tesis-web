import 'package:flutter_test/flutter_test.dart';

import 'package:tesis_web/main.dart';

void main() {
  testWidgets('Dashboard renders key sections', (WidgetTester tester) async {
    await tester.pumpWidget(const DashboardApp());

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Aplicar Filtros'), findsOneWidget);
    expect(find.text('Total accesos'), findsOneWidget);
  });
}
