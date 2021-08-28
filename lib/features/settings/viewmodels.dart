import 'dart:ui';

import 'package:async_redux/async_redux.dart';

import 'package:chummer_chummer/state.dart';
import 'package:chummer_chummer/features/settings/state.dart';

class SettingsViewModelFactory extends VmFactory<AppState, void> {
  @override
  SettingsViewModel fromStore() => SettingsViewModel(state.settingsState);
}

class SettingsViewModel extends Vm {
  final SettingsState _state;

  SettingsViewModel(this._state) : super(equals: [_state]);

  bool get isBusy => _state.isBusy;

  Locale? get locale => _state.locale;
  RecoilCompensationFormula? get recoilCompensationFormula => _state.recoilCompensationFormula;
}
