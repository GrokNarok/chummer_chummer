import 'dart:math';

import 'package:xml/xml.dart';

import 'package:chummer_chummer/util/error.dart';
import 'package:chummer_chummer/util/pair.dart';
import 'package:chummer_chummer/features/stat_block_page/data.dart';
import 'package:chummer_chummer/features/stat_block_page/constants.dart';

class CharacterFileParser {
  static Future<ErrorOr<CharacterBuilder>> parse(String xmlContents) async {
    try {
      final char = XmlDocument.parse(xmlContents).findAllElements("character").single;

      String name;
      final alias = char.findElements("alias");
      if (alias.length == 1 && alias.first.text.isNotEmpty) {
        name = alias.first.text;
      } else {
        name = char.findString("name");
        if (name.isEmpty) name = "Unnamed";
      }

      final metatype = char.findString("metatype");
      final metavariant = char.findString("metavariant");

      final reaction = _getAttribute(char, "REA");
      final intuition = _getAttribute(char, "INT");

      final isTechnomancer = char.findBool("technomancer");

      return ErrorOr(CharacterBuilder()
        ..name = name
        ..metatype = metatype
        ..metavariant = (metavariant.isNotEmpty && metavariant.toLowerCase() != "none" && metavariant != metatype) ? metavariant : null
        ..body = _getAttribute(char, "BOD")
        ..agility = _getAttribute(char, "AGI")
        ..reaction = reaction
        ..strength = _getAttribute(char, "STR")
        ..willpower = _getAttribute(char, "WIL")
        ..logic = _getAttribute(char, "LOG")
        ..intuition = intuition
        ..charisma = _getAttribute(char, "CHA")
        ..magic = char.findBool("magician") || char.findBool("adept") || char.findBool("critter") ? _getAttribute(char, "MAG") : null
        ..resonance = isTechnomancer ? _getAttribute(char, "RES") : null
        ..depth = char.findBool("ai") ? _getAttribute(char, "DEP") : null
        ..edge = _getAttribute(char, "EDG")
        ..currentEdge = _getEdge(char)
        ..essence = char.findDouble("totaless")
        ..initiative = Initiative(base: (reaction.total + intuition.total), dice: _getInitiativeDice(char))
        ..reach = _getReach(char)
        ..physicalCondition = int.parse(char.findAllElements("physicalcm").first.text)
        ..stunCondition = int.parse(char.findAllElements("stuncm").first.text)
        ..activeSkills = _getSkills(char, SkillType.active)
        ..knowledgeSkills = _getSkills(char, SkillType.knowledge)
        ..languageSkills = _getSkills(char, SkillType.language)
        ..powers = _getAllPowers(char)
        ..qualities = _getQualities(char)
        ..martialArts = _getAllMartialArts(char)
        ..adeptPowers = _getAdeptPowers(char)
        ..initiationGrade = char.findInt("initiategrade")
        ..metamagic = !isTechnomancer ? _getAllMetamagicOrEchoes(char) : []
        ..arts = _getAllArts(char)
        ..spells = _getAllSpells(char, isAlchemical: false)
        ..alchemicalPreparations = _getAllSpells(char, isAlchemical: true)
        ..spirits = _getAllSpirits(char)
        ..submersionGrade = char.findInt("submersiongrade")
        ..echoes = isTechnomancer ? _getAllMetamagicOrEchoes(char) : []
        ..complexForms = _getAllComplexForms(char)
        ..sprites = _getAllSprites(char)
        ..cyberware = _getAllCyberware(char)
        ..gear = _getAllGear(char)
        ..weapons = _getAllWeapons(char)
        ..armor = _getAllArmor(char)
        ..vehicles = _getAllVehicles(char)
        ..contacts = _getAllContacts(char)
        ..nuyen = char.findDouble("nuyen")
        ..karma = char.findInt("karma")
        ..improvements = _getAllConditionalImprovements(char));
    } catch (e) {
      return ErrorOr.error(ErrorData(ErrorCodes.parseFail, ErrorLevels.error, "Failed to parse the character file: $e"));
    }
  }

