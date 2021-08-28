import 'dart:ui';

import 'package:built_value/built_value.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chummer_chummer/util/error.dart';

part 'state.g.dart';

enum RecoilCompensationFormula {
  standard,
  fullStrength,
}

abstract class SettingsState implements Built<SettingsState, SettingsStateBuilder> {
  factory SettingsState([void updates(SettingsStateBuilder b)]) = _$SettingsState;
  SettingsState._();
  factory SettingsState.initial({SharedPreferences? preferences}) {
    final languageCode = preferences?.getString('language_code');
    final recoilCompensationFormula = preferences?.getInt('recoil_compensation_formula');
    return _$SettingsState._(
      isBusy: false,
      locale: (languageCode != null) ? Locale(languageCode) : null,
      recoilCompensationFormula:
          (recoilCompensationFormula != null) ? RecoilCompensationFormula.values[recoilCompensationFormula] : RecoilCompensationFormula.standard,
    );
  }

  ErrorData? get error;
  bool get isBusy;

  Locale? get locale;
  RecoilCompensationFormula get recoilCompensationFormula;
}
