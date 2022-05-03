import 'package:built_value/built_value.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chummer_chummer/features/settings/state.dart';
import 'package:chummer_chummer/features/stat_block_page/state.dart';

part 'state.g.dart';

abstract class AppState implements Built<AppState, AppStateBuilder> {
  factory AppState([void Function(AppStateBuilder b) updates]) = _$AppState;

  factory AppState.initial({SharedPreferences? preferences}) => _$AppState._(
        settingsState: SettingsState.initial(preferences: preferences),
        statBlockPageState: StatBlockPageState.initial(),
      );

  AppState._();

  SettingsState get settingsState;
  StatBlockPageState get statBlockPageState;
}
