import 'dart:math';

import 'package:async_redux/async_redux.dart';

import 'package:chummer_chummer/features/stat_block_page/constants.dart';
import 'package:chummer_chummer/util/error.dart';
import 'package:chummer_chummer/util/flatten.dart';
import 'package:chummer_chummer/state.dart';
import 'package:chummer_chummer/features/settings/state.dart';
import 'package:chummer_chummer/features/stat_block_page/data.dart';
import 'package:chummer_chummer/features/stat_block_page/state.dart';

class StatBlockPageViewModelFactory extends VmFactory<AppState, void> {
  @override
  StatBlockPageViewModel fromStore() => StatBlockPageViewModel(state.statBlockPageState);
}

class StatBlockPageViewModel extends Vm {
  final StatBlockPageState _state;

  StatBlockPageViewModel(this._state) : super(equals: [_state]);

  bool get hasError => _state.error != null;
  ErrorData? get error => _state.error;

  bool get isLoading => _state.loadingList.contains(true);

  bool get hasCharacter => _state.characters.length > 0;
  int get numberOfCharacters => _state.characters.length;
}

class CharacterViewModelFactory extends VmFactory<AppState, void> {
  final int index;

  CharacterViewModelFactory({required this.index});

  @override
  Lightweight fromStore() => index < state.statBlockPageState.characters.length
      ? Lightweight(state.statBlockPageState.characters[index], state.settingsState)
      : Lightweight(null, state.settingsState);
}

class Lightweight extends Vm {
  final Character? _character; // Will only be null when character data is deleted, but vm still has to be constructable for comparison by redux framework
  final SettingsState _settings;

  Lightweight(this._character, this._settings) : super(equals: [_character, _settings]);

  bool get hasCharacterFilePath => _character!.sourceFilePath != null;

  String get name => _character!.name;
  String get metatype => _character!.metatype;
  bool get hasMetavariant => _character!.metavariant != null;
  String get metavariant => _character!.metavariant ?? "";

  String get body => _attributeToString(_character!.body);
  String get agility => _attributeToString(_character!.agility);
  String get reaction => _attributeToString(_character!.reaction);
  String get strength => _attributeToString(_character!.strength);
  String get willpower => _attributeToString(_character!.willpower);
  String get logic => _attributeToString(_character!.logic);
  String get intuition => _attributeToString(_character!.intuition);
  String get charisma => _attributeToString(_character!.charisma);
  bool get hasMagic => _character!.magic != null;
  String get magic => hasMagic ? _attributeToString(_character!.magic!) : "";
  bool get hasResonance => _character!.resonance != null;
  String get resonance => hasResonance ? _attributeToString(_character!.resonance!) : "";
  bool get hasDepth => _character!.depth != null;
  String get depth => hasDepth ? _attributeToString(_character!.depth!) : "";
  String get edge => _attributeToString(_character!.edge);
  int get currentEdge => _character!.currentEdge;
  static String _attributeToString(Attribute a) => "${a.base}" + (a.total > a.base ? " (${a.total})" : "");

  double get essence => _character!.essence;
  String get displayEssence => essence.toString().replaceAll(RegExp(r"\.?0+$"), ""); // Truncate trailing zeros

  String get initiative => "${_character!.initiative.base} + ${_character!.initiative.dice}D6";

  int characterReachWith(ImprovementType improvementType) => _character!.reach + _character!.getImprovement(improvementType).floor();

  int get physicalCondition => _character!.physicalCondition;
  int get stunCondition => _character!.stunCondition;

  int get physicalLimit => _calculatePhysicalLimit(_character!);
  int get mentalLimit => ((_character!.logic.total * 2 + _character!.intuition.total + _character!.willpower.total) / 3).ceil();
  int get socialLimit => ((_character!.charisma.total * 2 + _character!.willpower.total + _character!.essence.floor()) / 3).ceil();
  int get astralLimit => max(mentalLimit, socialLimit);
  static int _calculatePhysicalLimit(Character character) => ((character.strength.total * 2 + character.body.total + character.reaction.total) / 3).ceil();

