import 'dart:async';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:chummer_chummer/services/store_extension.dart';
import 'package:chummer_chummer/state.dart';
import 'package:chummer_chummer/features/settings/state.dart';

abstract class SettingsAction extends ReduxActionWithServices<AppState> {
  SettingsState get fState => state.settingsState;
  FutureOr<SettingsState?> fReduce();

  @override
  Future<AppState?> reduce() async {
    final futureOrNewState = fReduce();
    final newState = (futureOrNewState is Future) ? await futureOrNewState : futureOrNewState;
    return (newState != null) ? state.rebuild((b) => b..settingsState = newState.toBuilder()) : null;
  }
}

class SetLocaleSettings extends SettingsAction {
  final Locale? locale;

  SetLocaleSettings({required this.locale});

  @override
  void before() => dispatch(_SetIsBusy());

  @override
  Future<SettingsState> fReduce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      prefs.setString('language_code', locale!.languageCode);
    } else {
      prefs.remove('language_code');
    }

    return fState.rebuild((b) => b
      ..locale = locale
      ..isBusy = false);
  }
}

class SetRecoilCompensationFormulaSettings extends SettingsAction {
  final RecoilCompensationFormula recoilCompensationFormula;

  SetRecoilCompensationFormulaSettings({required this.recoilCompensationFormula});

  @override
  void before() => dispatch(_SetIsBusy());

  @override
  Future<SettingsState> fReduce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('recoil_compensation_formula', recoilCompensationFormula.index);

    return fState.rebuild((b) => b
      ..recoilCompensationFormula = recoilCompensationFormula
      ..isBusy = false);
  }
}

class _SetIsBusy extends SettingsAction {
  @override
  SettingsState fReduce() {
    return fState.rebuild((b) => b..isBusy = true);
  }
}