  static int _getEdge(XmlElement char) {
    final currentEdge = _getAttribute(char, "EDG").total;
    final it = char.findElements("improvements").single.findElements("improvement").where((n) => n.findString("improvedname") == "EDG");
    if (it.length != 1) {
      return currentEdge; // if there is no "improvement" the max edge = current edge
    }
    final edgeAdjustment = it.single.findInt("aug"); // negative value, adjusting from max to current edge
    return currentEdge - edgeAdjustment;
  }

  static int _getInitiativeDice(XmlElement char) {
    final found = char.findElements("initiativedice");
    final dice = (found.length == 1) ? int.parse(found.single.text) : 1;
    final diceBonuses = _getImprovements(char, type: "InitiativeDice") //
        .map((i) => i.findInt("val"))
        .fold<int>(0, (acc, a) => acc + a);

    return dice + diceBonuses;
  }

  static int _getReach(XmlElement char) {
    final reach = _getImprovements(char, type: "Reach");
    return reach.isNotEmpty //
        ? reach.map((i) => i.findInt("val")).fold<int>(0, (acc, a) => acc + a)
        : 0;
  }

  static Attribute _getAttribute(XmlElement char, String attrName) {
    final attribute = _getAttributeElement(char, attrName);
    return Attribute(
      base: attribute.findInt("metatypemin") + attribute.findInt("base") + attribute.findInt("karma"),
      total: attribute.findInt("totalvalue"),
    );
  }

  static XmlElement _getAttributeElement(XmlElement char, String attrName) =>
      char.findElements("attributes").single.findElements("attribute").where((n) => n.findString("name") == attrName).single;

  static List<Skill> _getSkills(XmlElement char, SkillType type) {
    Skill getSkill(XmlElement skill, SkillType type, List<Skill> skillGroups) {
      final specific = skill.findElements("specific"); // Exotic skills have "specific" instead of "name"
      final name = specific.isNotEmpty ? "Exotic (${specific.single.text})" : skill.findString("name");

      final base = skill.findInt("base");
      final karma = skill.findInt("karma");
      var rating = base + karma;
      var specializations = <String>[];
      if (type == SkillType.active) {
        final skillGroupForThisSkill = skillGroupMapping[name];
        if (skillGroupForThisSkill != null) {
          rating += skillGroups.where((sg) => sg.name == skillGroupForThisSkill).single.rating;
        }
        specializations.addAll(skill.findAllElements("spec").map((s) => s.findString("name")));
      }
      return Skill(name: name, rating: rating, specializations: specializations);
    }

    var skillGroups = <Skill>[];
    // Skill groups only apply to active skills so don't bother for the rest
    if (type == SkillType.active) {
      // Skill groups have same structure as skills so be can reuse _getSkill()
      skillGroups.addAll(char.findAllElements("groups").single.findElements("group").map((group) => getSkill(group, SkillType.group, [])));
    }

    final skills = char
        .findAllElements("skill") //
        .where((s) => s.findString("isknowledge") == (type == SkillType.active ? "False" : "True"))
        .where((s) {
      if (type == SkillType.active) {
        return true;
      }
      final isLang = s.findString("type") == "Language";
      return type == SkillType.language ? isLang : !isLang;
    }) //
        .map((s) => getSkill(s, type, skillGroups));

    // Order highest to lowest but treat 0 as the highest as it indicates native proficiency in a language
    if (type == SkillType.language) {
      return skills.toList()
        ..sort((a, b) => a.rating == 0
            ? -999
            : b.rating == 0
                ? 999
                : b.rating.compareTo(a.rating));
    } else {
      return skills.toList()..sort((a, b) => b.rating.compareTo(a.rating));
    }
  }