  int get characterRecoilCompensation => _calculateCharacterRecoilCompensation(_character!, _settings);
  static int _calculateCharacterRecoilCompensation(Character character, SettingsState settings) {
    int standardRC() => 1 + (character.strength.total / 3).ceil();
    int fullStrengthRC() => 1 + character.strength.total;

    return (settings.recoilCompensationFormula == RecoilCompensationFormula.fullStrength) ? fullStrengthRC() : standardRC();
  }

  String get activeSkills => _skillsToString(_character!.activeSkills);
  String get knowledgeSkills => _skillsToString(_character!.knowledgeSkills);
  String get languageSkills => _skillsToString(_character!.languageSkills, isLang: true);
  static String _skillsToString(List<Skill> skills, {bool isLang = false}) => skills.where((s) => isLang || s.rating > 0).map((s) {
        return [
          "${s.name}",
          if (s.specializations.isNotEmpty) " (${s.specializations.join(", ")})",
          " ${s.rating > 0 ? s.rating : 'N'}",
          if (s.specializations.isNotEmpty) " (+2)"
        ].join();
      }).join(", ");

  bool get hasPowers => _character!.powers.isNotEmpty;
  String get powers => _character!.powers.map((p) {
        return p.name + (p.extra.isNotEmpty ? " (${p.extra})" : "") + (p.rating > 0 ? " ${p.rating}" : "");
      }).join(", ");

  bool get hasQualities => _character!.qualities.isNotEmpty;
  String get qualities => _character!.qualities.map((q) {
        return q.name + (q.extra.isNotEmpty ? " (${q.extra})" : "") + (q.rating > 1 ? " ${q.rating}" : "");
      }).join(", ");

  bool get hasMartialArts => _character!.martialArts.isNotEmpty;
  String get martialArts => _character!.martialArts.map((ma) {
        return ma.name + (ma.techniques.isNotEmpty ? " (${ma.techniques.join(', ')})" : "");
      }).join(", ");

  bool get hasAdeptPowers => _character!.adeptPowers.isNotEmpty;
  String get adeptPowers => _character!.adeptPowers.map((ap) {
        return ap.name + (ap.extra.isNotEmpty ? " (${ap.extra})" : "") + (ap.rating > 0 ? " ${ap.rating}" : "");
      }).join(", ");

  int get initiationGrade => _character!.initiationGrade;

  bool get hasMetamagic => _character!.metamagic.isNotEmpty;
  String get metamagic => _character!.metamagic.join(", ");

  bool get hasArts => _character!.arts.isNotEmpty;
  String get arts => _character!.arts.join(", ");

  bool get hasSpells => _character!.spells.isNotEmpty;
  String get spells => _character!.spells.join(", ");

  bool get hasAlchemicalPreparations => _character!.alchemicalPreparations.isNotEmpty;
  String get alchemicalPreparations => _character!.alchemicalPreparations.join(", ");

  bool get hasSpirits => _character!.spirits.isNotEmpty;
  List<String> get spirits => _character!.spirits.map((s) {
        final extra = [if (s.bound) "Bound", if (s.fettered) "Fettered"];
        return "${s.type} ${s.force}" + (extra.isNotEmpty ? " (${extra.join(', ')})" : "") + " (${s.services} Services): ${s.critterName}";
      }).toList();

  int get submersionGrade => _character!.submersionGrade;

  bool get hasEchoes => _character!.echoes.isNotEmpty;
  String get echoes => _character!.echoes.join(", ");

  bool get hasComplexForms => _character!.complexForms.isNotEmpty;
  String get complexForms => _character!.complexForms.join(", ");

  bool get hasSprites => _character!.sprites.isNotEmpty;
  List<String> get sprites => _character!.sprites.map((s) {
        final extra = [if (s.registered) "Registered", if (s.spritePet) "Sprite Pet"];
        return "${s.type} ${s.rating}" + (extra.isNotEmpty ? " (${extra.join(', ')})" : "") + " (${s.tasksOwed} Tasks Owed): ${s.spriteName}";
      }).toList();

