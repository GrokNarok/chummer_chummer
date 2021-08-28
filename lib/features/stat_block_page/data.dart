import 'package:built_value/built_value.dart';

part 'data.g.dart';

/// List of used conditional improvements, subset of Chummer5's list in ImprovementMethods.cs
enum ImprovementType {
  unarmedReach,
  weaponAccuracy,
  weaponSkillAccuracy,
}

class Attribute {
  final int base;
  final int total;

  Attribute({required this.base, required this.total});
}

class Initiative {
  final int base;
  final int dice;

  Initiative({required this.base, required this.dice});
}

enum SkillType {
  active,
  knowledge,
  language,
  group,
}

class Skill {
  final String name;
  final int rating;
  final List<String> specializations;

  Skill({required this.name, required this.rating, required this.specializations});
}

class Power {
  final String name;
  final String extra;
  final int rating;

  Power({required this.name, required this.extra, required this.rating});
}

class MartialArt {
  final String name;
  final List<String> techniques;

  MartialArt({required this.name, required this.techniques});
}

class Spirit {
  final String type;
  final String critterName;
  final int force;
  final int services;
  final bool bound;
  final bool fettered;

  Spirit({required this.type, required this.critterName, required this.force, required this.services, required this.bound, required this.fettered});
}

class Sprite {
  final String type;
  final String spriteName;
  final int rating;
  final int tasksOwed;
  final bool registered;
  final bool spritePet;

  Sprite({required this.type, required this.spriteName, required this.rating, required this.tasksOwed, required this.registered, required this.spritePet});
}

class Cyberware {
  final String name;
  final int rating;
  final String grade;
  final int? agi;
  final int? str;
  final int? armour;
  final List<Cyberware> components;

  Cyberware({required this.name, required this.rating, required this.grade, this.agi, this.str, this.armour, this.components = const []});
}

class Gear {
  final String name;
  final int rating;
  final int quantity;
  final List<Gear> components;

  Gear({required this.name, required this.rating, this.quantity = 1, this.components = const []});
}

class Accessory {
  final String name;
  final int rating;
  final int accuracy;
  final int recoilCompensationGroup; // Bonuses from accessories in the same group do not stack
  final int recoilCompensation;
  final int deployedRecoilCompensation; // Recoil compensation when accessory deployed (e.g. tripods)
  final bool included;
  final List<Gear> gear;

  Accessory({
    required this.name,
    required this.rating,
    required this.recoilCompensationGroup,
    required this.recoilCompensation,
    required this.deployedRecoilCompensation,
    required this.accuracy,
    this.included = false,
    this.gear = const [],
  });
}

class Weapon {
  final String name;
  final String category;
  final bool isMelee;
  final int reach;
  final bool usesPhysicalAccuracy; // Some weapon use physical limit for their accuracy.
  final int accuracy;
  final String damage;
  final String armourPenetration;
  final String? mode;
  final int? recoilCompensation;
  final String? ammo;
  final List<Accessory> accessories;
  final List<Weapon> underbarrelWeapons;

  Weapon({
    required this.name,
    required this.category,
    required this.isMelee,
    required this.reach,
    required this.usesPhysicalAccuracy,
    required this.accuracy,
    required this.damage,
    required this.armourPenetration,
    required this.mode,
    required this.recoilCompensation,
    required this.ammo,
    this.accessories = const [],
    this.underbarrelWeapons = const [],
  });
}

class Mod {
  final String name;
  final int rating;
  final bool included;

  Mod({required this.name, required this.rating, this.included = false});
}

class ArmorMod extends Mod {
  final int armor;
  final String extra;

  ArmorMod({required this.armor, required this.extra, required name, required rating, included = false})
      : super(name: name, rating: rating, included: included);
}

class ArmorCustomFitStack {
  final String nameOfCustomFit;
  final int armorBonus;

  ArmorCustomFitStack({required this.nameOfCustomFit, required this.armorBonus});
}

class Armor {
  final String name;
  final String label;
  final int armor;
  final bool isAddon; // Means this is an addon armor, e.g a helmet.
  final bool equipped;
  final ArmorCustomFitStack? armorCustomFitStack; // Some armor acts as a normal armor or as an addon for a specific other armor.
  final List<ArmorMod> mods;
  final List<Gear> gear;

  Armor({
    required this.name,
    this.label = "",
    required this.armor,
    required this.isAddon,
    this.equipped = false,
    this.armorCustomFitStack,
    this.mods = const [],
    this.gear = const [],
  });
}

