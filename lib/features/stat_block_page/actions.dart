import 'dart:async';
import 'dart:io';

import 'package:chummer_chummer/services/store_extension.dart';
import 'package:chummer_chummer/util/error.dart';
import 'package:chummer_chummer/state.dart';
import 'package:chummer_chummer/features/stat_block_page/state.dart';
import 'package:chummer_chummer/features/stat_block_page/character_file_parser.dart';

abstract class StatBlockPageAction extends ReduxActionWithServices<AppState> {
  StatBlockPageState get fState => state.statBlockPageState;
  FutureOr<StatBlockPageState?> fReduce();

  @override
  Future<AppState?> reduce() async {
    final futureOrNewState = fReduce();
    final newState = (futureOrNewState is Future) ? await futureOrNewState : futureOrNewState;
    return (newState != null) ? state.rebuild((b) => b..statBlockPageState = newState.toBuilder()) : null;
  }
}

class LoadCharacterFile extends StatBlockPageAction {
  late int _index;

  @override
  void before() {
    _index = fState.loadingList.length;
    dispatch(_SetLoadingCharacterFile(index: _index));
  }

  @override
  Future<StatBlockPageState> fReduce() async {
    try {
      final file = await store.fileService.open();
      if (file == null) {
        return fState.rebuild((b) => b..loadingList[_index] = false);
      }

      final response = await CharacterFileParser.parse(file.content);
      if (response.isError) {
        return fState.rebuild((b) => b
          ..error = response.error
          ..loadingList[_index] = false);
      } else {
        final newCharacter = response.value;
        return fState.rebuild((b) => b
          ..loadingList[_index] = false
          ..characters.add((newCharacter..sourceFilePath = file.path).build()));
      }
    } catch (e) {
      return fState.rebuild((b) => b
        ..error = ErrorData(ErrorCodes.fileIO, ErrorLevels.error, "Failed to open file: $e")
        ..loadingList[_index] = false);
    }
  }
}

class ReloadCharacterFile extends StatBlockPageAction {
  final int index;

  ReloadCharacterFile({required this.index}) : assert(!index.isNegative);

  @override
  void before() {
    assert(index >= 0 && index < fState.characters.length, "Invalid Character index.");
    assert(fState.characters[index].sourceFilePath != null, "Trying to reload a character sheet that wasn't loaded from a file.");
    dispatch(_SetLoadingCharacterFile(index: index));
  }

  @override
  Future<StatBlockPageState> fReduce() async {
    try {
      var file = File(fState.characters[index].sourceFilePath!);
      final response = await CharacterFileParser.parse(await file.readAsString());
      if (response.isError) {
        return fState.rebuild((b) => b
          ..error = response.error
          ..loadingList[index] = false);
      } else {
        final newCharacter = response.value;
        return fState.rebuild((b) => b
          ..loadingList[index] = false
          ..characters[index] = (newCharacter..sourceFilePath = file.path).build());
      }
    } catch (e) {
      return fState.rebuild((b) => b
        ..error = ErrorData(ErrorCodes.fileIO, ErrorLevels.error, "Failed to open file: $e")
        ..loadingList[index] = false);
    }
  }
}

class ClearCharacterFile extends StatBlockPageAction {
  final int index;

  ClearCharacterFile({required this.index}) : assert(!index.isNegative);

  @override
  StatBlockPageState fReduce() {
    if (index >= fState.characters.length || index.isNegative) {
      assert(false, "Invalid Character index.");
      return fState;
    }

    return fState.rebuild((b) => b..characters.removeAt(index));
  }
}

class ClearError extends StatBlockPageAction {
  @override
  StatBlockPageState fReduce() {
    return fState.rebuild((b) => b..error = null);
  }
}

/// Indicates that a character under given [index] is being (re)loaded.
class _SetLoadingCharacterFile extends StatBlockPageAction {
  final int index;

  _SetLoadingCharacterFile({required this.index}) : assert(!index.isNegative);

  @override
  StatBlockPageState fReduce() {
    if (index > fState.loadingList.length) {
      assert(false, "Character index was not incremented correctly.");
      return fState;
    }

    if (index < fState.loadingList.length) {
      return fState.rebuild((b) => b..loadingList[index] = true);
    } else {
      return fState.rebuild((b) => b..loadingList.insert(index, true));
    }
  }
}
