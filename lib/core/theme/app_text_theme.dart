import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'hybrid_tokens.dart';

/// Central geometry presets retained from the adopted production composition.
/// Widgets choose a preset; they never specify numeric text geometry.
enum AppTextGeometry {
  compact,
  badge,
  standard,
  supporting,
  reading,
  emptyState,
  launchFailure,
  spacedLabel,
  fitValue,
  fitMeasure,
  fitVerdict,
  fitExplanation,
  calendarCell,
  calendarCaption,
  explanatory,
  tableValue,
  timelineDate,
  summaryTitle,
  compactHeading,
  weatherDescription,
  answer,
  contextCaption,
  formLabel,
  answerNeutralTracking,
  chartLabel,
  calendarHeading,
  calendarInstruction,
  moonTotal,
  resultNotes,
  tightTracking,
  recoveryBody,
  chartCaption,
  candidateTitle,
  dialogTitle,
}

/// Typed typography roles and inherited-style geometry installed in ThemeData.
/// Base definitions stay in AppTypography; this extension is the runtime reader.
@immutable
class AppTextTheme extends ThemeExtension<AppTextTheme> {
  const AppTextTheme._(this._roles, this._geometry);
  final Map<String, TextStyle> _roles;
  final Map<AppTextGeometry, TextStyle> _geometry;

  static AppTextTheme of(BuildContext context) =>
      Theme.of(context).extension<AppTextTheme>() ?? standard;

  static final standard = AppTextTheme._(
    {
      "support": AppTypography.support,
      "nightHeading": AppTypography.nightHeading,
      "answerHeading": AppTypography.answerHeading,
      "screenTitle": AppTypography.screenTitle,
      "sectionHeading": AppTypography.sectionHeading,
      "sectionSubject": AppTypography.sectionSubject,
      "itemTitle": AppTypography.itemTitle,
      "rowTitle": AppTypography.rowTitle,
      "value": AppTypography.value,
      "body": AppTypography.body,
      "caption": AppTypography.caption,
      "dense": AppTypography.dense,
      "navigationLabel": AppTypography.navigationLabel,
      "homeHeading": AppTypography.homeHeading,
      "homePlanHeading": AppTypography.homePlanHeading,
      "homeTarget": AppTypography.homeTarget,
      "homeWordmark": AppTypography.homeWordmark,
      "homeWelcome": AppTypography.homeWelcome,
      "inherited": const TextStyle(),
    },
    {
      AppTextGeometry.compact: TextStyle(height: 1.4),
      AppTextGeometry.badge: TextStyle(height: 1.4, letterSpacing: 0),
      AppTextGeometry.standard: TextStyle(height: 1.5),
      AppTextGeometry.supporting: TextStyle(height: 1.55),
      AppTextGeometry.reading: TextStyle(height: 1.6),
      AppTextGeometry.emptyState: TextStyle(height: 22.1 / 13),
      AppTextGeometry.launchFailure: TextStyle(fontSize: 16, height: 1.4),
      AppTextGeometry.spacedLabel: TextStyle(letterSpacing: 0.5),
      AppTextGeometry.fitValue: TextStyle(fontSize: 15, height: 19 / 15),
      AppTextGeometry.fitMeasure: TextStyle(fontSize: 13, height: 17 / 13),
      AppTextGeometry.fitVerdict: TextStyle(fontSize: 13, height: 1.5),
      AppTextGeometry.fitExplanation: TextStyle(fontSize: 14, height: 1.55),
      AppTextGeometry.calendarCell: TextStyle(fontSize: 12, height: 1.5),
      AppTextGeometry.calendarCaption: TextStyle(
        fontSize: HybridTokens.calendarCaptionSize,
      ),
      AppTextGeometry.explanatory: TextStyle(height: 1.65),
      AppTextGeometry.tableValue: TextStyle(height: 1.45),
      AppTextGeometry.timelineDate: TextStyle(height: 17 / 13),
      AppTextGeometry.summaryTitle: TextStyle(fontSize: 18),
      AppTextGeometry.compactHeading: TextStyle(
        height: 1.4,
        letterSpacing: -0.33,
      ),
      AppTextGeometry.weatherDescription: TextStyle(height: 1.7),
      AppTextGeometry.answer: TextStyle(height: 1.3),
      AppTextGeometry.contextCaption: TextStyle(fontSize: 13),
      AppTextGeometry.formLabel: TextStyle(fontSize: 14),
      AppTextGeometry.answerNeutralTracking: TextStyle(
        height: 1.3,
        letterSpacing: 0,
      ),
      AppTextGeometry.chartLabel: TextStyle(
        fontFamily: HybridTokens.fontFamily,
        fontSize: HybridTokens.chartLabelSize,
      ),
      AppTextGeometry.calendarHeading: TextStyle(
        height: 1.35,
        letterSpacing: -0.33,
      ),
      AppTextGeometry.calendarInstruction: TextStyle(height: 24 / 13),
      AppTextGeometry.moonTotal: TextStyle(fontSize: 24, height: 1.3),
      AppTextGeometry.resultNotes: TextStyle(fontSize: 16, height: 1.5),
      AppTextGeometry.tightTracking: TextStyle(letterSpacing: -0.25),
      AppTextGeometry.recoveryBody: TextStyle(fontSize: 16),
      AppTextGeometry.chartCaption: TextStyle(height: 16 / 12),
      AppTextGeometry.candidateTitle: TextStyle(fontSize: 23, height: 1.3),
      AppTextGeometry.dialogTitle: TextStyle(height: 21 / 16),
    },
  );