class Vehicle {
  final String name;
  final int handling;
  final int offroadHandling;
  final int speed;
  final int offroadSpeed;
  final int acceleration;
  final int offroadAcceleration;
  final int body;
  final int armor;
  final int pilot;
  final int sensor;
  final int seats;
  final List<Mod> mods;
  final List<WeaponMount> mounts;
  final List<Gear> gear;

  Vehicle({
    required this.name,
    required this.handling,
    required this.offroadHandling,
    required this.speed,
    required this.offroadSpeed,
    required this.acceleration,
    required this.offroadAcceleration,
    required this.body,
    required this.armor,
    required this.pilot,
    required this.sensor,
    required this.seats,
    this.mods = const [],
    this.mounts = const [],
    this.gear = const [],
  });
}

class WeaponMount {
  final String name;
  final String? visibility;
  final String? flexibility;
  final String? control;
  final List<Weapon> weapons;

  WeaponMount({required this.name, required this.visibility, required this.flexibility, required this.control, required this.weapons});
}

class Contact {
  final String name;
  final String role;
  final String location;
  final int connection;
  final int loyalty;

  Contact({required this.name, required this.role, required this.location, required this.connection, required this.loyalty});
}

typedef Improvements = Map<ImprovementType, Map<String, double>>;

abstract class Character implements Built<Character, CharacterBuilder> {
  factory Character([void updates(CharacterBuilder b)]) = _$Character;
  Character._();

  String? get sourceFilePath;

  String get name;
  String get metatype;
  String? get metavariant;

  Attribute get body;
  Attribute get agility;
  Attribute get reaction;
  Attribute get strength;
  Attribute get willpower;
  Attribute get logic;
  Attribute get intuition;
  Attribute get charisma;

  Attribute? get magic;
  Attribute? get resonance;
  Attribute? get depth;

  Attribute get edge;
  int get currentEdge;

  double get essence;

  Initiative get initiative;

  int get reach;

  int get physicalCondition;
  int get stunCondition;

  List<Skill> get activeSkills;
  List<Skill> get knowledgeSkills;
  List<Skill> get languageSkills;

  List<Power> get powers;
  List<Power> get qualities;
  List<MartialArt> get martialArts;
  List<Power> get adeptPowers;
  int get initiationGrade;
  List<String> get metamagic;
  List<String> get arts;
  List<String> get spells;
  List<String> get alchemicalPreparations;
  List<Spirit> get spirits;
  int get submersionGrade;
  List<String> get echoes;
  List<String> get complexForms;
  List<Sprite> get sprites;
  List<Cyberware> get cyberware;
  List<Gear> get gear;
  List<Weapon> get weapons;
  List<Armor> get armor;
  List<Vehicle> get vehicles;
  List<Contact> get contacts;

  double get nuyen;
  int get karma;

  /// ImprovementType -> ImprovementName -> Value
  ///
  /// Improvement values are categorised by enumerated types and additionally (optionally) by a
  /// [String] name (improvementName), improvement that are not subcategorised use empty string as improvementName.
  ///
  /// E.g. all improvements to accuracy of attacks with a certain skill are recorded under
  /// [ImprovementType.weaponSkillAccuracy] and but the name of the skill is in improvementName.
  Improvements get improvements;
  double getImprovement(ImprovementType type, {String improvementName = ""}) {
    final improvement = improvements[type];
    if (improvement == null) return 0;
    return improvement[improvementName] ?? 0;
  }
}

/*
CharacterBuilder getCanonicalCharacter() => CharacterBuilder()
  ..name = "Canonical Character"
  ..metatype = "Human"
  ..body = Attribute(base: 2, total: 2)
  ..agility = Attribute(base: 3, total: 5)
  ..reaction = Attribute(base: 4, total: 4)
  ..strength = Attribute(base: 5, total: 5)
  ..willpower = Attribute(base: 2, total: 2)
  ..logic = Attribute(base: 3, total: 4)
  ..intuition = Attribute(base: 4, total: 4)
  ..charisma = Attribute(base: 5, total: 5)
  ..magic = null
  ..resonance = null
  ..depth = null
  ..edge = Attribute(base: 7, total: 7)
  ..currentEdge = 7
  ..essence = 6.0
  ..activeSkills = []
  ..knowledgeSkills = []
  ..languageSkills = []
  ..qualities = []
  ..adeptPowers = []
  ..cyberware = []
  ..initiative = Initiative(base: 1, dice: 1)
  ..physicalCondition = 9
  ..stunCondition = 9;
  */
