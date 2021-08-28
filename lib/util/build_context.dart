import 'package:flutter/widgets.dart';
import 'package:async_redux/async_redux.dart';

import 'package:chummer_chummer/state.dart';

/// Screen width in logical pixels at which the screen is considered wide, used to determine ui layout.
const screenWidthThreshold = 500.0;

extension AppBuildContext on BuildContext {
  Future<void> dispatch(ReduxAction<AppState> action, {bool notify = true}) {
    return StoreProvider.of<AppState>(this, null).dispatch(action, notify: notify);
  }

  bool get isWideScreen => MediaQuery.of(this).size.width >= screenWidthThreshold;
}
