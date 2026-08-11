import 'package:flutter/material.dart';

abstract class AppColors {
  static const transparent = Colors.transparent;
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const primaryGreen = MaterialColor(0xFF369373, {
    50: Color(0xFFF0F9F5),
    100: Color(0xFFDAF1E5),
    200: Color(0xFFB8E2CE),
    300: Color(0xFF89CCB0),
    400: Color(0xFF58AF8E),
    500: Color(0xFF369373),
    600: Color(0xFF26755C),
    700: Color(0xFF216752),
    800: Color(0xFF1A4B3C),
    900: Color(0xFF163E32),
    1000: Color(0xFF0B231D),
  });
  static const primaryBeige = MaterialColor(0xFF6F695D, {
    50: Color(0xFFF7F5F3),
    100: Color(0xFFEFEDEB),
    200: Color(0xFFE3E1DD),
    300: Color(0xFFD8D5CF),
    400: Color(0xFFABA59B),
    500: Color(0xFF6F695D),
    600: Color(0xFF5A574B),
    700: Color(0xFF474439),
    800: Color(0xFF2B2622),
    900: Color(0xFF1E1B15),
    1000: Color(0xFF0D0B08),
  });
  static const systemRed = MaterialColor(0xFFDA5959, {
    50: Color(0xFFFDF3F3),
    100: Color(0xFFFBE5E5),
    200: Color(0xFFF8D0D0),
    300: Color(0xFFF1B0B0),
    400: Color(0xFFE88181),
    500: Color(0xFFDA5959),
    600: Color(0xFFC63C3C),
    700: Color(0xFFA62F2F),
    800: Color(0xFF8A2A2A),
    900: Color(0xFF732929),
    1000: Color(0xFF3E1111),
  });
  static const systemGrey = MaterialColor(0xFF727272, {
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF5F5F5),
    200: Color(0xFFDEDEDE),
    300: Color(0xFFD3D3D3),
    400: Color(0xFFA3A3A3),
    500: Color(0xFF727272),
    600: Color(0xFF535353),
    700: Color(0xFF404040),
    800: Color(0xFF272727),
    900: Color(0xFF1A1A1A),
    1000: Color(0xFF0B0B0B),
  });

  static const supportingBlueLight = Color(0xFFDDEBFC);
  static const supportingBlue = Color(0xFF2D6CDF);
  static const supportingVioletLight = Color(0xFFE5E4FB);
  static const supportingViolet100 = Color(0xFFF3EEF9);
  static const supportingViolet = Color(0xFF7E5BD0);
  static const supportingViolet950 = Color(0xFF3B1D4E);
  static const supportingYellowLight = Color(0xFFF6F2CB);
  static const supportingYellow = Color(0xFFAD741F);
  static const supportingOrangeLight = Color(0xFFF7E9DD);
  static const supportingOrange = Color(0xFFC75B39);
  static const supportingPinkLight = Color(0xFFFBE8F5);
  static const supportingPink = Color(0xFFD23086);
  static const burgundy = MaterialColor(0xFFB54D80, {
    600: Color(0xFFB54D80),
    900: Color(0xFF6C2F4B),
  });

  static const gradientDarkGreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A4B3B), Color(0xFF14392E), Color(0xFF0B231C)],
  );
  static const greenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF369373), Color(0xFF216752)],
  );
  static const gradientBeige = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7F5F3), Color(0x4DDFDBD8), Color(0xFFDFDBD8)],
  );

  static const supportingGradientBlue = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [Color(0xFFBAD4EE), Color(0xFF9DB7E9), Color(0xFFB1C0EC)],
  );
  static const supportingGradientPurple = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [Color(0xFFC2BDE5), Color(0xFFA2ADD7), Color(0xFFC6BBDD)],
  );
  static const supportingGradientOrange = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [Color(0xFFEFCEBD), Color(0xFFE6CCA7), Color(0xFFE6DEBD)],
  );
  static const supportingGradientRed = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF7EBDD), Color(0xFFE3B58E), Color(0xFFC15F35)],
  );
  static const supportingGradientBurgundy = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xFFEBC1CD), Color(0xFFE1ADAF)],
  );
}

