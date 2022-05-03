import 'package:async_redux/async_redux.dart';

import 'package:chummer_chummer/services/file_service.dart';

/// Services are bits that interact with the outside world and/or platform specific: APIs, file io, hardware interfaces, ect.
/// As such they may or may not be available depending on how the app is run so we make a point of providing
/// disconnected (fake/mock) versions so that the app can be run and tested independent of those constraints.
/// Disconnected services can provide random errors and delays to test error handling and ui responsiveness
/// (useful when an API doesn't provide a test interface (i.e. most of the time)). Disconnected services
/// are also used in automated tests instead of (or in addition to) mocks.
///
/// Service type things would normally be introduces at middleware layer of Redux but because async_redux doesn't
/// have middleware and uses async actions instead we need a way to supply services to those actions. The helper
/// classes below accomplish that by adding the services to the app's store.
class StoreWithServices<St> extends Store<St> {
  final FileService fileService;

  StoreWithServices({
    required St initialState,
    required this.fileService,
  }) : super(initialState: initialState);
}

abstract class ReduxActionWithServices<St> extends ReduxAction<St> {
  @override
  StoreWithServices<St> get store => super.store as StoreWithServices<St>;
}
