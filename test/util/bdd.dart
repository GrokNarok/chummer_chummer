import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chummer_chummer/state.dart';
import 'package:chummer_chummer/services/store_extension.dart';
import 'package:chummer_chummer/services/file_service.dart';
import 'package:chummer_chummer/main.dart';

/// This is the top level test object, it's intended to follow a user story.
///
/// Instances of this class should be created for each tested feature.
/// Stories consist of description and one or more scenarios which
/// encapsulate actual steps of using a feature.
///
/// Example:
/// ```
/// var story = Story("Language settings")
///   ..asA("user")
///   ..iWant("to be able to change language")
///   ..soThat("I can use read text in the app");
///
/// story.scenario(title: "user is on the login page")
///   ..given(onLoginPage)
///   ..when(iSelectLanguageFromMenu)
///   ..then(textIsDisplayedInSelectedLanguage);
///
/// final TestStep onLoginPage = TestStep("user is on the login page", (_) {
///   // This is the default starting page - no need to navigate, just confirm it's login page.
///   expect(find.text("Please login"), findsOneWidget);
/// }));
///
/// final TestStep iSelectLanguageFromMenu = TestStep("i select a different language from the menu", (_) {
///   await tester.tap(find.byKey(Key("menu_language_lojban")));
///   await tester.pump();
/// });
///
///
/// final TestStep textIsDisplayedInSelectedLanguage = TestStep("the text is displayed in the selected language", (context) {
///   expect(find.text("e'o ko login"), findsOneWidget);
/// });
///
/// ```
///
/// Once constructed, a story can be executed via the [execute] method.
/// All of the common dependencies will be provided for the test steps automatically.
class Story {
  final String title;
  final List<Scenario> _scenarios;
  String? _role;
  String? _feature;
  String? _benefit;

  Story(this.title) : _scenarios = <Scenario>[];

  void asA(String role) {
    _role = role;
  }

  void iWant(String feature) {
    _feature = feature;
  }

  void soThat(String benefit) {
    _benefit = benefit;
  }

  Scenario scenario(String title) {
    final scenario = Scenario(title: title);
    _scenarios.add(scenario);
    return scenario;
  }

  void execute() {
    assert(_role != null);
    assert(_feature != null);
    assert(_benefit != null);

    group("Story: $title (as a $_role I want $_feature so that $_benefit)", () {
      for (var scenario in _scenarios) {
        scenario.execute();
      }
    });
  }
}

typedef StepClosure = Future<void> Function(WidgetTester);

/// This is a specific scenario of a user story.
///
/// A [Scenario] consists of:
///
/// [given]s - things assumed to be true is the scenario
///
/// [when]s - actions the user takes
///
/// [then]s - expected results
class Scenario {
  final String title;
  final _testStepInfos = <_TestStepInfo>[];

  Scenario({required this.title});

  void given(TestStep step) {
    _testStepInfos.add(_TestStepInfo("given", step));
  }

  void when(TestStep step) {
    _testStepInfos.add(_TestStepInfo("when", step));
  }

  void then(TestStep step) {
    _testStepInfos.add(_TestStepInfo("then", step));
  }

  void silent(TestStep step) {
    _testStepInfos.add(_TestStepInfo("", step, silent: true));
  }

  void execute() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    testWidgets(_toString(), (WidgetTester tester) async {
      binding.renderView.configuration = TestViewConfiguration(size: const Size(1920, 1080));

      // Setup App for testing
      SharedPreferences.setMockInitialValues({}); // Makes SharedPreferences work in tests.
      await tester.runAsync(() async {
        await tester.pumpWidget(App(
          store: StoreWithServices<AppState>(
            initialState: AppState.initial(),
            fileService: FileServiceDisconnected(),
          ),
        ));
        await tester.pump();
        await tester.pump();

        // Run test steps
        for (var stepInfo in _testStepInfos) {
          await stepInfo.step.closure(tester);
        }

        await tester.pump();
      });
    });
  }

  String _toString() {
    String? lastPrefix;

    final steps = _testStepInfos.where((stepInfo) => !stepInfo.silent).map<String>((stepInfo) {
      final sameAsLast = stepInfo.prefix == lastPrefix;
      lastPrefix = stepInfo.prefix;
      return [
        if (sameAsLast) "and ",
        "${stepInfo.prefix} ${stepInfo.step.description}",
      ].join();
    }).join("\n\t\t");

    return "\n\tScenario: $title\n\t\t$steps";
  }
}

class _TestStepInfo {
  final String prefix;
  final TestStep step;
  final bool silent;

  const _TestStepInfo(this.prefix, this.step, {this.silent = false});
}

/// This contains a description of the step and the actual test code to execute.
class TestStep {
  final String description;
  final StepClosure closure;

  const TestStep(this.description, this.closure);
}
