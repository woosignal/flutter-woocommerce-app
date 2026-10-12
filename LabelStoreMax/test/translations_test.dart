import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Translation tests.
///
/// This template ships 12 languages. `NyLocalization.translate()` returns the
/// raw key when a translation is missing, so a key present in `en.json` and
/// absent from `de.json` shows a German customer the English key verbatim -
/// there is no fallback to English. These tests are the guard against that,
/// and they are meant to stay: add a key to one file and the suite tells you
/// which of the other eleven you forgot.
///
/// They read `lang/` off disk and need nothing else, so they do not boot the
/// app.
void main() {
  NyTest.init();

  /// Every key in a language file, with nested keys flattened to
  /// "nylo.journey.next".
  Map<String, String> flatten(Map<String, dynamic> json, [String prefix = '']) {
    Map<String, String> flat = {};
    json.forEach((key, value) {
      String path = prefix.isEmpty ? key : "$prefix.$key";
      if (value is Map<String, dynamic>) {
        flat.addAll(flatten(value, path));
      } else {
        flat[path] = value.toString();
      }
    });
    return flat;
  }

  Map<String, Map<String, String>> load() {
    Map<String, Map<String, String>> languages = {};
    for (FileSystemEntity entity in Directory('lang').listSync()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      String code =
          entity.uri.pathSegments.last.replaceAll('.json', '');
      languages[code] =
          flatten(jsonDecode(entity.readAsStringSync()) as Map<String, dynamic>);
    }
    return languages;
  }

  final Map<String, Map<String, String>> languages = load();
  final Map<String, String> english = languages['en']!;
  final List<String> others = languages.keys.where((c) => c != 'en').toList()
    ..sort();

  /// The keys the framework itself looks up. A missing one shows the raw key
  /// inside a Nylo widget - the not-found page, the pull-to-refresh footer,
  /// the confirm dialog.
  const List<String> nyloKeys = [
    'nylo.confirm_action.cancel',
    'nylo.confirm_action.confirm',
    'nylo.collection_view.no_results',
    'nylo.collection_view.pull_up',
    'nylo.collection_view.failed',
    'nylo.collection_view.release',
    'nylo.page_not_found.title',
    'nylo.page_not_found.message',
    'nylo.page_not_found.go_back',
    'nylo.form_picker.select',
    'nylo.form_picker.clear',
    'nylo.journey.step',
    'nylo.journey.of',
    'nylo.journey.back',
    'nylo.journey.next',
    'nylo.journey.finish',
    'nylo.language_switcher.title',
    'nylo.offline_banner.message',
  ];

  final RegExp placeholder = RegExp(r'\{\{(\w+)\}\}');

  nyGroup('language files', () {
    nyTest('all twelve are present and parse', () async {
      expect(languages.length, 12);
      expect(languages.keys.toList()..sort(), [
        'de', 'en', 'es', 'fr', 'hi', 'id',
        'it', 'nl', 'pt', 'th', 'tr', 'zh',
      ]);
      for (Map<String, String> language in languages.values) {
        expect(language, isNotEmpty);
      }
    });

    nyTest('every file holds exactly the same keys as English', () async {
      for (String code in others) {
        Set<String> missing =
            english.keys.toSet().difference(languages[code]!.keys.toSet());
        Set<String> extra =
            languages[code]!.keys.toSet().difference(english.keys.toSet());

        expect(missing, isEmpty,
            reason: 'lang/$code.json is missing ${missing.length} key(s) that '
                'lang/en.json has - each one renders as the raw English key '
                'for a $code customer: $missing');
        expect(extra, isEmpty,
            reason: 'lang/$code.json has ${extra.length} key(s) no other file '
                'has, so nothing looks them up: $extra');
      }
    });

    nyTest('no translation is blank', () async {
      for (MapEntry<String, Map<String, String>> language
          in languages.entries) {
        List<String> blank = language.value.entries
            .where((entry) => entry.value.trim().isEmpty)
            .map((entry) => entry.key)
            .toList();

        expect(blank, isEmpty,
            reason: 'lang/${language.key}.json has empty values, which render '
                'as empty text on screen: $blank');
      }
    });
  });

  nyGroup('the framework block', () {
    nyTest('every file carries the full nylo block', () async {
      for (MapEntry<String, Map<String, String>> language
          in languages.entries) {
        for (String key in nyloKeys) {
          expect(language.value.containsKey(key), isTrue,
              reason: 'lang/${language.key}.json is missing "$key". The '
                  'framework looks this up itself and shows the raw key when '
                  'it is not there.');
          expect(language.value[key]!.trim(), isNotEmpty,
              reason: 'lang/${language.key}.json leaves "$key" blank');
        }
      }
    });

    nyTest('the not-found page keys the app points at exist', () async {
      // not_found_page.dart translates through the framework's own keys
      // rather than app keys of its own.
      expect(english['nylo.page_not_found.title'], "Page Not Found");
      expect(english['nylo.page_not_found.message'],
          "Sorry, the page you have requested is not available.");
    });
  });

  nyGroup('placeholders', () {
    nyTest('every translation carries the same placeholders as English',
        () async {
      for (String code in others) {
        for (MapEntry<String, String> entry in english.entries) {
          Set<String> expected = placeholder
              .allMatches(entry.value)
              .map((match) => match.group(1)!)
              .toSet();
          String? translated = languages[code]![entry.key];
          if (translated == null) continue;
          Set<String> actual = placeholder
              .allMatches(translated)
              .map((match) => match.group(1)!)
              .toSet();

          expect(actual, expected,
              reason: 'lang/$code.json "${entry.key}" must interpolate the '
                  'same values as English. A dropped placeholder loses the '
                  'number; an invented one renders literally.');
        }
      }
    });

    nyTest('the keys that take arguments still have their placeholders',
        () async {
      // These are passed `arguments:` at the call site.
      expect(english['Spend a minimum of minimumAmount to redeem'],
          contains("{{minimumAmount}}"));
      expect(english['Spend less than maximumAmount to redeem'],
          contains("{{maximumAmount}}"));
    });
  });

  nyGroup('the buttons a customer has to understand', () {
    nyTest('the pay button is translated everywhere', () async {
      // "CHECKOUT" is the label on the button that takes the payment. It has
      // been wrong here before - rendered as "verify", "look at" and, in
      // Turkish, "log out".
      for (String code in others) {
        expect(languages[code]!['CHECKOUT'], isNot("CHECKOUT"),
            reason: 'lang/$code.json leaves the pay button in English');
      }
    });

    nyTest('the cancel button is translated everywhere', () async {
      for (String code in others) {
        expect(languages[code]!['CANCEL'], isNot("CANCEL"),
            reason: 'lang/$code.json leaves the cancel button in English');
      }
    });

    nyTest('the login label is translated where the word differs', () async {
      // "Login" is the same loanword in German, Dutch, Italian and
      // Indonesian, so those four are expected to match English.
      const Set<String> loanwordLocales = {'de', 'nl', 'it', 'id'};

      for (String code in others) {
        if (loanwordLocales.contains(code)) continue;
        expect(languages[code]!['Login'], isNot("Login"),
            reason: 'lang/$code.json leaves the login label in English');
      }
    });
  });
}
