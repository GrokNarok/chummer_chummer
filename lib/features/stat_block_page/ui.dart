import 'dart:math';

import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:chummer_chummer/theme/theme.dart';
import 'package:chummer_chummer/theme/sizes.dart';
import 'package:chummer_chummer/theme/colors.dart';
import 'package:chummer_chummer/util/build_context.dart';
import 'package:chummer_chummer/widgets/expanding_text.dart';
import 'package:chummer_chummer/widgets/searched_text.dart';
import 'package:chummer_chummer/widgets/random_background.dart';
import 'package:chummer_chummer/state.dart';
import 'package:chummer_chummer/features/stat_block_page/actions.dart';
import 'package:chummer_chummer/features/stat_block_page/viewmodels.dart';
import 'package:chummer_chummer/widgets/app_bar_progress_indicator.dart';

class StatBlockPage extends StatefulWidget {
  @override
  _StatBlockPageState createState() => _StatBlockPageState();
}

class _StatBlockPageState extends State<StatBlockPage> {
  final _searchController = TextEditingController();

  bool showSearch = false; // determines if the search field is shown in the narrow layout

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) => StoreConnector<AppState, StatBlockPageViewModel>(
        vm: () => StatBlockPageViewModelFactory(),
        builder: _buildPage,
        onWillChange: (ctx, _, __, newViewModel) {
          // Handle error
          if (newViewModel.error != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(_snackBar(ctx, newViewModel.error!.msg));
            ctx.dispatch(ClearError());
          }
        },
      );

  Widget _buildPage(BuildContext ctx, StatBlockPageViewModel viewModel) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: RandomBackground(
              backgroundColor: Theme.of(ctx).colorScheme.background,
              patternColor: ThemeExtension.of(ctx).colorScheme.backgroundPattern,
            ),
          ),
        ),
        InheritedSearchTerm(
          searchTerm: _searchController.text,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _appBar(ctx, viewModel),
              body: viewModel.hasCharacter ? _statBlocks(ctx, viewModel) : _emptyPage(ctx),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Theme.of(ctx).colorScheme.secondary,
                onPressed: () => ctx.dispatch(LoadCharacterFile()),
                child: Icon(Icons.add),
              ),
            ),
          ),
        ),
      ],
    );
  }

  SnackBar _snackBar(BuildContext ctx, String errorMsg) => SnackBar(
        backgroundColor: Theme.of(ctx).colorScheme.error,
        content: Text("Error: $errorMsg}", style: Theme.of(ctx).textTheme.bodyText1!.copyWith(color: Theme.of(ctx).colorScheme.onError)),
      );

  AppBar _appBar(BuildContext ctx, StatBlockPageViewModel viewModel) => AppBar(
        leading: (!context.isWideScreen && showSearch)
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => setState(() => showSearch = !showSearch),
              )
            : null,
        title: Row(
          children: [
            if (context.isWideScreen || !showSearch)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: Sizing.l),
                child: Text("Chummer\u00B2"),
              ),
            if (context.isWideScreen || showSearch)
              Expanded(
                child: Center(
                  child: Container(
                    width: 400.0,
                    child: TextField(
                      controller: _searchController,
                      cursorColor: Theme.of(ctx).textTheme.bodyText2?.color,
                      decoration: InputDecoration(
                        prefixIconConstraints: BoxConstraints(maxWidth: Sizing.l, maxHeight: Sizing.l),
                        prefixIcon: Icon(Icons.search, color: Theme.of(ctx).textTheme.bodyText2?.color),
                        suffixIconConstraints: BoxConstraints(maxWidth: Sizing.l, maxHeight: Sizing.l),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  child: Icon(Icons.clear, color: Theme.of(ctx).textTheme.bodyText2?.color),
                                  onTap: () => _searchController.clear(),
                                ),
                              )
                            : null,
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(ctx).textTheme.bodyText2!.color!)),
                        isDense: true,
                        hintText: AppLocalizations.of(ctx)!.search_instructions,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          if (!context.isWideScreen && !showSearch)
            IconButton(
              key: Key("search_button"),
              icon: Icon(Icons.search),
              tooltip: AppLocalizations.of(ctx)!.settings_tooltip,
              onPressed: () => setState(() => showSearch = !showSearch),
            ),
          IconButton(
            key: Key("settings_button"),
            icon: Icon(Icons.settings),
            tooltip: AppLocalizations.of(ctx)!.settings_tooltip,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
        bottom: viewModel.isLoading ? AppBarProgressIndicator() : null,
      );

  Widget _statBlocks(BuildContext ctx, StatBlockPageViewModel viewModel) {
    const minStatBlockWidth = 400.0;
    final numStatBlocks = viewModel.numberOfCharacters;
    final numColumns = max((MediaQuery.of(ctx).size.width / minStatBlockWidth).floor(), 1);
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: (numStatBlocks / numColumns).ceil(),
      itemBuilder: (_, i) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          numColumns,
          (j) {
            final index = (i * numColumns) + j;
            return Expanded(
                child: (index < numStatBlocks)
                    ? Container(
                        margin: const EdgeInsets.all(Sizing.xxs),
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.6), blurRadius: 1, offset: Offset(2, 2))],
                        ),
                        child: StatBlock(index: index),
                      )
                    : Container()); // Empty Containers for unoccupied "slots" so the stat blocks on last row are same width as rest
          },
        ).toList(),
      ),
    );
  }

  Widget _emptyPage(BuildContext ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizing.l),
          child: TextButton(
            onPressed: () => ctx.dispatch(LoadCharacterFile()),
            child: Text(AppLocalizations.of(ctx)!.load_file_instructions, textAlign: TextAlign.center, style: Theme.of(ctx).textTheme.headline5),
          ),
        ),
      );
}

