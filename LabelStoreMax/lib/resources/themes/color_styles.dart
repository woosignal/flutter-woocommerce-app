import 'package:nylo_framework/nylo_framework.dart';

/// Interface for your base styles.
/// Add more styles here and then implement in
/// light/light_theme_colors.dart and dark/dark_theme_colors.dart.
///
/// [general], [appBar] and [bottomTabBar] are Nylo's own groups (from
/// [ThemeColor]) - they are what resources/themes/base_theme.dart reads and
/// what `context.color.general.background` resolves to.
/// [button], [container] and [input] are this template's own groups, for the
/// store colours Nylo has no equivalent for.
abstract class ColorStyles extends ThemeColor {
  /// Colors for general use.
  @override
  GeneralColors get general;

  /// Colors for the app bar.
  @override
  AppBarColors get appBar;

  /// Colors for the bottom tab bar.
  @override
  BottomTabBarColors get bottomTabBar;

  /// Colors for the store's buttons.
  ButtonColors get button;

  /// Colors for containers drawn on top of the background.
  ContainerColors get container;

  /// Colors for form inputs.
  InputColors get input;
}

/// Color configuration for the store's buttons.
class ButtonColors {
  /// The primary button background color.
  final Color background;

  /// The primary button content/text color.
  final Color content;

  /// The secondary button background color.
  final Color secondaryBackground;

  /// The secondary button content/text color.
  final Color secondaryContent;

  /// Creates a [ButtonColors] configuration.
  const ButtonColors({
    required this.background,
    required this.content,
    required this.secondaryBackground,
    required this.secondaryContent,
  });
}

/// Color configuration for containers drawn on top of the background,
/// e.g. cards, bottom sheets and list tiles.
class ContainerColors {
  /// The container background color.
  final Color background;

  /// Creates a [ContainerColors] configuration.
  const ContainerColors({required this.background});
}

/// Color configuration for form inputs.
class InputColors {
  /// The content/text color inside an input.
  final Color content;

  /// Creates an [InputColors] configuration.
  const InputColors({required this.content});
}
