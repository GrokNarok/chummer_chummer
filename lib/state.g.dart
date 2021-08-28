// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppState extends AppState {
  @override
  final SettingsState settingsState;
  @override
  final StatBlockPageState statBlockPageState;

  factory _$AppState([void Function(AppStateBuilder)? updates]) =>
      (new AppStateBuilder()..update(updates)).build();

  _$AppState._({required this.settingsState, required this.statBlockPageState})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        settingsState, 'AppState', 'settingsState');
    BuiltValueNullFieldError.checkNotNull(
        statBlockPageState, 'AppState', 'statBlockPageState');
  }

  @override
  AppState rebuild(void Function(AppStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppStateBuilder toBuilder() => new AppStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppState &&
        settingsState == other.settingsState &&
        statBlockPageState == other.statBlockPageState;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc(0, settingsState.hashCode), statBlockPageState.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('AppState')
          ..add('settingsState', settingsState)
          ..add('statBlockPageState', statBlockPageState))
        .toString();
  }
}

class AppStateBuilder implements Builder<AppState, AppStateBuilder> {
  _$AppState? _$v;

  SettingsStateBuilder? _settingsState;
  SettingsStateBuilder get settingsState =>
      _$this._settingsState ??= new SettingsStateBuilder();
  set settingsState(SettingsStateBuilder? settingsState) =>
      _$this._settingsState = settingsState;

  StatBlockPageStateBuilder? _statBlockPageState;
  StatBlockPageStateBuilder get statBlockPageState =>
      _$this._statBlockPageState ??= new StatBlockPageStateBuilder();
  set statBlockPageState(StatBlockPageStateBuilder? statBlockPageState) =>
      _$this._statBlockPageState = statBlockPageState;

  AppStateBuilder();

  AppStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _settingsState = $v.settingsState.toBuilder();
      _statBlockPageState = $v.statBlockPageState.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$AppState;
  }

  @override
  void update(void Function(AppStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$AppState build() {
    _$AppState _$result;
    try {
      _$result = _$v ??
          new _$AppState._(
              settingsState: settingsState.build(),
              statBlockPageState: statBlockPageState.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'settingsState';
        settingsState.build();
        _$failedField = 'statBlockPageState';
        statBlockPageState.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'AppState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
