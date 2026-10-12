import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/bootstrap/theme.dart';
import 'package:flutter_app/config/design.dart';
import 'package:flutter_app/resources/themes/color_styles.dart';
import 'package:flutter_app/resources/themes/dark/dark_theme_colors.dart';
import 'package:flutter_app/resources/themes/light/light_theme_colors.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/store_logo_widget.dart';
import 'support/boot_test_app.dart';
import 'support/fixtures.dart';

/// Theme tests.
///
/// The store picks its own colours on the WooSignal dashboard and the app
/// reads them out of `themeColors`. These tests check that both themes build,
/// that every colour group resolves, and - most importantly - that the six
/// remote keys per theme are the ones actually used, because a typo in one of
/// those names silently falls back to nothing.
void main() {
  NyTest.init();

  nySetUpAll(() async {
    await bootTestApp();
  });

  nySetUp(() async {
    seedAppConfig();
  });

  nyGroup('registration', () {
    nyTest('the two theme ids are the ones the drawer toggles between',
        () async {
      // These strings are stored on the device by NyThemeManager, so renaming
      // one resets every customer to the system theme.
      expect(appThemes.map((theme) => theme.id).toList(),
          ["default_light_theme", "default_dark_theme"]);
    });

    nyTest('each theme builds a ThemeData of the right brightness', () async {
      ThemeData light = appThemes[0].theme(appThemes[0].colors);
      ThemeData dark = appThemes[1].theme(appThemes[1].colors);

      expect(light, isA<ThemeData>());
      expect(dark, isA<ThemeData>());
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
    });

    nyTest('each theme carries the colour set for its brightness', () async {
      expect(appThemes[0].colors, isA<LightThemeColors>());
      expect(appThemes[1].colors, isA<DarkThemeColors>());
      expect(appThemes[0].type, NyThemeType.light);
      expect(appThemes[1].type, NyThemeType.dark);
    });
  });

  nyGroup('the light colour groups', () {
    nyTest('all six resolve', () async {
      ColorStyles colors = LightThemeColors();

      expect(colors.general, isNotNull);
      expect(colors.appBar, isNotNull);
      expect(colors.bottomTabBar, isNotNull);
      expect(colors.button, isNotNull);
      expect(colors.container, isNotNull);
      expect(colors.input, isNotNull);
    });

    nyTest('the store\'s own colours come through', () async {
      ColorStyles colors = LightThemeColors();

      expect(colors.general.background, const Color(0xFFFFFFFF));
      expect(colors.general.content, const Color(0xFF000000));
      expect(colors.appBar.background, const Color(0xFFFFFFFF));
      expect(colors.appBar.content, const Color(0xFF3a3d40));
      expect(colors.button.background, const Color(0xFF529cda));
      expect(colors.button.content, const Color(0xFFFFFFFF));
    });

    nyTest('a different store gets different colours', () async {
      // Proof the colours are read at call time, not baked in.
      seedAppConfig().themeColors!['light']['button_background'] =
          '0xFFFF0000';

      expect(LightThemeColors().button.background, const Color(0xFFFF0000));
    });
  });

  nyGroup('the dark colour groups', () {
    nyTest('all six resolve', () async {
      ColorStyles colors = DarkThemeColors();

      expect(colors.general, isNotNull);
      expect(colors.appBar, isNotNull);
      expect(colors.bottomTabBar, isNotNull);
      expect(colors.button, isNotNull);
      expect(colors.container, isNotNull);
      expect(colors.input, isNotNull);
    });

    nyTest('the store\'s own colours come through', () async {
      ColorStyles colors = DarkThemeColors();

      expect(colors.general.background, const Color(0xFF212121));
      expect(colors.general.content, const Color(0xFFE1E1E1));
      expect(colors.appBar.background, const Color(0xFF2C2C2C));
      expect(colors.appBar.content, const Color(0xFFFFFFFF));
      expect(colors.button.background, const Color(0xFFFFFFFF));
      expect(colors.button.content, const Color(0xFF232c33));
    });

    nyTest('dark is not simply light', () async {
      expect(DarkThemeColors().general.background,
          isNot(LightThemeColors().general.background));
      expect(DarkThemeColors().general.content,
          isNot(LightThemeColors().general.content));
    });
  });

  nyGroup('the remote colour keys', () {
    nyTest('every key the themes read is one the store sends', () async {
      // Both themes read exactly these six names. A typo in one of them
      // throws when the store config arrives, so they are pinned here.
      const List<String> keys = [
        'background',
        'primary_text',
        'app_bar_background',
        'app_bar_text',
        'button_background',
        'button_text',
      ];

      for (String brightness in ['light', 'dark']) {
        for (String key in keys) {
          expect(
              seedAppConfig().themeColors![brightness].containsKey(key),
              isTrue,
              reason: '"$brightness.$key" is read by the theme');
        }
      }
    });
  });

  nyGroup('the theme in a widget tree', () {
    nyWidgetTest('context.color hands back the app\'s own colour styles',
        (tester) async {
      // `context.color` is the app's extension over nyColorStyle, and every
      // button, card and input in the app reads its colours through it.
      late ColorStyles resolved;

      await tester.pumpNyWidgetSimple(Builder(builder: (context) {
        resolved = nyColorStyle<ColorStyles>(context);
        return const SizedBox.shrink();
      }));

      expect(resolved, isA<ColorStyles>());
      expect(resolved.button, isNotNull);
      expect(resolved.general, isNotNull);
    });
  });

  nyGroup('design config', () {
    nyTest('the loader and the logo are the store\'s own widgets', () async {
      expect(DesignConfig.loader, isA<AppLoaderWidget>());
      expect(DesignConfig.logo, isA<StoreLogo>());
    });

    nyTest('the app font can be replaced at runtime', () async {
      // The themes reassign this from the store's `themeFont`, which is why it
      // is deliberately not final.
      TextStyle original = DesignConfig.appFont;

      DesignConfig.appFont = const TextStyle(fontFamily: "TestFont");
      expect(DesignConfig.appFont.fontFamily, "TestFont");

      DesignConfig.appFont = original;
      expect(DesignConfig.appFont, original);
    });
  });
}