  bool get hasCyberware => cyberware.isNotEmpty;
  String get cyberware => _cyberwareCache(_character!.cyberware)();
  static final _cyberwareCache = cache1state((List<Cyberware> cyberware) => () => _cyberwareToString(cyberware));
  static String _cyberwareToString(List<Cyberware> cyberware) {
    String foldCyberList(List<Cyberware> cyber, [bool isTopLevel = true]) {
      return cyber.map((c) {
        final attributesAndOrComponents = [
          if (c.agi != null) "Agility ${c.agi}",
          if (c.str != null) "Strength ${c.str}",
          if (c.armour != null) "Armour ${c.armour}",
          foldCyberList(c.components, false),
        ].join(", ");
        return [
          "${c.name}",
          if (c.rating != 0) " ${c.rating}",
          if (isTopLevel && c.grade != "Standard") " (${c.grade})",
          if (attributesAndOrComponents.isNotEmpty) " [$attributesAndOrComponents]",
        ].join();
      }).join(", ");
    }

    return foldCyberList(cyberware);
  }

  bool get hasGear => gear.isNotEmpty;
  String get gear => _gearCache(_character!.gear)();
  static final _gearCache = cache1state((List<Gear> gear) => () => _gearToString(gear));
  static String _gearToString(List<Gear> gear) {
    String foldGearList(List<Gear> gear) {
      // "Commlink Functionality" is a build-in component with a bunch of default junk we don't care to display
      return gear.where((g) => g.name != "Commlink Functionality").map((g) {
        return [
          if (g.quantity != 1) "${g.quantity} ",
          "${g.name}",
          if (g.rating != 0) " ${g.rating}",
          foldGearList(g.components),
        ].join();
      }).join(", ");
    }

    return foldGearList(gear);
  }

  bool get hasWeapons => weapons.isNotEmpty;
  List<String> get weapons => _weaponsCache(_character!, _settings)();
  static final _weaponsCache = cache2states((Character character, SettingsState settings) => () => _weaponsToStrings(character, settings));
  static List<String> _weaponsToStrings(Character character, SettingsState settings) => [
        _platformWeaponsToStrings(character, character.weapons, platformRC: _calculateCharacterRecoilCompensation(character, settings)),
        character.vehicles
            .map((vehicle) => _platformWeaponsToStrings(
                  character,
                  vehicle.mounts.map((wm) => wm.weapons).flatten(), // All weapons on all mounts
                  platformRC: vehicle.body, // Recoil Compensation of a mounted weapon is base in vehicle's Body
                ).map((vehicleWeapon) => "${vehicle.name}: $vehicleWeapon"))
            .flatten()
      ].flatten();

  /// Turn a list of platform's (character or vehicle) weapons into a list of displayable [String]s
  static List<String> _platformWeaponsToStrings(Character character, List<Weapon> weapons, {required int platformRC}) => weapons
      .map((weapon) => [
            _weaponToString(character, weapon, platformRC: platformRC, accessories: weapon.accessories),
            // List underbarrel weapons as separate weapons (but use base weapon's accessories)
            ...weapon.underbarrelWeapons.map((underbarrelWeapon) =>
                "${weapon.name}: ${_weaponToString(character, underbarrelWeapon, platformRC: platformRC, accessories: weapon.accessories)}"),
          ])
      .flatten();