class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  const AppColorsTheme._({
    required this.transparent,
    required this.primaryGreen50,
    required this.primaryGreen100,
    required this.primaryGreen200,
    required this.primaryGreen300,
    required this.primaryGreen400,
    required this.primaryGreen500,
    required this.primaryGreen600,
    required this.primaryGreen700,
    required this.primaryGreen800,
    required this.primaryGreen900,
    required this.primaryGreen1000,
    required this.primaryBeige50,
    required this.primaryBeige100,
    required this.primaryBeige200,
    required this.primaryBeige300,
    required this.primaryBeige400,
    required this.primaryBeige500,
    required this.primaryBeige600,
    required this.primaryBeige700,
    required this.primaryBeige800,
    required this.primaryBeige900,
    required this.primaryBeige1000,
    required this.systemRed50,
    required this.systemRed100,
    required this.systemRed200,
    required this.systemRed300,
    required this.systemRed400,
    required this.systemRed500,
    required this.systemRed600,
    required this.systemRed700,
    required this.systemRed800,
    required this.systemRed900,
    required this.systemRed1000,
    required this.systemGrey50,
    required this.systemGrey100,
    required this.systemGrey200,
    required this.systemGrey300,
    required this.systemGrey400,
    required this.systemGrey500,
    required this.systemGrey600,
    required this.systemGrey700,
    required this.systemGrey800,
    required this.systemGrey900,
    required this.systemGrey1000,
    required this.black,
    required this.white,
    required this.white92,
    required this.white80,
    required this.white48,
    required this.white40,
    required this.white24,
    required this.white16,
    required this.white12,
    required this.white6,
    required this.supportingBlueLight,
    required this.supportingBlue,
    required this.supportingVioletLight,
    required this.supportingViolet100,
    required this.supportingViolet,
    required this.supportingViolet950,
    required this.supportingYellowLight,
    required this.supportingYellow,
    required this.supportingOrangeLight,
    required this.supportingOrange,
    required this.supportingPinkLight,
    required this.supportingPink,
    required this.burgundy600,
    required this.burgundy900,
    required this.gradientDarkGreen,
    required this.greenGradient,
    required this.gradientBeige,
    required this.supportingGradientBlue,
    required this.supportingGradientPurple,
    required this.supportingGradientOrange,
    required this.supportingGradientRed,
    required this.supportingGradientBurgundy,
  });

  factory AppColorsTheme.light() => AppColorsTheme._(
    transparent: AppColors.transparent,
    primaryGreen50: AppColors.primaryGreen.shade50,
    primaryGreen100: AppColors.primaryGreen.shade100,
    primaryGreen200: AppColors.primaryGreen.shade200,
    primaryGreen300: AppColors.primaryGreen.shade300,
    primaryGreen400: AppColors.primaryGreen.shade400,
    primaryGreen500: AppColors.primaryGreen.shade500,
    primaryGreen600: AppColors.primaryGreen.shade600,
    primaryGreen700: AppColors.primaryGreen.shade700,
    primaryGreen800: AppColors.primaryGreen.shade800,
    primaryGreen900: AppColors.primaryGreen.shade900,
    primaryGreen1000: AppColors.primaryGreen[1000]!,
    primaryBeige50: AppColors.primaryBeige.shade50,
    primaryBeige100: AppColors.primaryBeige.shade100,
    primaryBeige200: AppColors.primaryBeige.shade200,
    primaryBeige300: AppColors.primaryBeige.shade300,
    primaryBeige400: AppColors.primaryBeige.shade400,
    primaryBeige500: AppColors.primaryBeige.shade500,
    primaryBeige600: AppColors.primaryBeige.shade600,
    primaryBeige700: AppColors.primaryBeige.shade700,
    primaryBeige800: AppColors.primaryBeige.shade800,
    primaryBeige900: AppColors.primaryBeige.shade900,
    primaryBeige1000: AppColors.primaryBeige[1000]!,
    systemRed50: AppColors.systemRed.shade50,
    systemRed100: AppColors.systemRed.shade100,
    systemRed200: AppColors.systemRed.shade200,
    systemRed300: AppColors.systemRed.shade300,
    systemRed400: AppColors.systemRed.shade400,
    systemRed500: AppColors.systemRed.shade500,
    systemRed600: AppColors.systemRed.shade600,
    systemRed700: AppColors.systemRed.shade700,
    systemRed800: AppColors.systemRed.shade800,
    systemRed900: AppColors.systemRed.shade900,
    systemRed1000: AppColors.systemRed[1000]!,
    systemGrey50: AppColors.systemGrey.shade50,
    systemGrey100: AppColors.systemGrey.shade100,
    systemGrey200: AppColors.systemGrey.shade200,
    systemGrey300: AppColors.systemGrey.shade300,
    systemGrey400: AppColors.systemGrey.shade400,
    systemGrey500: AppColors.systemGrey.shade500,
    systemGrey600: AppColors.systemGrey.shade600,
    systemGrey700: AppColors.systemGrey.shade700,
    systemGrey800: AppColors.systemGrey.shade800,
    systemGrey900: AppColors.systemGrey.shade900,
    systemGrey1000: AppColors.systemGrey[1000]!,
    black: AppColors.black,
    white: AppColors.white,
    white92: AppColors.white.withValues(alpha: 0.92),
    white80: AppColors.white.withValues(alpha: 0.8),
    white48: AppColors.white.withValues(alpha: 0.48),
    white40: AppColors.white.withValues(alpha: 0.4),
    white24: AppColors.white.withValues(alpha: 0.24),
    white16: AppColors.white.withValues(alpha: 0.16),
    white12: AppColors.white.withValues(alpha: 0.12),
    white6: AppColors.white.withValues(alpha: 0.06),
    supportingBlueLight: AppColors.supportingBlueLight,
    supportingBlue: AppColors.supportingBlue,
    supportingVioletLight: AppColors.supportingVioletLight,
    supportingViolet100: AppColors.supportingViolet100,
    supportingViolet: AppColors.supportingViolet,
    supportingViolet950: AppColors.supportingViolet950,
    supportingYellowLight: AppColors.supportingYellowLight,
    supportingYellow: AppColors.supportingYellow,
    supportingOrangeLight: AppColors.supportingOrangeLight,
    supportingOrange: AppColors.supportingOrange,
    supportingPinkLight: AppColors.supportingPinkLight,
    supportingPink: AppColors.supportingPink,
    burgundy600: AppColors.burgundy.shade600,
    burgundy900: AppColors.burgundy.shade900,
    gradientDarkGreen: AppColors.gradientDarkGreen,
    greenGradient: AppColors.greenGradient,
    gradientBeige: AppColors.gradientBeige,
    supportingGradientBlue: AppColors.supportingGradientBlue,
    supportingGradientPurple: AppColors.supportingGradientPurple,
    supportingGradientOrange: AppColors.supportingGradientOrange,
    supportingGradientRed: AppColors.supportingGradientRed,
    supportingGradientBurgundy: AppColors.supportingGradientBurgundy,
  );

  final Color transparent;
  final Color primaryGreen50;
  final Color primaryGreen100;
  final Color primaryGreen200;
  final Color primaryGreen300;
  final Color primaryGreen400;
  final Color primaryGreen500;
  final Color primaryGreen600;
  final Color primaryGreen700;
  final Color primaryGreen800;
  final Color primaryGreen900;
  final Color primaryGreen1000;
  final Color primaryBeige50;
  final Color primaryBeige100;
  final Color primaryBeige200;
  final Color primaryBeige300;
  final Color primaryBeige400;
  final Color primaryBeige500;
  final Color primaryBeige600;
  final Color primaryBeige700;
  final Color primaryBeige800;
  final Color primaryBeige900;
  final Color primaryBeige1000;
  final Color systemRed50;
  final Color systemRed100;
  final Color systemRed200;
  final Color systemRed300;
  final Color systemRed400;
  final Color systemRed500;
  final Color systemRed600;
  final Color systemRed700;
  final Color systemRed800;
  final Color systemRed900;
  final Color systemRed1000;
  final Color systemGrey50;
  final Color systemGrey100;
  final Color systemGrey200;
  final Color systemGrey300;
  final Color systemGrey400;
  final Color systemGrey500;
  final Color systemGrey600;
  final Color systemGrey700;
  final Color systemGrey800;
  final Color systemGrey900;
  final Color systemGrey1000;
  //black
  final Color black;
  //white with transparency
  final Color white;
  final Color white92;
  final Color white80;
  final Color white48;
  final Color white40;
  final Color white24;
  final Color white16;
  final Color white12;
  final Color white6;
  // supporting colors
  final Color supportingBlueLight;
  final Color supportingBlue;
  final Color supportingVioletLight;
  final Color supportingViolet100;
  final Color supportingViolet;
  final Color supportingViolet950;
  final Color supportingYellowLight;
  final Color supportingYellow;
  final Color supportingOrangeLight;
  final Color supportingOrange;
  final Color supportingPinkLight;
  final Color supportingPink;
  final Color burgundy600;
  final Color burgundy900;
  // gradients
  final LinearGradient gradientDarkGreen;
  final LinearGradient greenGradient;
  final LinearGradient gradientBeige;
  final LinearGradient supportingGradientBlue;
  final LinearGradient supportingGradientPurple;
  final LinearGradient supportingGradientOrange;
  final LinearGradient supportingGradientRed;
  final LinearGradient supportingGradientBurgundy;

  @override
  AppColorsTheme copyWith({
    Color? transparent,
    Color? primaryGreen50,
    Color? primaryGreen100,
    Color? primaryGreen200,
    Color? primaryGreen300,
    Color? primaryGreen400,
    Color? primaryGreen500,
    Color? primaryGreen600,
    Color? primaryGreen700,
    Color? primaryGreen800,
    Color? primaryGreen900,
    Color? primaryGreen1000,
    Color? primaryBeige50,
    Color? primaryBeige100,
    Color? primaryBeige200,
    Color? primaryBeige300,
    Color? primaryBeige400,
    Color? primaryBeige500,
    Color? primaryBeige600,
    Color? primaryBeige700,
    Color? primaryBeige800,
    Color? primaryBeige900,
    Color? primaryBeige1000,
    Color? systemRed50,
    Color? systemRed100,
    Color? systemRed200,
    Color? systemRed300,
    Color? systemRed400,
    Color? systemRed500,
    Color? systemRed600,
    Color? systemRed700,
    Color? systemRed800,
    Color? systemRed900,
    Color? systemRed1000,
    Color? systemGrey50,
    Color? systemGrey100,
    Color? systemGrey200,
    Color? systemGrey300,
    Color? systemGrey400,
    Color? systemGrey500,
    Color? systemGrey600,
    Color? systemGrey700,
    Color? systemGrey800,
    Color? systemGrey900,
    Color? systemGrey1000,
    Color? black,
    Color? white,
    Color? white92,
    Color? white80,
    Color? white48,
    Color? white40,
    Color? white24,
    Color? white16,
    Color? white12,
    Color? white6,
    Color? supportingBlueLight,
    Color? supportingBlue,
    Color? supportingVioletLight,
    Color? supportingViolet100,
    Color? supportingViolet,
    Color? supportingViolet950,
    Color? supportingYellowLight,
    Color? supportingYellow,
    Color? supportingOrangeLight,
    Color? supportingOrange,
    Color? supportingPinkLight,
    Color? supportingPink,
    Color? burgundy600,
    Color? burgundy900,
    LinearGradient? gradientDarkGreen,
    LinearGradient? greenGradient,
    LinearGradient? gradientBeige,
    LinearGradient? supportingGradientBlue,
    LinearGradient? supportingGradientPurple,
    LinearGradient? supportingGradientOrange,
    LinearGradient? supportingGradientRed,
    LinearGradient? supportingGradientBurgundy,
  }) => AppColorsTheme._(
    transparent: transparent ?? this.transparent,
    primaryGreen50: primaryGreen50 ?? this.primaryGreen50,
    primaryGreen100: primaryGreen100 ?? this.primaryGreen100,
    primaryGreen200: primaryGreen200 ?? this.primaryGreen200,
    primaryGreen300: primaryGreen300 ?? this.primaryGreen300,
    primaryGreen400: primaryGreen400 ?? this.primaryGreen400,
    primaryGreen500: primaryGreen500 ?? this.primaryGreen500,
    primaryGreen600: primaryGreen600 ?? this.primaryGreen600,
    primaryGreen700: primaryGreen700 ?? this.primaryGreen700,
    primaryGreen800: primaryGreen800 ?? this.primaryGreen800,
    primaryGreen900: primaryGreen900 ?? this.primaryGreen900,
    primaryGreen1000: primaryGreen1000 ?? this.primaryGreen1000,
    primaryBeige50: primaryBeige50 ?? this.primaryBeige50,
    primaryBeige100: primaryBeige100 ?? this.primaryBeige100,
    primaryBeige200: primaryBeige200 ?? this.primaryBeige200,
    primaryBeige300: primaryBeige300 ?? this.primaryBeige300,
    primaryBeige400: primaryBeige400 ?? this.primaryBeige400,
    primaryBeige500: primaryBeige500 ?? this.primaryBeige500,
    primaryBeige600: primaryBeige600 ?? this.primaryBeige600,
    primaryBeige700: primaryBeige700 ?? this.primaryBeige700,
    primaryBeige800: primaryBeige800 ?? this.primaryBeige800,
    primaryBeige900: primaryBeige900 ?? this.primaryBeige900,
    primaryBeige1000: primaryBeige1000 ?? this.primaryBeige1000,
    systemRed50: systemRed50 ?? this.systemRed50,
    systemRed100: systemRed100 ?? this.systemRed100,
    systemRed200: systemRed200 ?? this.systemRed200,
    systemRed300: systemRed300 ?? this.systemRed300,
    systemRed400: systemRed400 ?? this.systemRed400,
    systemRed500: systemRed500 ?? this.systemRed500,
    systemRed600: systemRed600 ?? this.systemRed600,
    systemRed700: systemRed700 ?? this.systemRed700,
    systemRed800: systemRed800 ?? this.systemRed800,
    systemRed900: systemRed900 ?? this.systemRed900,
    systemRed1000: systemRed1000 ?? this.systemRed1000,
    systemGrey50: systemGrey50 ?? this.systemGrey50,
    systemGrey100: systemGrey100 ?? this.systemGrey100,
    systemGrey200: systemGrey200 ?? this.systemGrey200,
    systemGrey300: systemGrey300 ?? this.systemGrey300,
    systemGrey400: systemGrey400 ?? this.systemGrey400,
    systemGrey500: systemGrey500 ?? this.systemGrey500,
    systemGrey600: systemGrey600 ?? this.systemGrey600,
    systemGrey700: systemGrey700 ?? this.systemGrey700,
    systemGrey800: systemGrey800 ?? this.systemGrey800,
    systemGrey900: systemGrey900 ?? this.systemGrey900,
    systemGrey1000: systemGrey1000 ?? this.systemGrey1000,
    black: black ?? this.black,
    white: white ?? this.white,
    white92: white92 ?? this.white92,
    white80: white80 ?? this.white80,
    white48: white48 ?? this.white48,
    white40: white40 ?? this.white40,
    white24: white24 ?? this.white24,
    white16: white16 ?? this.white16,
    white12: white12 ?? this.white12,
    white6: white6 ?? this.white6,
    supportingBlueLight: supportingBlueLight ?? this.supportingBlueLight,
    supportingBlue: supportingBlue ?? this.supportingBlue,
    supportingVioletLight: supportingVioletLight ?? this.supportingVioletLight,
    supportingViolet100: supportingViolet100 ?? this.supportingViolet100,
    supportingViolet: supportingViolet ?? this.supportingViolet,
    supportingViolet950: supportingViolet950 ?? this.supportingViolet950,
    supportingYellowLight: supportingYellowLight ?? this.supportingYellowLight,
    supportingYellow: supportingYellow ?? this.supportingYellow,
    supportingOrangeLight: supportingOrangeLight ?? this.supportingOrangeLight,
    supportingOrange: supportingOrange ?? this.supportingOrange,
    supportingPinkLight: supportingPinkLight ?? this.supportingPinkLight,
    supportingPink: supportingPink ?? this.supportingPink,
    burgundy600: burgundy600 ?? this.burgundy600,
    burgundy900: burgundy900 ?? this.burgundy900,
    gradientDarkGreen: gradientDarkGreen ?? this.gradientDarkGreen,
    greenGradient: greenGradient ?? this.greenGradient,
    gradientBeige: gradientBeige ?? this.gradientBeige,
    supportingGradientBlue:
        supportingGradientBlue ?? this.supportingGradientBlue,
    supportingGradientPurple:
        supportingGradientPurple ?? this.supportingGradientPurple,
    supportingGradientOrange:
        supportingGradientOrange ?? this.supportingGradientOrange,
    supportingGradientRed: supportingGradientRed ?? this.supportingGradientRed,
    supportingGradientBurgundy:
        supportingGradientBurgundy ?? this.supportingGradientBurgundy,
  );

  @override
  // ignore: prefer_expression_function_bodies
  AppColorsTheme lerp(
    covariant ThemeExtension<AppColorsTheme>? other,
    double t,
  ) {
    // No need if we are using one theme
    return this;
  }
}
