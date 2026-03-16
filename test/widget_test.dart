import 'package:architecthup/features/auth/presentation/providers/auth_provider.dart';
import 'package:architecthup/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:architecthup/features/projects/presentation/screens/projects_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard foundation renders real sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWith((ref) => null)],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Project summary'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Active projects'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Active projects'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Upcoming work'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Upcoming work'), findsOneWidget);
  });

  testWidgets('projects foundation renders list structure', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: ProjectsListScreen())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Search projects'), findsOneWidget);
    expect(find.text('North Gate Residences'), findsOneWidget);
  });
}
