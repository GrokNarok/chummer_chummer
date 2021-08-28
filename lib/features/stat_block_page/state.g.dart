// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StatBlockPageState extends StatBlockPageState {
  @override
  final ErrorData? error;
  @override
  final BuiltList<bool> loadingList;
  @override
  final BuiltList<Character> characters;

  factory _$StatBlockPageState(
          [void Function(StatBlockPageStateBuilder)? updates]) =>
      (new StatBlockPageStateBuilder()..update(updates)).build();

  _$StatBlockPageState._(
      {this.error, required this.loadingList, required this.characters})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        loadingList, 'StatBlockPageState', 'loadingList');
    BuiltValueNullFieldError.checkNotNull(
        characters, 'StatBlockPageState', 'characters');
  }

  @override
  StatBlockPageState rebuild(
          void Function(StatBlockPageStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StatBlockPageStateBuilder toBuilder() =>
      new StatBlockPageStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StatBlockPageState &&
        error == other.error &&
        loadingList == other.loadingList &&
        characters == other.characters;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, error.hashCode), loadingList.hashCode),
        characters.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('StatBlockPageState')
          ..add('error', error)
          ..add('loadingList', loadingList)
          ..add('characters', characters))
        .toString();
  }
}

class StatBlockPageStateBuilder
    implements Builder<StatBlockPageState, StatBlockPageStateBuilder> {
  _$StatBlockPageState? _$v;

  ErrorData? _error;
  ErrorData? get error => _$this._error;
  set error(ErrorData? error) => _$this._error = error;

  ListBuilder<bool>? _loadingList;
  ListBuilder<bool> get loadingList =>
      _$this._loadingList ??= new ListBuilder<bool>();
  set loadingList(ListBuilder<bool>? loadingList) =>
      _$this._loadingList = loadingList;

  ListBuilder<Character>? _characters;
  ListBuilder<Character> get characters =>
      _$this._characters ??= new ListBuilder<Character>();
  set characters(ListBuilder<Character>? characters) =>
      _$this._characters = characters;

  StatBlockPageStateBuilder();

  StatBlockPageStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _loadingList = $v.loadingList.toBuilder();
      _characters = $v.characters.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StatBlockPageState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$StatBlockPageState;
  }

  @override
  void update(void Function(StatBlockPageStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$StatBlockPageState build() {
    _$StatBlockPageState _$result;
    try {
      _$result = _$v ??
          new _$StatBlockPageState._(
              error: error,
              loadingList: loadingList.build(),
              characters: characters.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'loadingList';
        loadingList.build();
        _$failedField = 'characters';
        characters.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'StatBlockPageState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
