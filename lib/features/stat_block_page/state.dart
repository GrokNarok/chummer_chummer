import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import 'package:chummer_chummer/util/error.dart';

import 'data.dart';

part 'state.g.dart';

abstract class StatBlockPageState implements Built<StatBlockPageState, StatBlockPageStateBuilder> {
  factory StatBlockPageState([void Function(StatBlockPageStateBuilder b) updates]) = _$StatBlockPageState;
  StatBlockPageState._();
  factory StatBlockPageState.initial() => _$StatBlockPageState._(
        loadingList: BuiltList<bool>(),
        characters: BuiltList<Character>(),
      );

  ErrorData? get error;

  /// List of flags indicating characters that are being (re)loaded.
  BuiltList<bool> get loadingList;

  BuiltList<Character> get characters;
}