  TextStyle get support => _roles["support"]!;
  TextStyle get nightHeading => _roles["nightHeading"]!;
  TextStyle get answerHeading => _roles["answerHeading"]!;
  TextStyle get screenTitle => _roles["screenTitle"]!;
  TextStyle get sectionHeading => _roles["sectionHeading"]!;
  TextStyle get sectionSubject => _roles["sectionSubject"]!;
  TextStyle get itemTitle => _roles["itemTitle"]!;
  TextStyle get rowTitle => _roles["rowTitle"]!;
  TextStyle get value => _roles["value"]!;
  TextStyle get body => _roles["body"]!;
  TextStyle get caption => _roles["caption"]!;
  TextStyle get dense => _roles["dense"]!;
  TextStyle get navigationLabel => _roles["navigationLabel"]!;
  TextStyle get homeHeading => _roles["homeHeading"]!;
  TextStyle get homePlanHeading => _roles["homePlanHeading"]!;
  TextStyle get homeTarget => _roles["homeTarget"]!;
  TextStyle get homeWordmark => _roles["homeWordmark"]!;
  TextStyle get homeWelcome => _roles["homeWelcome"]!;
  TextStyle get inherited => _roles["inherited"]!;

  /// Retains the caller's inherited family/color/weight and replaces only the
  /// centrally declared geometry. A null Material role stays inherited.
  TextStyle resolve(TextStyle? base, AppTextGeometry geometry) =>
      (base ?? inherited).merge(_geometry[geometry]);

  @override
  AppTextTheme copyWith({
    TextStyle? support,
    TextStyle? nightHeading,
    TextStyle? answerHeading,
    TextStyle? screenTitle,
    TextStyle? sectionHeading,
    TextStyle? sectionSubject,
    TextStyle? itemTitle,
    TextStyle? rowTitle,
    TextStyle? value,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? dense,
    TextStyle? navigationLabel,
    TextStyle? homeHeading,
    TextStyle? homePlanHeading,
    TextStyle? homeTarget,
    TextStyle? homeWordmark,
    TextStyle? homeWelcome,
    TextStyle? inherited,
    Map<AppTextGeometry, TextStyle>? geometry,
  }) => AppTextTheme._(
    {
      'support': support ?? this.support,
      'nightHeading': nightHeading ?? this.nightHeading,
      'answerHeading': answerHeading ?? this.answerHeading,
      'screenTitle': screenTitle ?? this.screenTitle,
      'sectionHeading': sectionHeading ?? this.sectionHeading,
      'sectionSubject': sectionSubject ?? this.sectionSubject,
      'itemTitle': itemTitle ?? this.itemTitle,
      'rowTitle': rowTitle ?? this.rowTitle,
      'value': value ?? this.value,
      'body': body ?? this.body,
      'caption': caption ?? this.caption,
      'dense': dense ?? this.dense,
      'navigationLabel': navigationLabel ?? this.navigationLabel,
      'homeHeading': homeHeading ?? this.homeHeading,
      'homePlanHeading': homePlanHeading ?? this.homePlanHeading,
      'homeTarget': homeTarget ?? this.homeTarget,
      'homeWordmark': homeWordmark ?? this.homeWordmark,
      'homeWelcome': homeWelcome ?? this.homeWelcome,
      'inherited': inherited ?? this.inherited,
    },
    {..._geometry, ...?geometry},
  );

  @override
  AppTextTheme lerp(covariant AppTextTheme? other, double t) {
    if (other == null) return this;
    return AppTextTheme._(
      {
        for (final key in _roles.keys)
          key: TextStyle.lerp(_roles[key], other._roles[key], t)!,
      },
      {
        for (final key in _geometry.keys)
          key: TextStyle.lerp(_geometry[key], other._geometry[key], t)!,
      },
    );
  }
}