  static List<Power> _getAllPowers(XmlElement char) {
    return char.findElements("critterpowers").single.findElements("critterpower").map((p) {
      return Power(
        name: p.findString("name"),
        extra: p.findString("extra"),
        rating: p.findInt("rating"),
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<Power> _getQualities(XmlElement char) {
    // Chummer5 duplicates quality entries to indicate that a quality is of higher Rating, so we need to count duplicates and convert that to Rating score.
    final uniqueQualities = <String, Pair<XmlElement, int>>{};
    char.findElements("qualities").single.findElements("quality").forEach((quality) {
      final id = quality.findString("sourceid");
      if (!uniqueQualities.containsKey(id)) {
        uniqueQualities[id] = Pair(quality, 1);
      } else {
        uniqueQualities[id] = Pair(quality, uniqueQualities[id]!.last + 1);
      }
    });

    return uniqueQualities.values.map((pair) {
      return Power(
        name: pair.first.findString("name"),
        extra: pair.first.findString("extra"),
        rating: pair.last,
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<MartialArt> _getAllMartialArts(XmlElement char) {
    return char.findElements("martialarts").single.findElements("martialart").map((ma) {
      return MartialArt(
        name: ma.findString("name"),
        techniques: ma.findElements("martialarttechniques").single.findElements("martialarttechnique").map((mat) {
          return mat.findString("name");
        }).toList()
          ..sort(),
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<Power> _getAdeptPowers(XmlElement char) {
    return char.findElements("powers").single.findElements("power").map((p) {
      return Power(
        name: p.findString("name"),
        extra: p.findString("extra"),
        rating: p.findInt("rating"),
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<String> _getAllMetamagicOrEchoes(XmlElement char) {
    return char.findElements("metamagics").single.findElements("metamagic").map((mm) {
      return mm.findString("name");
    }).toList()
      ..sort();
  }

  static List<String> _getAllArts(XmlElement char) {
    return char.findElements("arts").single.findElements("art").map((a) {
      return a.findString("name");
    }).toList()
      ..sort();
  }

  static List<String> _getAllSpells(XmlElement char, {required bool isAlchemical}) {
    return char.findElements("spells").single.findElements("spell").where((s) => s.findBool("alchemical") == isAlchemical).map((s) {
      return s.findString("name");
    }).toList()
      ..sort();
  }

  static List<Spirit> _getAllSpirits(XmlElement char) {
    return char.findElements("spirits").single.findElements("spirit").where((s) => s.findString("type").toLowerCase() == "spirit").map((s) {
      return Spirit(
        type: s.findString("name"),
        critterName: s.findString("crittername"),
        force: s.findInt("force"),
        services: s.findInt("services"),
        bound: s.findBool("bound"),
        fettered: s.findBool("fettered"),
      );
    }).toList()
      ..sort((a, b) => a.type.compareTo(b.type));
  }

  static List<String> _getAllComplexForms(XmlElement char) {
    return char.findElements("complexforms").single.findElements("complexform").map((cf) {
      return cf.findString("name");
    }).toList()
      ..sort();
  }

  static List<Sprite> _getAllSprites(XmlElement char) {
    // Chummer5 just lists sprites as spirits and used spirit terms
    return char.findElements("spirits").single.findElements("spirit").where((s) => s.findString("type").toLowerCase() == "sprite").map((s) {
      return Sprite(
        type: s.findString("name"),
        spriteName: s.findString("crittername"),
        rating: s.findInt("force"),
        tasksOwed: s.findInt("services"),
        registered: s.findBool("bound"),
        spritePet: s.findBool("fettered"),
      );
    }).toList()
      ..sort((a, b) => a.type.compareTo(b.type));
  }

  static final _limbAugmentNames = ["Armor", "Customized Agility", "Customized Strength", "Enhanced Agility", "Enhanced Strength"];
  static List<Cyberware> _getAllCyberware(XmlElement char) {
    List<Cyberware> getCyberware(XmlElement cyberwares) {
      return cyberwares
          .findElements("cyberware")
          .map((cyber) {
            final name = cyber.findString("name");
            final rating = cyber.findInt("rating");
            final grade = cyber.findString("grade");
            final components = getCyberware(cyber.findElements("children").single);
            final limbAugments = components.where((c) => _limbAugmentNames.contains(c.name)).toList();
            final otherComponents = components.where((c) => !_limbAugmentNames.contains(c.name)).toList();
            int? agi, str, armour;
            if (limbAugments.isNotEmpty) {
              // Default limb agi/str is 3 unless the character's natural limits are lower.
              final defaultAgi = min(3, _getAttributeElement(char, "AGI").findInt("metatypemax"));
              final defaultStr = min(3, _getAttributeElement(char, "STR").findInt("metatypemax"));

              // Using fold on a list of 0 or 1 items to get the initial value if the list is empty or the rating of the element if the list has an element.
              agi = limbAugments.where((a) => a.name == "Customized Agility").fold<int>(defaultAgi, (_, element) => element.rating);
              agi += limbAugments.where((a) => a.name == "Enhanced Agility").fold<int>(0, (_, element) => element.rating);

              str = limbAugments.where((a) => a.name == "Customized Strength").fold<int>(defaultStr, (_, element) => element.rating);
              str += limbAugments.where((a) => a.name == "Enhanced Strength").fold<int>(0, (_, element) => element.rating);

              armour = limbAugments.where((a) => a.name == "Armor").fold<int?>(null, (_, element) => element.rating);
            }

            return Cyberware(name: name, rating: rating, grade: grade, agi: agi, str: str, armour: armour, components: otherComponents);
          })
          .where((q) => !q.name.contains("Essence Hole")) // Essence Holes are included as cyberware but we don't want them.
          .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
    }

    return getCyberware(char.findElements("cyberwares").single);
  }

  static List<Gear> _getAllGear(XmlElement element) {
    List<Gear> getGear(XmlElement gear) {
      return gear
          .findElements("gear")
          .map((g) => Gear(
                name: g.findString("name"),
                rating: g.findInt("rating"),
                quantity: g.findDouble("qty").toInt(), // qty is sometimes fractional in the save file
                components: getGear(g.findElements("children").single),
              ))
          .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
    }

    return getGear(element.findElements("gears").single);
  }

  static List<Weapon> _getAllWeapons(XmlElement element, {bool isUnderbarrel = false}) {
    // In the Chummer5 file underbarrel weapons are each wrapped in an <underbarrel> tag
    final weapons = isUnderbarrel
        ? element.findElements("underbarrel").map((ubw) => ubw.findElements("weapon")).flatten()
        : element.findElements("weapons").single.findElements("weapon");

    return weapons.map((w) {
      final accuracy = w.findElements("accuracy").first.text; // For some reason accuracy is listed twice in the save file
      final usesPhysicalAccuracy = accuracy.toLowerCase() == "physical";
      final mode = w.findString("mode");
      final recoilCompensation = w.findString("rc");
      final ammo = w.findString("ammo");
      final isMelee = w.findString("type") == "Melee";
      return Weapon(
        name: w.findString("name"),
        category: w.findString("category"),
        isMelee: isMelee,
        reach: w.findInt("reach"),
        usesPhysicalAccuracy: usesPhysicalAccuracy,
        accuracy: usesPhysicalAccuracy ? 0 : int.tryParse(accuracy) ?? 0,
        damage: w.findString("damage"),
        armourPenetration: w.findString("ap"),
        mode: (mode.isNotEmpty && mode != "0") ? mode : null,
        recoilCompensation: (recoilCompensation.isNotEmpty && !isMelee) ? int.parse(recoilCompensation) : null,
        ammo: (ammo.isNotEmpty && ammo != "0") ? ammo : null,
        accessories: _getAllAccessories(w),
        underbarrelWeapons: _getAllWeapons(w, isUnderbarrel: true),
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<Accessory> _getAllAccessories(XmlElement element) {
    final accessories = element.findElements("accessories");
    if (accessories.isEmpty) {
      return [];
    }

    return accessories.single.findElements("accessory").map((a) {
      final recoilCompensationStr = a.findString("rc");
      final recoilCompensation = recoilCompensationStr.isNotEmpty ? int.parse(recoilCompensationStr) : 0;
      final deployedRC = a.findBool("rcdeployable");
      return Accessory(
          name: a.findString("name"),
          rating: a.findInt("rating"),
          accuracy: a.findInt("accuracy"),
          recoilCompensationGroup: a.findInt("rcgroup"),
          recoilCompensation: !deployedRC ? recoilCompensation : 0,
          deployedRecoilCompensation: deployedRC ? recoilCompensation : 0,
          included: a.findBool("included"),
          gear: a.findElements("gears").isNotEmpty ? _getAllGear(a) : []);
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<Armor> _getAllArmor(XmlElement char) {
    return char.findElements("armors").single.findElements("armor").map((a) {
      final armor = a.findString("armor");
      final isAddon = armor.contains("+");
      final mods = a
          .findElements("armormods")
          .single
          .findElements("armormod")
          .map((am) => ArmorMod(
              name: am.findString("name"),
              rating: am.findInt("rating"),
              included: am.findBool("included"),
              armor: am.findInt("armor"),
              extra: am.findString("extra")))
          .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      final armorCustomFitStackBonus = a.findInt("armoroverride");
      final armorCustomFitStackName = mods.where((am) => am.name.toLowerCase().contains("custom fit (stack)")).map((am) => am.extra);
      final hasArmorCustomFitStack = armorCustomFitStackName.length == 1;
      return Armor(
        name: a.findString("name"),
        label: a.findString("armorname"),
        armor: int.tryParse(armor) ?? 0,
        isAddon: isAddon,
        equipped: a.findBool("equipped"),
        armorCustomFitStack:
            hasArmorCustomFitStack ? ArmorCustomFitStack(nameOfCustomFit: armorCustomFitStackName.single, armorBonus: armorCustomFitStackBonus) : null,
        mods: mods,
        gear: a.findElements("gears").isNotEmpty ? _getAllGear(a) : [],
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<Vehicle> _getAllVehicles(XmlElement char) {
    return char.findElements("vehicles").single.findElements("vehicle").map((v) {
      return Vehicle(
        name: v.findString("name"),
        handling: v.findInt("handling"),
        offroadHandling: v.findInt("offroadhandling"),
        speed: v.findInt("speed"),
        offroadSpeed: v.findInt("offroadspeed"),
        acceleration: v.findInt("accel"),
        offroadAcceleration: v.findInt("offroadaccel"),
        body: v.findInt("body"),
        armor: v.findInt("armor"),
        pilot: v.findInt("pilot"),
        sensor: v.findInt("sensor"),
        seats: v.findInt("seats"),
        mods: v.findElements("mods").single.findElements("mod").map((am) {
          return Mod(name: am.findString("name"), rating: am.findInt("rating"), included: am.findBool("included"));
        }).toList()
          ..sort((a, b) => a.name.compareTo(b.name)),
        mounts: v.findElements("weaponmounts").single.findElements("weaponmount").map((wm) {
          String? getWeaponMountOption(XmlElement weaponMount, String category) {
            final option = weaponMount.findAllElements("weaponmountoption").where((wmo) => wmo.findString("category").toLowerCase() == category.toLowerCase());
            return (option.length == 1) ? option.single.findString("name") : null;
          }

          return WeaponMount(
            name: wm.findString("name"),
            visibility: getWeaponMountOption(wm, "visibility"),
            flexibility: getWeaponMountOption(wm, "flexibility"),
            control: getWeaponMountOption(wm, "control"),
            weapons: _getAllWeapons(wm),
          );
        }).toList(),
        gear: v.findElements("gears").isNotEmpty ? _getAllGear(v) : [],
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<Contact> _getAllContacts(XmlElement char) {
    return char.findElements("contacts").single.findElements("contact").map((c) {
      return Contact(
        name: c.findString("name"),
        role: c.findString("role"),
        location: c.findString("location"),
        connection: c.findInt("connection"),
        loyalty: c.findInt("loyalty"),
      );
    }).toList()
      ..sort((a, b) => a.role.compareTo(b.role));
  }

  static Improvements _getAllConditionalImprovements(XmlElement char) {
    final out = Improvements();
    char.findElements("improvements").single.findElements("improvement").forEach((improvementElement) {
      final type = improvementsByName[improvementElement.findString("improvementttype")];
      // Skip improvements that are not in our list:
      if (type == null) return;

      /// See documentation of [Character]'s [improvements] field for more clarity on this.
      final name = improvementElement.findString("improvedname");
      final value = improvementElement.findDouble("val");
      final improvement = out[type];
      if (improvement != null) {
        improvement[name] = (improvement[name] ?? 0) + value;
      } else {
        out[type] = {name: value};
      }
    });

    return out;
  }

  /// Get all improvements of a certain type.
  /// This is used for permanent improvements that are incorporated into base values.
  /// For conditional improvements use _getAllConditionalImprovements()
  static List<XmlElement> _getImprovements(XmlElement char, {required String type}) {
    return char
        .findElements("improvements")
        .single
        .findElements("improvement")
        .where((i) => i.findString("improvementttype").toLowerCase() == type.toLowerCase())
        .toList();
  }
}

extension XmlElementHelpers on XmlElement {
  String findString(String name) => this.findElements(name).single.text;
  int findInt(String name) => int.tryParse(this.findString(name)) ?? 0;
  double findDouble(String name) => double.tryParse(this.findString(name)) ?? 0.0;
  bool findBool(String name) => this.findString(name).toLowerCase() == "true";
}
