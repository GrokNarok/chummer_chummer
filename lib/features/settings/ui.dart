import 'dart:io';

import 'package:async_redux/async_redux.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:chummer_chummer/util/build_context.dart';
import 'package:chummer_chummer/widgets/app_bar_progress_indicator.dart';
import 'package:chummer_chummer/state.dart';
import 'package:chummer_chummer/features/settings/state.dart';
import 'package:chummer_chummer/features/settings/viewmodels.dart';
import 'package:chummer_chummer/features/settings/actions.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) => StoreConnector<AppState, SettingsViewModel>(
        vm: () => SettingsViewModelFactory(),
        builder: _buildPage,
      );

  Widget _buildPage(BuildContext ctx, SettingsViewModel viewModel) => Scaffold(
        appBar: AppBar(
          bottom: viewModel.isBusy ? AppBarProgressIndicator() : null,
        ),
        body: ConstrainedBox(
          constraints: BoxConstraints.loose(Size.fromWidth(480)),
          child: ListView(
            children: [
              _localeSetting(ctx, viewModel),
              _recoilCompensationSetting(ctx, viewModel),
            ],
          ),
        ),
      );

  Widget _localeSetting(BuildContext ctx, SettingsViewModel viewModel) => ListTile(
        title: Text(AppLocalizations.of(ctx)!.locale_label),
        trailing: DropdownButton<Locale>(
          value: viewModel.locale,
          onChanged: (newLocale) => ctx.dispatch(SetLocaleSettings(locale: newLocale)),
          underline: Container(),
          items: [
            DropdownMenuItem<Locale>(
              key: Key("default_locale"),
              child: Text("${AppLocalizations.of(ctx)!.system_option} (${Platform.localeName})"),
            ),
            DropdownMenuItem<Locale>(
              value: Locale("en"),
              child: Text(AppLocalizations.of(ctx)!.locale_en_option),
            ),
            DropdownMenuItem<Locale>(
              value: Locale("ru"),
              child: Text(AppLocalizations.of(ctx)!.locale_ru_option),
            ),
          ],
        ),
      );

  Widget _recoilCompensationSetting(BuildContext ctx, SettingsViewModel viewModel) => ListTile(
        title: Text(AppLocalizations.of(ctx)!.recoil_compensation_formula_label),
        trailing: DropdownButton<RecoilCompensationFormula>(
          value: viewModel.recoilCompensationFormula,
          onChanged: (newFormula) => ctx.dispatch(SetRecoilCompensationFormulaSettings(recoilCompensationFormula: newFormula!)),
          underline: Container(),
          items: [
            DropdownMenuItem<RecoilCompensationFormula>(
              value: RecoilCompensationFormula.standard,
              child: Text(AppLocalizations.of(ctx)!.recoil_compensation_formula_standard),
            ),
            DropdownMenuItem<RecoilCompensationFormula>(
              value: RecoilCompensationFormula.fullStrength,
              child: Text(AppLocalizations.of(ctx)!.recoil_compensation_formula_full_strength),
            ),
          ],
        ),
      );
}
