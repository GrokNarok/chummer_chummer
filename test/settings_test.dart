import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ru.dart';

import 'util/bdd.dart';
import 'stat_block_test.dart';

final localization = AppLocalizationsEn();

void main() {
  final story = Story("App settings")
    ..asA("user")
    ..iWant("to configure the app")
    ..soThat("it can better meet my needs");

  story.scenario("Set locale")
    ..given(iAmOnSettingsPage)
    ..then(iSeeEnglishLabels)
    ..when(iChangeLocaleToRussian)
    ..then(iSeeRussianLabels);

  story.scenario("Set recoil compensation formula")
    ..given(iAmOnStatBlockPage)
    ..given(iHaveOpenedCharacter)
    ..then(iSeeStandardRecoilCompensationValue)
    ..when(iChangeRecoilCompensationSetting)
    ..then(iSeeNewRecoilCompensationValue);

  story.execute();
}

final TestStep iAmOnSettingsPage = TestStep("I am on the Settings page", (tester) async {
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();
});

final TestStep iSeeEnglishLabels = TestStep("I see English labels", (tester) async {
  expect(find.text(localization.locale_label), findsOneWidget);
});

final TestStep iChangeLocaleToRussian = TestStep("I change the locale to Russian", (tester) async {
  var buttonToTap = find.byKey(const Key("default_locale"));
  await tester.dragUntilVisible(buttonToTap, find.byType(Viewport), const Offset(0, 50));
  await tester.tap(buttonToTap);
  await tester.pumpAndSettle();

  buttonToTap = find.text(localization.locale_ru_option).last;
  await tester.dragUntilVisible(buttonToTap, find.byType(Viewport), const Offset(0, 50));
  await tester.tap(buttonToTap);
  await tester.pumpAndSettle();
});

final russianLocalization = AppLocalizationsRu();
final TestStep iSeeRussianLabels = TestStep("I see Russian labels", (tester) async {
  expect(find.text(russianLocalization.locale_label), findsOneWidget);
});

final TestStep iAmOnStatBlockPage = TestStep("I am on the Stat Block page", (tester) async {
  // Stat Block page is home page - do nothing
});

final TestStep iHaveOpenedCharacter = TestStep("I have opened a character", iOpenFile.closure);

String _weaponText({required int recoilCompensation}) => [
      "Ares SIGMA 3 [Submachine Guns, Acc 4 (8), DV 8P, AP -, SA/BF/FA, RC $recoilCompensation ",
      "(${recoilCompensation + 1}), ammo 50(d), w/ Flashlight, Infrared, Folding Stock, Foregrip, ",
      "Personalized Grip, Slide Mount, Slide Mount, Smartgun System, Internal]"
    ].join();

final TestStep iSeeStandardRecoilCompensationValue = TestStep("I see the standard Recoil Compensation value", (tester) async {
  expect(
    find.text(_weaponText(recoilCompensation: 3)),
    findsWidgets,
  );
});

final TestStep iChangeRecoilCompensationSetting = TestStep("I change Recoil Compensation setting", (tester) async {
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();

  var buttonToTap = find.text(localization.recoil_compensation_formula_standard).last;
  await tester.dragUntilVisible(buttonToTap, find.byType(Viewport), const Offset(0, 50));
  await tester.tap(buttonToTap);
  await tester.pumpAndSettle();

  buttonToTap = find.text(localization.recoil_compensation_formula_full_strength).last;
  await tester.dragUntilVisible(buttonToTap, find.byType(Viewport), const Offset(0, 50));
  await tester.tap(buttonToTap);
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
});

final TestStep iSeeNewRecoilCompensationValue = TestStep("I see the new Recoil Compensation value", (tester) async {
  expect(
    find.text(_weaponText(recoilCompensation: 5)),
    findsWidgets,
  );
});