  /// Turn a weapon into a displayable [String]
  ///
  /// [accessories] needs to provide the list of accessories used when calculating final parameters of the weapon.
  /// Normally it's the weapon's accessory list but for underbarrel weapons it's the parent weapon's accessories.
  static String _weaponToString(Character character, Weapon weapon, {required int platformRC, required List<Accessory> accessories}) {
    String calculateReach() {
      var reach = character.reach + weapon.reach;
      if (weapon.category.toLowerCase() == "unarmed") {
        reach += character.getImprovement(ImprovementType.unarmedReach).floor();
      }
      return reach > 0 ? " Reach $reach" : " Reach -";
    }

    String calculateAccuracy() {
      bool isScope(Accessory a) => a.name.toLowerCase().contains("smartgun") || a.name.toLowerCase().contains("sight");
      final accuracyBase = weapon.usesPhysicalAccuracy ? _calculatePhysicalLimit(character) : weapon.accuracy;
      final scopeAccuracyBonus = accessories.where((a) => isScope(a)).fold<int>(0, (acc, a) => max(acc, a.accuracy)); // Bonus from scopes in non-cumulative
      final otherAccuracyBonus = accessories.where((a) => !isScope(a)).fold<int>(0, (acc, a) => acc + a.accuracy);
      final accuracyImprovements = character.getImprovement(ImprovementType.weaponAccuracy, improvementName: weapon.name) +
          character.getImprovement(ImprovementType.weaponSkillAccuracy, improvementName: getSkillForWeaponCategory(weapon.category, weapon.name) ?? "");
      final accuracyBonus = scopeAccuracyBonus + otherAccuracyBonus + accuracyImprovements.floor();
      return "Acc $accuracyBase" + (accuracyBonus > 0 ? " (${accuracyBase + accuracyBonus})" : "");
    }

    String calculateRC() {
      int calculateRCBonus(bool forDeployed) => accessories
          // Make map with the highest recoil compensation value in each group
          .fold<Map<int, int>>({}, (acc, a) {
            final recoilCompensation = forDeployed ? a.deployedRecoilCompensation : a.recoilCompensation;
            final current = acc[a.recoilCompensationGroup];
            if (current == null || current < recoilCompensation) {
              acc[a.recoilCompensationGroup] = recoilCompensation;
            }
            return acc;
          })
          // Add up values from each group
          .values
          .fold<int>(0, (acc, a) => acc + a);
      final recoilCompensationBonus = calculateRCBonus(false);
      final recoilCompensationDeployedBonus = calculateRCBonus(true);
      final recoilCompensation = platformRC + (weapon.recoilCompensation ?? 0) + recoilCompensationBonus;
      return (recoilCompensation > 0 || recoilCompensationDeployedBonus > 0)
          ? "RC $recoilCompensation" + (recoilCompensationDeployedBonus > 0 ? " (${recoilCompensation + recoilCompensationDeployedBonus})" : "")
          : "RC -";
    }

    // Replace (STR) or (STR+number) with the total strength of the character and add the number as necessary.
    final damage = weapon.damage.replaceAllMapped(RegExp(r"\(STR(\+(\d+))?\)"), (match) {
      return (character.strength.total + (int.tryParse(match.group(1) ?? "0") ?? 0)).toString();
    });

    final accessoriesStrings = accessories.map((a) {
      return "${a.name}" + (a.rating > 0 ? " ${a.rating}" : "");
    }).join(", ");

    return [
      "${weapon.name} [",
      [
        "${weapon.category}",
        if (weapon.isMelee) calculateReach(),
        calculateAccuracy(),
        "DV $damage",
        "AP ${weapon.armourPenetration}",
        if (weapon.mode != null) "${weapon.mode}",
        if (!weapon.isMelee) calculateRC(),
        if (weapon.ammo != null) "ammo ${weapon.ammo}",
      ].join(", "),
      if (accessoriesStrings.isNotEmpty) ", w/ $accessoriesStrings",
      "]",
    ].join();
  }

  bool get hasArmor => armor.isNotEmpty;
  List<String> get armor => _armorCache(_character!.armor)();
  static final _armorCache = cache1state((List<Armor> armor) => () => _armorToStrings(armor));
  static List<String> _armorToStrings(List<Armor> armor) => armor.map((ar) {
        final armorBonus = _calculateArmorBonus(ar);
        final mods = ar.mods.map((am) {
          return "${am.name}" + (am.extra.isNotEmpty ? " (${am.extra})" : "") + (am.rating > 0 ? " ${am.rating}" : "");
        });
        final gear = ar.gear.map((g) {
          return "${g.name}" + (g.rating > 0 ? " ${g.rating}" : "");
        });
        final modsAndGear = [...mods, ...gear].join(", ");
        return [
          "${ar.name}",
          if (ar.label.isNotEmpty) " (${ar.label})",
          " [",
          if (ar.isAddon) "+",
          "${ar.armor}",
          if (armorBonus > 0) " (${ar.armor + armorBonus})",
          if (modsAndGear.isNotEmpty) ", w/ $modsAndGear",
          "]",
        ].join();
      }).toList();

