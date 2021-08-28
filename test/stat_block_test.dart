import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';

import 'util/bdd.dart';

final localization = AppLocalizationsEn();

void main() {
  final story = Story("Viewing Character stat block")
    ..asA("user")
    ..iWant("to see the details of a SR5 character")
    ..soThat("I can reference them during a session");

  story.scenario("Open and close chummer5 character file")
    ..given(iAmOnStatBlockPage)
    ..then(iSeeOptionToOpenFile)
    ..when(iOpenFile)
    ..then(iSeeCharacterStatBlock)
    ..when(iCloseStatBlock)
    ..then(iSeeOptionToOpenFile);

  story.execute();
}

final TestStep iAmOnStatBlockPage = TestStep("I am on the Stat Block page", (tester) async {
  // Stat Block page is home page - do nothing
});

final TestStep iSeeOptionToOpenFile = TestStep("I see an option to open file", (tester) async {
  expect(find.text(localization.load_file_instructions), findsOneWidget);
  expect(
    find.descendant(
      of: find.byType(FloatingActionButton),
      matching: find.byIcon(Icons.add),
    ),
    findsOneWidget,
  );
});

final TestStep iOpenFile = TestStep("I open a character file", (tester) async {
  await tester.tap(find.byIcon(Icons.add));
  await Future.delayed(Duration(milliseconds: 250)); // Opening file will spawn an isolate and we have to wait on it in real time, 1/4 sec should be enough.
  await tester.pumpAndSettle();
  // Disconnected mode automatically returns the test character file without further interaction
});

final TestStep iSeeCharacterStatBlock = TestStep("I see the character's stat block", (tester) async {
  expect(find.text("NAME: TESTFORD"), findsOneWidget);
  expect(find.text("METATYPE: PIXIE"), findsOneWidget);
  expect(find.text("Physical 6, Mental 8, Social 8"), findsOneWidget);
});

final TestStep iCloseStatBlock = TestStep("I close the stat block", (tester) async {
  await tester.tap(find.byIcon(Icons.more_vert));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.close));
  await tester.pumpAndSettle();
});
