import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/camera_class.dart';
import '../../../domain/models/session_result.dart';
import '../../../domain/services/stacking_gain_curve.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/entry_text.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/hybrid_icon.dart';
import '../../widgets/capture_plan/stacking_gain_graph.dart';
import '../settings/settings_parts.dart';
import '../../../domain/models/session.dart';
import '../../../domain/models/session_snapshot.dart';
import '../../../domain/repositories/session_repository.dart';
import '../../../domain/services/result_action.dart';
import '../../../domain/services/saved_night_end.dart';
import '../../../domain/services/session_reconciliation.dart';
import '../../shared/app_words.dart';
import '../../shared/context_line.dart';
import '../../shared/entry_share_text.dart';
import '../../shared/display_units_of.dart';
import '../../shared/plan_state.dart';
import '../../navigation/app_router.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/plan_lifecycle_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../shared/failure_feedback.dart';
import '../execution/results_screen.dart';
import 'progress_screen.dart';
import 'logbook_screen.dart';
import '../../shared/unsaved_plan_prompt.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../core/utils/astro_math.dart';
import '../../shared/capture_settings_text.dart';
import '../../viewmodels/astrobin_export_viewmodel.dart';
import 'astrobin_export.dart';

/// A Logbook entry (TASK 14.1; S8.7, P8.7, ADR-019 §8, §10): read-only
/// history from its snapshots — never today's site, target or rig (ADR-014
/// §4). In order: the identity (the name, or target · night) and its state;
/// the result; the night, site, target and rig; planned against actual
/// (CALC-37) per block; the notes; the conditions; then the actions its
/// state allows (I-6), Share (D8-4: no notes, no coordinates) and Export as
/// file (the portable manifest v2). An old log shows its stored text only.
/// It never opens a live tracker.
class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late Future<SessionDetail?> _detail;

  @override
  void initState() {
    super.initState();
    _detail = context.read<SessionsViewModel>().detail(widget.sessionId);
  }

  /// Re-reads the entry after an action (a result, a name).
  void _load() {
    final sessions = context.read<SessionsViewModel>();
    setState(() {
      _detail = sessions.detail(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _detail,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: hybridAppBar(context, title: const Text(AppWords.logbook)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.error case final error?) {
          return Scaffold(
            appBar: hybridAppBar(context, title: const Text(AppWords.logbook)),
            body: LoadFailureView(
              action: 'load the entry',
              error: error,
              onRetry: _load,
            ),
          );
        }
        if (data == null) {
          return Scaffold(
            appBar: hybridAppBar(context, title: const Text(AppWords.logbook)),
            body: Center(
              child: snapshot.connectionState == ConnectionState.done
                  ? const Text('This entry no longer exists.')
                  : const CircularProgressIndicator(),
            ),
          );
        }
        final s = data.session;
        final snap = s.executionStartSnapshot ?? s.planSnapshot;
        final site = snap?.siteName ?? s.record.locationName;
        final night = s.eveningDate;
        final zoneRule = s.legacy || night == null
            ? null
            : ContextLine.zoneRule(
                snap?.night?.startUtc ?? s.record.sessionDate,
                zoneId: s.timeZoneId ?? snap?.timeZoneId,
              );
        final p = AppPalette.of(context);
        // logbook.js `detailView`: the result first, then planned and
        // recorded, the plan as saved, the notes, this target so far,
        // export and delete. The native extras (name, copy, open, share,
        // conditions, budget and weather as saved) keep their places in it.
        return Scaffold(
          appBar: hybridAppBar(
            context,
            title: Text(entryTitle(s)),
            actions: const [FieldModeButton()],
          ),
          body: ListView(
            key: const Key('detail.scroll'),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.itemGap,
              AppSpacing.gutter,
              AppSpacing.xl,
            ),
            children: [
              DocumentSection(
                key: const Key('detail.outcomeGroup'),
                children: [
                  if ([if (s.name != null) targetAndNight(s), ?site].join(' · ')
                      case final line when line.isNotEmpty)
                    Text(
                      line,
                      key: const Key('detail.context'),
                      style: AppTypography.body.copyWith(
                        height: 1.5,
                        color: p.textSecondary,
                      ),
                    ),
                  if (zoneRule != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        zoneRule,
                        key: const Key('detail.zone'),
                        style: AppTypography.dense.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                    ),
                  _Result(
                    session: s,
                    reconciliation: data.reconciliation,
                    onBack: _load,
                  ),
                ],
              ),
              _PlanVsActual(session: s, reconciliation: data.reconciliation),
              if (!s.legacy)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: DocumentSection(
                    key: const Key('detail.snapshotGroup'),
                    children: [_SnapshotSections(session: s)],
                  ),
                ),
              _Notes(session: s),
              _Block(
                title: 'This target so far',
                child: switch (data.progress) {
                  final progress? => TargetProgressCard(
                    progress: progress,
                    embedded: true,
                  ),
                  null => const SettingsCopy(
                    'No recorded results for this target yet.',
                  ),
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DocumentSection(
                key: const Key('detail.actionsGroup'),
                children: [
                  _Export(session: s, reconciliation: data.reconciliation),
                  if (!s.legacy) _NameTile(session: s, onChanged: _load),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: OutlinedButton(
                      // S8.5 (S5.8, RD-09 S1): the entry's visible Delete.
                      key: const Key('detail.delete'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          HybridTokens.minTarget,
                        ),
                        foregroundColor:
                            (Theme.of(context).extension<HybridTokens>() ??
                                    HybridTokens.light)
                                .errorText,
                      ),
                      onPressed: () async {
                        if (await deleteEntry(context, s) && context.mounted) {
                          context.pop();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: AppSpacing.sm,
                        children: [
                          HybridIcon(
                            HybridIcons.trash,
                            size: MediaQuery.textScalerOf(context).scale(20),
                            strokeWidth: 1.7,
                            color:
                                (Theme.of(context).extension<HybridTokens>() ??
                                        HybridTokens.light)
                                    .errorText,
                          ),
                          const Flexible(child: Text('Delete entry')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A flat group of related record content, separated by the document rhythm.
class _Block extends StatelessWidget {
  const _Block({
    super.key,
    required this.title,
    required this.child,
    this.copy,
  });

  final String title;
  final String? copy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: DocumentSection(
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: AppTypography.sectionHeading.copyWith(
                color: p.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.cellY),
          if (copy case final c?) SettingsCopy(c),
          child,
        ],
      ),
    );
  }
}

/// A disclosure that stays open for this visit (`details.logbook-…`).
class _Disclosure extends StatefulWidget {
  const _Disclosure({
    super.key,
    required this.id,
    required this.title,
    required this.child,
    this.summary,
    this.top = AppSpacing.md,
    this.topRule = true,
  });

  final double top;
  final bool topRule;
  final String id;
  final String title;
  final String? summary;
  final Widget child;

  @override
  State<_Disclosure> createState() => _DisclosureState();
}

class _DisclosureState extends State<_Disclosure> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: widget.top),
    child: CollapsibleSection(
      sectionKey: widget.id,
      topRule: widget.topRule,
      title: widget.title,
      summary: widget.summary,
      open: _open,
      onToggle: () => setState(() => _open = !_open),
      child: widget.child,
    ),
  );
}

/// Label and value pairs (`.workspace-facts`): the 14 px label at the
/// start, the value at the end; [stacked]: the 13 px label above its value
/// (notes).
class _Facts extends StatelessWidget {
  const _Facts(this.rows, {super.key, this.stacked = false});

  final Map<String, String> rows;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final label = AppTypography.body.copyWith(
      height: 1.5,
      color: p.textPrimary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final MapEntry(:key, :value) in rows.entries)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: MergeSemantics(
              child: stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key,
                          style: AppTypography.caption.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                        Text(value, style: label),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(key, style: label)),
                        const SizedBox(width: AppSpacing.itemGap),
                        Flexible(
                          child: Text(
                            value,
                            textAlign: TextAlign.end,
                            style: label.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
      ],
    );
  }
}

/// The result first (ADR-019 §4; logbook.js `logbook-result`): the state,
/// how it was reported, the integration, when a result can be recorded,
/// then Record or Edit result — before the night starts the action is
/// shown disabled with its reason (F19 A2/A5).
class _Result extends StatelessWidget {
  const _Result({
    required this.session,
    required this.reconciliation,
    required this.onBack,
  });

  final Session session;
  final SessionReconciliation? reconciliation;
  final VoidCallback onBack;

  Future<void> _open(BuildContext context, {bool copy = false}) async {
    final s = session;
    final plan = context.read<SessionPlanViewModel>();
    final lifecycle = context.read<PlanLifecycleViewModel>();
    final night = copy
        ? await pickNight(context, initial: plan.tonightKey)
        : null;
    if (copy && night == null) return;
    if (!context.mounted) return;
    // S6.3 (U1): Save · Discard · Cancel, unless it is the plan already open.
    final leaving = !copy && s.id == plan.activeSessionId
        ? LeavingPlan.keep
        : await askBeforeLeavingPlan(context);
    if (leaving == null || !context.mounted) return;
    final opened = await runWithFeedback(
      context,
      copy ? 'copy the plan' : 'open the plan',
      () => lifecycle.openSession(
        s,
        discard: leaving == LeavingPlan.discard,
        copyTo: night,
      ),
    );
    if (opened && context.mounted) {
      showDone(
        context,
        copy
            ? 'Copied to ${NightTimeFormatter.eveningDate(night!)}'
            : 'Plan opened',
      );
      unawaited(context.push(AppRouter.session()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = session;
    final r = reconciliation;
    final p = AppPalette.of(context);
    final sessions = context.read<SessionsViewModel>();
    final action = sessions.resultAction(s);
    final record = action == ResultAction.record;
    // F19 A2: a result can be recorded from the saved night's start.
    final start = SavedNightEnd.startOf(s);
    final zone = s.timeZoneId ?? s.planSnapshot?.timeZoneId;
    final counted =
        s.status == SessionStatus.completed ||
        s.status == SessionStatus.inProgress;
    final upcoming = s.isSavedPlan && action == ResultAction.none;
    final due = record && s.status != SessionStatus.inProgress && !s.legacy;
    const tall = Size.fromHeight(HybridTokens.minTarget);
    final when = upcoming && start != null
        ? 'Record from '
              '${NightTimeFormatter.eveningDate(CalendarDate.fromDateTimeFields(NightTimeFormatter.wallClock(start, zoneId: zone)))}, '
              '${NightTimeFormatter.clockTime(context, start, zoneId: zone)} · '
              '${zone == null ? 'device zone' : '$zone (${NightTimeFormatter.shortZone(start, zoneId: zone)})'}.'
        : null;
    return Column(
      key: const Key('detail.result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                header: true,
                child: EntryStateBadge(
                  PlanState.of(s),
                  key: const Key('detail.status'),
                  large: true,
                  word: EntryShareText.result(s),
                ),
              ),
              if (due) const EntryStateBadge.due(key: Key('detail.noResult')),
              if (s.legacy)
                const Text(
                  '${AppWords.oldLog} — stored text only',
                  key: Key('detail.legacy'),
                ),
            ],
          ),
        ),
        // The words the badge shows, for tests and screen readers alike.
        Offstage(
          child: Text(
            EntryShareText.result(s),
            key: const Key('detail.resultText'),
          ),
        ),
        const SizedBox(height: AppSpacing.cellY),
        Text(
          counted && r != null
              ? ResultsText.integration(r)
              : ResultsText.plannedOnly(
                  SessionReconciliation.plannedOnly(s.blocks),
                  due: due,
                ),
          key: const Key('detail.summary'),
          style: AppTypography.value.copyWith(
            color: p.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (when != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.cellY),
            child: Text(
              when,
              key: const Key('detail.resultWhen'),
              style: AppTypography.caption.copyWith(
                height: 1.55,
                color: p.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.itemGap),
        if (action != ResultAction.none)
          FilledButton(
            key: Key(record ? 'detail.recordResult' : 'detail.editResults'),
            onPressed: () async {
              await context.push(AppRouter.results(s.id));
              onBack();
            },
            style: FilledButton.styleFrom(minimumSize: tall),
            child: Text(record ? AppWords.recordResult : AppWords.editResult),
          )
        else if (s.isSavedPlan)
          const FilledButton(
            key: Key('detail.recordResultLater'),
            onPressed: null,
            child: Text(AppWords.recordResult),
          ),
        // F19 A2: tonight's saved plan still opens in the planner.
        if (sessions.isUpcoming(s)) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            key: const Key('detail.openInPlanner'),
            onPressed: () => _open(context),
            style: OutlinedButton.styleFrom(minimumSize: tall),
            child: const Text('Open in planner'),
          ),
        ],
        if (!s.legacy) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            key: const Key('detail.copy'),
            onPressed: () => _open(context, copy: true),
            style: OutlinedButton.styleFrom(minimumSize: tall),
            child: const Text(AppWords.copyToAnotherNight),
          ),
        ],
      ],
    );
  }
}

/// The context the session was planned or started in, from its snapshot
/// (logbook.js `logbook-snapshot`): read-only, one tap away.
class _SnapshotSections extends StatelessWidget {
  const _SnapshotSections({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final started = session.executionStartSnapshot;
    final snap = started ?? session.planSnapshot;
    final p = AppPalette.of(context);
    final title = started != null ? 'At the start of imaging' : 'Plan as saved';
    if (snap == null) {
      return _Disclosure(
        top: 0,
        key: const Key('detail.noSnapshot'),
        topRule: false,
        id: 'logbook.snapshot',
        title: title,
        summary: 'Unavailable: not saved or unreadable',
        child: const SettingsCopy(
          'This entry has no readable snapshot of its plan.',
        ),
      );
    }
    final night = snap.night;
    String at(DateTime utc) => night == null
        ? NightTimeFormatter.deviceZoneCaption(utc)
        : NightTimeFormatter.instant(
            context,
            utc,
            windowStartUtc: night.startUtc,
            zoneId: snap.timeZoneId,
          );
    String deg(double? v, [int digits = 0]) =>
        v == null ? 'unknown' : QuantityText.degrees(v, digits: digits);
    String dur(Duration? d) =>
        d == null ? 'unknown' : OpportunityText.duration(d);
    String? known(Object? v, [String unit = '']) =>
        v == null ? null : '$v$unit';
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.itemGap),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: AppTypography.value.copyWith(
            fontWeight: FontWeight.w600,
            color: p.textPrimary,
          ),
        ),
      ),
    );
    final camera = snap.cameraClass;
    return _Disclosure(
      top: 0,
      key: const Key('detail.snapshot'),
      topRule: false,
      id: 'logbook.snapshot',
      title: title,
      summary: 'Read-only night, site, target and rig snapshot',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsCopy(
            'Taken ${at(snap.takenAtUtc)}. Changes to Library records or '
            'this result never replace the saved snapshot.',
            key: const Key('detail.snapshotLabel'),
          ),
          heading('Night'),
          _Facts(key: const Key('detail.night'), {
            if (night != null) ...{
              // The noon-to-noon night key, not an imaging window (UX-18).
              'Night span': '${at(night.startUtc)} – ${at(night.endUtc)}',
              'Times in': NightTimeFormatter.zoneCaption(
                night.startUtc,
                zoneId: snap.timeZoneId,
              ),
            },
            'Darkness limit': deg(snap.darknessLimitDeg),
            'Minimum altitude': deg(snap.minAltitudeDeg),
            'Usable time': dur(snap.usableTime),
            for (final (i, (a, b)) in snap.windows.indexed)
              'Window ${i + 1}': '${at(a)} – ${at(b)}',
          }),
          heading('Site'),
          _Facts(key: const Key('detail.site'), {
            'Name': snap.siteName ?? 'Not a saved site',
            'Position':
                '${deg(snap.siteLatitudeDeg ?? night?.latitude, 3)}, '
                '${deg(snap.siteLongitudeDeg ?? night?.longitude, 3)}',
            'Elevation': switch (snap.siteElevationM) {
              final m? => QuantityText.elevation(m, unitsOf(context)),
              null => 'unknown',
            },
            'Bortle': known(snap.bortleClass) ?? 'unknown',
            'SQM': known(snap.sqm, ' mag/arcsec²') ?? 'unknown',
          }),
          heading('Target'),
          _Facts(key: const Key('detail.target'), {
            'Name': snap.targetName ?? 'none',
            if (snap.target case final t?) ...{
              'RA / Dec (J2000)':
                  '${AstroMath.formatRightAscension(t.rightAscension)}, '
                  '${AstroMath.formatDeclination(t.declination)}',
            },
          }),
          heading('Rig'),
          _Facts(key: const Key('detail.rig'), {
            'Name': snap.rigName ?? 'none',
            'Camera class': camera?.label ?? 'unknown',
            'Sensitivity control': switch (camera?.lightSensitivity) {
              LightSensitivity.iso => 'ISO',
              LightSensitivity.gain => 'Gain',
              _ => 'unknown',
            },
            'Focal length':
                known(snap.rigFocalLengthMm?.round(), ' mm') ?? 'unknown',
            'Focal ratio': snap.rigFocalRatio == null
                ? 'unknown'
                : 'f/${snap.rigFocalRatio!.toStringAsFixed(1)}',
            'Pixel pitch': known(snap.rigPixelPitchUm, ' µm') ?? 'unknown',
          }),
          heading('Budget'),
          _Facts(key: const Key('detail.budget'), {
            AppWords.integration: dur(snap.integration),
            AppWords.timeNeeded: dur(snap.windowLoad),
            AppWords.totalTime: dur(snap.sessionBudget),
          }),
          heading('Weather'),
          _Facts(key: const Key('detail.weather'), _weather(snap, at)),
        ],
      ),
    );
  }

  static Map<String, String> _weather(
    SessionSnapshot snap,
    String Function(DateTime) at,
  ) => switch (snap.weatherState) {
    // F19 A3: the forecast saved with the plan, with its source and its age
    // then — never today's forecast in its place.
    'available' => {
      'Forecast': 'as saved with the plan',
      'Source': snap.weatherSource ?? 'unknown',
      if (snap.weatherFetchedAtUtc case final t?) 'Fetched': at(t),
      'Age when saved': switch (snap.weatherAgeAtSave) {
        'current' => 'current',
        'aging' => 'aging',
        'stale' => 'stale',
        _ => 'unknown',
      },
      'Cloud cover (dark hours)': switch (snap.weatherCloudPct) {
        null => 'no forecast',
        (:final min, :final max) => QuantityText.percentRange(min, max),
      },
      if (snap.weatherHoursWithoutForecast case final n when n > 0)
        'Hours without forecast': '$n',
    },
    'outOfRange' => {'Forecast': 'beyond the 16-day forecast'},
    'unavailable' => {'Forecast': 'unavailable'},
    _ => {'Forecast': 'none recorded'},
  };
}