  int get characterArmor => _characterArmorCache(_character!.armor)();
  static final _characterArmorCache = cache1state((List<Armor> armor) => () => _calculateCharacterArmor(armor));
  static int _calculateCharacterArmor(List<Armor> armor) {
    final equipped = armor.where((ar) => ar.equipped);
    final withCustomFit = equipped.where((a) => a.armorCustomFitStack != null);
    final base = equipped
        .where((ar) => !ar.isAddon)
        .map((ar) => ar.armor + _calculateArmorBonus(ar) + _calculateCustomFitStackBonus(ar, withCustomFit))
        .fold<int>(0, (acc, bonus) => max(acc, bonus));
    final addons = equipped.where((ar) => ar.isAddon).fold<int>(0, (acc, ar) => acc += ar.armor + _calculateArmorBonus(ar));
    return base + addons;
  }

  static int _calculateArmorBonus(Armor ar) => ar.mods.map((am) => am.armor).fold<int>(0, (acc, bonus) => acc + bonus);
  static int _calculateCustomFitStackBonus(Armor ar, Iterable<Armor> armors) => armors
      .where((a) => a.armorCustomFitStack != null && a.armorCustomFitStack!.nameOfCustomFit.toLowerCase() == ar.name.toLowerCase())
      .map((a) => a.armorCustomFitStack!)
      .fold(0, (acc, customFit) => max(acc, customFit.armorBonus));

  bool get hasVehicles => vehicles.isNotEmpty;
  List<String> get vehicles => _vehiclesCache(_character!.vehicles)();
  static final _vehiclesCache = cache1state((List<Vehicle> vehicles) => () => _vehiclesToStrings(vehicles));
  static List<String> _vehiclesToStrings(List<Vehicle> vehicles) => vehicles.map((v) {
        final mods = v.mods.map((m) {
          return "${m.name}" + (m.rating > 0 ? " ${m.rating}" : "");
        });
        final mounts = v.mounts.map((wm) {
          return "${wm.name} (" +
              [
                if (wm.visibility != null) "${wm.visibility}",
                if (wm.flexibility != null) "${wm.flexibility}",
                if (wm.control != null) "${wm.control}",
                ...wm.weapons.map((w) => w.name)
              ].join(", ") +
              ")";
        });
        final gear = v.gear.map((g) {
          return (g.quantity > 1 ? "${g.quantity} " : "") + "${g.name}" + (g.rating > 0 ? " ${g.rating}" : "");
        });

        return "${v.name} [" +
            [
              "Handling ${v.handling}" + (v.handling != v.offroadHandling ? "/${v.offroadHandling}" : ""),
              "Speed ${v.speed}" + (v.speed != v.offroadSpeed ? "/${v.offroadSpeed}" : ""),
              "Accel ${v.acceleration}" + (v.acceleration != v.offroadAcceleration ? "/${v.offroadAcceleration}" : ""),
              "Body ${v.body}",
              "Armor ${v.armor}",
              if (v.pilot > 0) "Pilot ${v.pilot}",
              "Sensor ${v.sensor}",
              if (v.seats > 0) "Passengers ${v.seats}",
              ...mods,
              ...mounts,
              ...gear,
            ].join(", ") +
            "]";
      }).toList();

  bool get hasContacts => _character!.contacts.isNotEmpty;
  List<String> get contacts => _character!.contacts.map((c) {
        return [
          "${c.role}",
          if (c.location.isNotEmpty) " in ${c.location}",
          " (Connection ${c.connection}, Loyalty ${c.loyalty})",
          if (c.name.isNotEmpty) ": ${c.name}",
        ].join();
      }).toList();

  String get nuyenSymbol => "\u00A5";
  double get nuyen => _character!.nuyen;
  String get displayNuyen => "${nuyen.floor().toString()}$nuyenSymbol";

  int get karma => _character!.karma;
}
