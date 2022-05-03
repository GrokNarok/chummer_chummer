import 'package:chummer_chummer/services/file_service.dart';
import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chummer_chummer/state.dart';
import 'package:chummer_chummer/theme/theme.dart';
import 'package:chummer_chummer/services/store_extension.dart';
import 'package:chummer_chummer/features/stat_block_page/ui.dart';
import 'package:chummer_chummer/features/settings/ui.dart';

/// Disconnected mode is used to run the app without APIs, file io, hardware interfaces, ect. with data
/// normally provided by those replaced with fakes. Disconnected mode is also used in automated tests
/// instead of (or in addition to) mocks.
const bool runInDisconnectedMode = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  runApp(App(
    store: StoreWithServices<AppState>(
      initialState: AppState.initial(preferences: preferences),
      fileService: runInDisconnectedMode ? FileServiceDisconnected() : FileServiceConnected(),
    ),
  ));
}

class App extends StatelessWidget {
  final StoreWithServices<AppState> store;

  const App({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) => StoreProvider<AppState>(
        store: store,
        child: StoreConnector<AppState, _AppViewModel>(
          vm: () => _AppViewModelFactory(),
          distinct: true,
          builder: (BuildContext context, _AppViewModel viewModel) => ThemeExtension(
            colorScheme: AppTheme.colorSchemeExtension(AppThemes.classic),
            child: MaterialApp(
              title: "Chummer\u00B2",
              theme: AppTheme.themeData(AppThemes.classic),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: viewModel.locale,
              routes: {
                '/': (_) => const StatBlockPage(),
                '/settings': (_) => const SettingsPage(),
              },
            ),
          ),
        ),
      );
}

class _AppViewModelFactory extends VmFactory<AppState, App> {
  @override
  _AppViewModel fromStore() => _AppViewModel(state.settingsState.locale);
}

/// ViewModel for the part of the state that directly affects MaterialApp widget
class _AppViewModel extends Vm {
  final Locale? locale;

  _AppViewModel(this.locale) : super(equals: [locale]);
}