/// Planned and recorded (logbook.js `logbook-blocks`): each block's plan
/// and count, the integration totals, then the stacking gain per comparable
/// group, relative to the plan.
class _PlanVsActual extends StatelessWidget {
  const _PlanVsActual({required this.session, required this.reconciliation});

  final Session session;
  final SessionReconciliation? reconciliation;

  @override
  Widget build(BuildContext context) {
    final r = reconciliation;
    final s = session;
    final log = s.record;
    final p = AppPalette.of(context);
    if (r == null) {
      // An old log: the stored totals only (ADR-014 §7).
      return _Block(
        key: const Key('detail.planVsActual'),
        title: 'Planned and recorded',
        child: _Facts({
          for (final b in s.blocks)
            EntryText.block(b, null): '${b.frameCount} planned',
          'Planned light frames': '${log.plannedLightFrames}',
          'Actual light frames': log.actualLightFrames?.toString() ?? 'unknown',
          'Rejected frames': log.rejectedFrames?.toString() ?? 'unknown',
        }),
      );
    }
    final camera = (s.executionStartSnapshot ?? s.planSnapshot)?.cameraClass;
    // Counts exist once a result was recorded, or a run was started.
    final counted =
        s.status == SessionStatus.completed ||
        s.status == SessionStatus.inProgress ||
        s.startedAtUtc != null;
    final action = context.read<SessionsViewModel>().resultAction(s);
    final asPlanned = s.resultKind == ResultKind.asPlanned;
    String dur(Duration d) => OpportunityText.duration(d);
    String recorded(BlockReconciliation b) {
      if (!b.isLight) {
        return 'Not counted: the result form records light frames only';
      }
      if (counted) {
        return '${EntryText.plural(b.confirmed, 'frame')} · '
            '${dur(b.actualIntegration)}'
            '${b.rejected > 0 ? ' · ${b.rejected} rejected' : ''}'
            '${asPlanned ? ' (reported as planned)' : ''}';
      }
      if (s.status == SessionStatus.abandoned) return 'None';
      return action == ResultAction.record
          ? 'None recorded yet'
          : 'Not yet: the night has not started';
    }

    final small = AppTypography.caption.copyWith(color: p.textSecondary);
    final value = AppTypography.body.copyWith(
      height: 1.5,
      color: p.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    Widget pair(
      String a,
      String av,
      String b,
      String bv, {
      bool strong = false,
    }) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.itemGap,
      children: [
        for (final (label, text) in [(a, av), (b, bv)])
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(label, style: small),
                  Text(
                    text,
                    style: strong
                        ? value.copyWith(fontWeight: FontWeight.w500)
                        : value,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    final groups = r.lightGroups();
    final rule = BorderSide(color: p.border);
    return _Block(
      key: const Key('detail.planVsActual'),
      title: 'Planned and recorded',
      copy:
          'Light-frame integration and counts. The saved plan stays '
          'unchanged.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, b) in r.blocks.indexed)
            Container(
              key: Key('detail.block.$i'),
              padding: EdgeInsets.only(
                top: i == 0 ? AppSpacing.itemGap : AppSpacing.itemGap,
                bottom: AppSpacing.itemGap,
              ),
              decoration: BoxDecoration(
                border: i == 0 ? null : Border(top: rule),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.xs,
                children: [
                  Text(
                    '${EntryText.block(b.block, camera)}'
                    // F06 A4: the recorded white balance and focus mode.
                    '${CaptureSettingsText.suffix(b.block)}',
                    style: value.copyWith(fontWeight: FontWeight.w600),
                  ),
                  pair(
                    'Planned',
                    '${b.planned} × ${QuantityText.exposure(b.block.exposureTimeSeconds)}'
                        '${b.isLight ? ' · ${dur(b.plannedIntegration)}' : ''}',
                    'Recorded',
                    recorded(b),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
            child: pair(
              'Planned integration',
              dur(r.plannedIntegration),
              'Recorded integration',
              counted ? dur(r.actualIntegration) : 'none recorded',
              strong: true,
            ),
          ),
          if (groups.isNotEmpty)
            _Disclosure(
              key: const Key('detail.gain'),
              id: 'logbook.gain',
              title: 'Stacking gain',
              summary: 'Relative to the plan, per comparable group',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, g) in groups.indexed)
                    StackingGainGraph(
                      key: Key('detail.gainGraph.$i'),
                      curve: StackingGainCurve.of(
                        g.planned,
                        exposureMs: g.exposureMs,
                      ),
                      caption: '${i + 1} · ${EntryText.block(g.first, camera)}',
                      groupLabel: EntryText.block(g.first, camera),
                      recorded: counted ? g.confirmed : null,
                    ),
                  Text(
                    'Ideal √N within comparable light frames: twice the time '
                    'gives 1.41×, not 2×. Not absolute signal-to-noise.',
                    style: small.copyWith(height: 1.55),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The notes, then any conditions recorded with the result.
class _Notes extends StatelessWidget {
  const _Notes({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final log = session.record;
    final notes = {
      if (log.environmentalNotes case final n? when n.isNotEmpty)
        'Conditions and events': n,
      if (log.processingNotes case final n? when n.isNotEmpty)
        'Processing notes': n,
    };
    final conditions = {
      if (log.temperature case final t?)
        'Temperature': QuantityText.temperature(t, unitsOf(context), digits: 1),
      if (log.humidity case final h?) 'Humidity': QuantityText.percent(h),
      if (log.cloudCover case final c?) 'Cloud cover': QuantityText.percent(c),
    };
    return _Block(
      key: const Key('detail.notes'),
      title: 'Notes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (notes.isEmpty && conditions.isEmpty)
            const SettingsCopy('None recorded.'),
          if (notes.isNotEmpty) _Facts(notes, stacked: true),
          if (conditions.isNotEmpty)
            _Facts(key: const Key('detail.conditions'), conditions),
        ],
      ),
    );
  }
}

/// Export this entry (logbook.js `logbook-export`): the text summary to
/// share (no notes, no coordinates; D8-4), the portable file, and the
/// AstroBin CSV.
class _Export extends StatelessWidget {
  const _Export({required this.session, required this.reconciliation});

  final Session session;
  final SessionReconciliation? reconciliation;

  @override
  Widget build(BuildContext context) {
    final s = session;
    final sessions = context.read<SessionsViewModel>();
    const tall = Size.fromHeight(HybridTokens.minTarget);
    Widget icon(HybridIconData i) => HybridIcon(
      i,
      size: MediaQuery.textScalerOf(context).scale(20),
      strokeWidth: 1.7,
    );
    return Padding(
      padding: EdgeInsets.zero,
      child: _Disclosure(
        top: 0,
        key: const Key('detail.exportSection'),
        topRule: false,
        id: 'logbook.export',
        title: 'Export this entry',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            const SettingsCopy(
              'The text summary leaves out notes and site coordinates. The '
              'file includes both; review it before sharing.',
            ),
            OutlinedButton.icon(
              key: const Key('detail.share'),
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  text: EntryShareText.of(
                    s,
                    reconciliation: reconciliation,
                    units: unitsOf(context),
                  ),
                ),
              ),
              icon: icon(HybridIcons.download),
              label: const Text('Text summary'),
              style: OutlinedButton.styleFrom(minimumSize: tall),
            ),
            // TASK 14.3; S8.7: the portable manifest v2 file with the event
            // log, distinct from the summary.
            if (sessions.canExport)
              OutlinedButton.icon(
                key: const Key('detail.export'),
                onPressed: () async {
                  final done = await runWithFeedback(
                    context,
                    'export the entry',
                    () => sessions.exportOne(s.id),
                  );
                  // S9.8 (D9-5): after the share sheet returns.
                  if (done && context.mounted) {
                    showDone(context, 'Export file created');
                  }
                },
                icon: icon(HybridIcons.download),
                label: const Text(AppWords.exportAsFile),
                style: OutlinedButton.styleFrom(minimumSize: tall),
              ),
            // F20: this entry's AstroBin acquisition CSV, after its preview.
            if (context.read<AstroBinExportViewModel?>() != null && !s.legacy)
              OutlinedButton.icon(
                key: const Key('detail.astrobin'),
                onPressed: () => exportForAstroBinFlow(context, id: s.id),
                icon: icon(HybridIcons.download),
                label: const Text(exportForAstroBin),
                style: OutlinedButton.styleFrom(minimumSize: tall),
              ),
          ],
        ),
      ),
    );
  }
}

/// "Name (optional)" (S8.6; 08 §24): never asked at Save plan; set, changed
/// or removed here. Without one the entry is shown as target · night.
class _NameTile extends StatelessWidget {
  const _NameTile({required this.session, required this.onChanged});

  final Session session;
  final VoidCallback onChanged;

  Future<void> _edit(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initial: session.name ?? ''),
    );
    if (name == null || !context.mounted) return;
    final sessions = context.read<SessionsViewModel>();
    final saved = await runWithFeedback(
      context,
      'save the name',
      () => sessions.rename(session.id, name),
    );
    if (!saved) return;
    // S9.8 (D9-5): a rename says so.
    if (context.mounted) {
      showDone(context, name.trim().isEmpty ? 'Name removed' : 'Name saved');
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: MergeSemantics(
        child: Semantics(
          button: true,
          child: InkWell(
            key: const Key('detail.name'),
            onTap: () => _edit(context),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: p.border),
                  bottom: BorderSide(color: p.border),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.itemGap,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            AppWords.nameOptional,
                            style: AppTypography.body.copyWith(
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: p.textPrimary,
                            ),
                          ),
                          Text(
                            session.name ?? 'None · shown as target · night',
                            style: AppTypography.caption.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    HybridIcon(
                      HybridIcons.edit,
                      size: MediaQuery.textScalerOf(context).scale(20),
                      strokeWidth: 1.7,
                      color: p.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The name's editor; it owns its field, which lives as long as the dialog.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _field = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(AppWords.nameOptional),
    content: TextField(
      key: const Key('detail.nameField'),
      controller: _field,
      autofocus: true,
      maxLength: SessionRepository.maxNameLength,
      decoration: const InputDecoration(
        helper: Text('Leave empty to show the target and night.'),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('detail.nameSave'),
        onPressed: () => Navigator.pop(context, _field.text),
        child: const Text('Save'),
      ),
    ],
  );
}
