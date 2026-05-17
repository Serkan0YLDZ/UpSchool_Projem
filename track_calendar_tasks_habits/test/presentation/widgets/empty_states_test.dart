import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_calendar_tasks_habits/core/widgets/empty_state_widget.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_theme.dart';

void main() {
  testWidgets('EmptyStateWidget doğru mesaj ve ikonu gösterir', (WidgetTester tester) async {
    // Arrange
    const testMessage = 'Hiçbir görev bulunamadı';
    const testIcon = Icons.inbox_rounded;
    
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: EmptyStateWidget(
            message: testMessage,
            icon: testIcon,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text(testMessage), findsOneWidget);
    expect(find.byIcon(testIcon), findsOneWidget);
    
    // Emoji olmaması gerektiğini doğrulama (Sadece IconData kullanılıyor)
    // Eğer bir Text widget'ı içinde emoji olsaydı, bunu da kontrol edebilirdik.
    // Ancak EmptyStateWidget doğrudan bir IconData aldığı için kural (FR-06) sağlanmış oluyor.
  });

  testWidgets('EmptyStateWidget CTA butonu gösterir ve tıklandığında tetikler', (WidgetTester tester) async {
    // Arrange
    bool isClicked = false;
    
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: EmptyStateWidget(
            message: 'Boş',
            icon: Icons.abc,
            ctaLabel: 'Ekle',
            onCtaPressed: () {
              isClicked = true;
            },
          ),
        ),
      ),
    );

    // Act
    final ctaButton = find.text('Ekle');
    expect(ctaButton, findsOneWidget);
    
    await tester.tap(ctaButton);
    await tester.pump();
    
    // Assert
    expect(isClicked, isTrue);
  });
}
