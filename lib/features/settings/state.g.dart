// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SettingsState extends SettingsState {
  @override
  final ErrorData? error;
  @override
  final bool isBusy;
  @override
  final Locale? locale;
  @override
  final RecoilCompensationFormula recoilCompensationFormula;

  factory _$SettingsState([void Function(SettingsStateBuilder)? updates]) =>
      (new SettingsStateBuilder()..update(updates)).build();

  _$SettingsState._(
      {this.error,
      required this.isBusy,
      this.locale,
      required this.recoilCompensationFormula})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(isBusy, 'SettingsState', 'isBusy');
    BuiltValueNullFieldError.checkNotNull(recoilCompensationFormula,
        'SettingsState', 'recoilCompensationFormula');
  }

  @override
  SettingsState rebuild(void Function(SettingsStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsStateBuilder toBuilder() => new SettingsStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettingsState &&
        error == other.error &&
        isBusy == other.isBusy &&
        locale == other.locale &&
        recoilCompensationFormula == other.recoilCompensationFormula;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, error.hashCode), isBusy.hashCode), locale.hashCode),
        recoilCompensationFormula.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('SettingsState')
          ..add('error', error)
          ..add('isBusy', isBusy)
          ..add('locale', locale)
          ..add('recoilCompensationFormula', recoilCompensationFormula))
        .toString();
  }
}

class SettingsStateBuilder
    implements Builder<SettingsState, SettingsStateBuilder> {
  _$SettingsState? _$v;

  ErrorData? _error;
  ErrorData? get error => _$this._error;
  set error(ErrorData? error) => _$this._error = error;

  bool? _isBusy;
  bool? get isBusy => _$this._isBusy;
  set isBusy(bool? isBusy) => _$this._isBusy = isBusy;

  Locale? _locale;
  Locale? get locale => _$this._locale;
  set locale(Locale? locale) => _$this._locale = locale;

  RecoilCompensationFormula? _recoilCompensationFormula;
  RecoilCompensationFormula? get recoilCompensationFormula =>
      _$this._recoilCompensationFormula;
  set recoilCompensationFormula(
          RecoilCompensationFormula? recoilCompensationFormula) =>
      _$this._recoilCompensationFormula = recoilCompensationFormula;

  SettingsStateBuilder();

  SettingsStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _isBusy = $v.isBusy;
      _locale = $v.locale;
      _recoilCompensationFormula = $v.recoilCompensationFormula;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SettingsState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SettingsState;
  }

  @override
  void update(void Function(SettingsStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$SettingsState build() {
    final _$result = _$v ??
        new _$SettingsState._(
            error: error,
            isBusy: BuiltValueNullFieldError.checkNotNull(
                isBusy, 'SettingsState', 'isBusy'),
            locale: locale,
            recoilCompensationFormula: BuiltValueNullFieldError.checkNotNull(
                recoilCompensationFormula,
                'SettingsState',
                'recoilCompensationFormula'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