class StatBlock extends StatelessWidget {
  final int index;

  const StatBlock({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext ctx) => StoreConnector<AppState, Lightweight>(
        vm: () => CharacterViewModelFactory(index: index),
        builder: _buildPage,
      );

  final _contentLabelsColumnWidth = 88.0;
  Widget _buildPage(BuildContext ctx, Lightweight viewModel) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _separator(ctx),
          Container(
            decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.primary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Sizing.xs, vertical: Sizing.xxs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${AppLocalizations.of(ctx)!.name_label}: ${viewModel.name.toUpperCase()}",
                        style: Theme.of(ctx).textTheme.bodyText1!.copyWith(color: Theme.of(ctx).colorScheme.secondary, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${AppLocalizations.of(ctx)!.metatype_label}: ${viewModel.metatype.toUpperCase()}" +
                            (viewModel.hasMetavariant ? " (${viewModel.metavariant.toUpperCase()})" : ""),
                        style: Theme.of(ctx).textTheme.bodyText1!.copyWith(color: Theme.of(ctx).colorScheme.secondary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizing.s),
                  child: PopupMenuButton<Function()>(
                    child: Icon(Icons.more_vert, color: Theme.of(ctx).colorScheme.secondary),
                    tooltip: AppLocalizations.of(ctx)!.stat_block_menu_tooltip,
                    onSelected: (callBack) => callBack(),
                    itemBuilder: (_) => [
                      if (viewModel.loadedFromFile)
                        PopupMenuItem(
                          child: Row(children: <Widget>[
                            Icon(Icons.refresh),
                            const SizedBox(width: Sizing.s),
                            Text(AppLocalizations.of(ctx)!.stat_block_menu_reload),
                          ]),
                          value: () => ctx.dispatch(ReloadCharacterFile(index: index)),
                        ),
                      PopupMenuItem(
                        child: Row(children: <Widget>[
                          Icon(Icons.close),
                          const SizedBox(width: Sizing.s),
                          Text(AppLocalizations.of(ctx)!.stat_block_menu_close),
                        ]),
                        value: () => ctx.dispatch(ClearCharacterFile(index: index)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _separator(ctx),
          Stack(
            children: <Widget>[
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.primary),
                      child: Text("", style: Theme.of(ctx).textTheme.bodyText1), // Match height to the text label on top
                    ),
                    _separator(ctx),
                    Expanded(child: Container(decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.surface))),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _attribute(ctx, AppLocalizations.of(ctx)!.body_label, viewModel.body),
                  _attribute(ctx, AppLocalizations.of(ctx)!.agility_label, viewModel.agility),
                  _attribute(ctx, AppLocalizations.of(ctx)!.reaction_label, viewModel.reaction),
                  _attribute(ctx, AppLocalizations.of(ctx)!.strength_label, viewModel.strength),
                  _attribute(ctx, AppLocalizations.of(ctx)!.willpower_label, viewModel.willpower),
                  _attribute(ctx, AppLocalizations.of(ctx)!.logic_label, viewModel.logic),
                  _attribute(ctx, AppLocalizations.of(ctx)!.intuition_label, viewModel.intuition),
                  _attribute(ctx, AppLocalizations.of(ctx)!.charisma_label, viewModel.charisma),
                  _attribute(ctx, AppLocalizations.of(ctx)!.essence_label, viewModel.displayEssence),
                  _attribute(ctx, AppLocalizations.of(ctx)!.edge_label, viewModel.edge),
                  if (viewModel.hasMagic) _attribute(ctx, AppLocalizations.of(ctx)!.magic_label, viewModel.magic.toString()),
                  if (viewModel.hasResonance) _attribute(ctx, AppLocalizations.of(ctx)!.resonance_label, viewModel.resonance.toString()),
                  if (viewModel.hasDepth) _attribute(ctx, AppLocalizations.of(ctx)!.depth_label, viewModel.depth.toString()),
                ],
              ),
            ],
          ),
          _separator(ctx),
          Stack(
            children: <Widget>[
              Positioned.fill(
                child: Row(
                  children: <Widget>[
                    Container(width: _contentLabelsColumnWidth, decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.primary)),
                    Expanded(child: Container(decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.surface))),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  _contentRow(ctx, AppLocalizations.of(ctx)!.condition, Text("${viewModel.physicalCondition}/${viewModel.stunCondition}")),
                  _contentRow(ctx, AppLocalizations.of(ctx)!.armor, Text(viewModel.characterArmor.toString())),
                  _contentRow(
                      ctx,
                      AppLocalizations.of(ctx)!.limits,
                      SearchedText([
                        "${AppLocalizations.of(ctx)!.physical} ${viewModel.physicalLimit}",
                        "${AppLocalizations.of(ctx)!.mental} ${viewModel.mentalLimit}",
                        "${AppLocalizations.of(ctx)!.social} ${viewModel.socialLimit}",
                      ].join(", "))),
                  _contentRow(ctx, AppLocalizations.of(ctx)!.initiative, Text(viewModel.initiative)),
                  _contentRow(ctx, AppLocalizations.of(ctx)!.active_skills, SearchedText(viewModel.activeSkills)),
                  _contentRow(ctx, AppLocalizations.of(ctx)!.knowledge_skills, SearchedText(viewModel.knowledgeSkills)),
                  _contentRow(ctx, AppLocalizations.of(ctx)!.languages, SearchedText(viewModel.languageSkills)),
                  if (viewModel.hasPowers) _contentRow(ctx, AppLocalizations.of(ctx)!.powers, SearchedText(viewModel.powers)),
                  if (viewModel.hasQualities) _contentRow(ctx, AppLocalizations.of(ctx)!.qualities, SearchedText(viewModel.qualities)),
                  if (viewModel.hasMartialArts) _contentRow(ctx, AppLocalizations.of(ctx)!.magic_arts, SearchedText(viewModel.martialArts)),
                  if (viewModel.hasAdeptPowers) _contentRow(ctx, AppLocalizations.of(ctx)!.adept_powers, SearchedText(viewModel.adeptPowers)),
                  if (viewModel.initiationGrade > 0)
                    _contentRow(ctx, AppLocalizations.of(ctx)!.initiation_grade, SearchedText(viewModel.initiationGrade.toString())),
                  if (viewModel.hasMetamagic) _contentRow(ctx, AppLocalizations.of(ctx)!.metamagic, SearchedText(viewModel.metamagic)),
                  if (viewModel.hasArts) _contentRow(ctx, AppLocalizations.of(ctx)!.magic_arts, SearchedText(viewModel.arts)),
                  if (viewModel.hasSpells) _contentRow(ctx, AppLocalizations.of(ctx)!.spells, SearchedText(viewModel.spells)),
                  if (viewModel.hasAlchemicalPreparations)
                    _contentRow(ctx, AppLocalizations.of(ctx)!.alchemical_preparations, SearchedText(viewModel.alchemicalPreparations)),
                  if (viewModel.hasSpirits) _contentRow(ctx, AppLocalizations.of(ctx)!.spirits, SearchedText(viewModel.spirits.join("\n"))),
                  if (viewModel.submersionGrade > 0)
                    _contentRow(ctx, AppLocalizations.of(ctx)!.submersion_grade, SearchedText(viewModel.submersionGrade.toString())),
                  if (viewModel.hasEchoes) _contentRow(ctx, AppLocalizations.of(ctx)!.echoes, SearchedText(viewModel.echoes)),
                  if (viewModel.hasComplexForms) _contentRow(ctx, AppLocalizations.of(ctx)!.complex_forms, SearchedText(viewModel.complexForms)),
                  if (viewModel.hasSprites) _contentRow(ctx, AppLocalizations.of(ctx)!.sprites, SearchedText(viewModel.sprites.join("\n"))),
                  if (viewModel.hasCyberware) _contentRow(ctx, AppLocalizations.of(ctx)!.augmentations, SearchedText(viewModel.cyberware)),
                  if (viewModel.hasGear) _contentRow(ctx, AppLocalizations.of(ctx)!.gear, SearchedText(viewModel.gear)),
                  if (viewModel.hasWeapons)
                    _contentRow(ctx, AppLocalizations.of(ctx)!.weapons, _expandableContent(viewModel.weapons), padding: EdgeInsets.zero),
                  if (viewModel.hasArmor) _contentRow(ctx, AppLocalizations.of(ctx)!.armor_sets, _expandableContent(viewModel.armor), padding: EdgeInsets.zero),
                  if (viewModel.hasVehicles)
                    _contentRow(ctx, AppLocalizations.of(ctx)!.vehicles, _expandableContent(viewModel.vehicles), padding: EdgeInsets.zero),
                  if (viewModel.hasContacts) _contentRow(ctx, AppLocalizations.of(ctx)!.contacts, SearchedText(viewModel.contacts.join("\n"))),
                  _contentRow(ctx, "${AppLocalizations.of(ctx)!.nuyen}/${AppLocalizations.of(ctx)!.karma}",
                      SearchedText("${viewModel.displayNuyen} / ${viewModel.karma} ${AppLocalizations.of(ctx)!.karma}")),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _separator(BuildContext ctx) => Container(color: Theme.of(ctx).colorScheme.secondary, height: Sizing.xxs);

  Widget _attribute(BuildContext ctx, String label, String val) => Expanded(
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: Theme.of(ctx).textTheme.bodyText1!.copyWith(color: Theme.of(ctx).colorScheme.secondary, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: Sizing.xxs),
            Text(
              val,
              style: Theme.of(ctx).textTheme.bodyText1,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      );

  Widget _contentRow(BuildContext ctx, String label, Widget content, {EdgeInsets? padding}) => Padding(
        padding: const EdgeInsets.only(bottom: Sizing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Sizing.xs),
              width: _contentLabelsColumnWidth,
              child: Text(
                label,
                style: Theme.of(ctx).textTheme.bodyText2!.copyWith(color: Theme.of(ctx).colorScheme.secondary, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Padding(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: Sizing.xs),
                child: content,
              ),
            ),
          ],
        ),
      );

  Widget _expandableContent(List<String> elements) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: elements
            .map((e) => ExpandingText(
                  collapsed: SearchedText(e, overflow: TextOverflow.ellipsis),
                  expanded: SearchedText(e),
                ))
            .toList(),
      );
}
