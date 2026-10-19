import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/config/feature_scope.dart';
import '../screens/about/about_screen.dart';
import '../screens/details/night_moon_screen.dart';
import '../screens/details/weather_detail_screen.dart';
import '../screens/equipment/equipment_selection_screen.dart';
import '../screens/home/session_planner_route.dart';
import '../screens/library/library_screen.dart';
import '../screens/location/location_picker_screen.dart';
import '../screens/logbook/progress_screen.dart';
import '../screens/logbook/logbook_screen.dart';
import '../screens/logbook/session_detail_screen.dart';
import '../screens/metadata/metadata_import_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/sites/site_editor_screen.dart';
import '../screens/sites/sites_screen.dart';
import '../screens/target/target_selection_screen.dart';
import '../screens/execution/results_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../viewmodels/tonight_viewmodel.dart';
import '../shared/list_mode.dart';
import '../screens/tonight/tonight_candidates_screen.dart';
import '../screens/tonight/tonight_home_screen.dart';
import 'app_shell.dart';

/// The route map of ADR-015 (TASK 12.2; `docs/IA_WIREFRAMES.md` §2).
///
/// Four tabs in a [StatefulShellRoute] — Tonight, Sessions, Library,
/// Settings — each with its own navigator and kept state. Pages that
/// should cover the tabs (the session planner, the pickers it opens, the
/// site editor and the map pickers) live on the root navigator.
class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Paths, so screens never spell them out by hand.
  static const tonight = '/tonight';
  static const candidates = '/tonight/candidates';
  static const sessions = '/sessions';

  /// A saved session's detail (TASK 14.1).
  static String sessionDetail(int id) => '/sessions/$id';

  /// Progress by target (TASK 14.2; in the Logbook since S8.5, RD-07,
  /// ADR-019 §9).
  static const logbookProgress = '/sessions/progress';
  static const library = '/library';
  static const libraryRigs = '/library/rigs';
  static const libraryTargets = '/library/targets';
  static const librarySites = '/library/sites';

  static const settings = '/settings';
  static const about = '/settings/about';

  /// The planning settings over the plan (F12; UX-S R3): Back returns to
  /// the plan and its section.
  static const planSettings = '/plan/settings';

  /// The metadata import (S3.7, ADR-018 §7): above the tabs, opened from
  /// the equipment screen's "Add from a photo".
  static const metadata = '/equipment/import';

  /// The session planner for the current session (`/session/current`) or
  /// a stored session id.
  static String session([Object id = 'current']) => '/session/$id';

  /// "How did it go?" for session [id]: its result (S8.2; the route of
  /// TASK 13.4's reconciliation). The live tracker's route is gone (S8.4).
  static String results(int id) => '/session/$id/results';
  static const selectTarget = '/select/target';
  static const selectRig = '/select/rig';

  /// [selectRig] from the plan's missing-rig action or onboarding (D8 A,
  /// UXA-C2): a rig created there is chosen for the plan.
  static const selectRigForPlan = '$selectRig?for=plan';
  static const selectSite = '/select/site';
  static const siteEdit = '/site/edit';
  static const sitePick = '/site/pick';
  static const position = '/position';

  /// The first-run setup (TASK 12.5).
  static const welcome = '/welcome';

  /// The first route (F16 A1): the setup on a first run, else Tonight.
  static String firstLocation(TonightViewModel tonight) =>
      tonight.startsAtWelcome ? welcome : AppRouter.tonight;

  /// The detail screens (S6.5; ADR-019 §9): the plan's night and its
  /// forecast, above the tabs.
  static const nightMoon = '/night';
  static const weather = '/weather';

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: tonight,
    // F22 A1 (TD-094): after the system kills the app in the background,
    // the open route comes back (Flutter state restoration of the router's
    // location; the tabs' own stacks are not restored separately). An
    // `extra` cannot be restored ([RestoredArgsCodec]); a route that needs
    // one goes back to its list instead of opening a different form (A2).
    restorationScopeId: 'router',
    extraCodec: const RestoredArgsCodec(),
    redirect: (context, state) =>
        state.uri.path == '/' || state.uri.path.isEmpty ? tonight : null,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: tonight,
                builder: (context, state) => const TonightHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'candidates',
                    builder: (context, state) =>
                        const TonightCandidatesScreen(),
                  ),
                ],
              ),
            ],
          ),
          if (FeatureScope.logbook)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: sessions,
                  builder: (context, state) => const LogbookScreen(),
                  routes: [
                    // S8.5: before ':id', so the literal path wins.
                    GoRoute(
                      path: 'progress',
                      builder: (context, state) => const ProgressScreen(),
                    ),
                    // TASK 14.1: a session's detail, from its snapshots.
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => SessionDetailScreen(
                        sessionId: int.parse(state.pathParameters['id']!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: library,
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  // S9.1 (RD-07, TD-053): the Library manages; a tap opens.
                  GoRoute(
                    path: 'rigs',
                    builder: (context, state) =>
                        const EquipmentSelectionScreen(mode: ListMode.manage),
                  ),
                  GoRoute(
                    path: 'targets',
                    builder: (context, state) =>
                        const TargetSelectionScreen(mode: ListMode.manage),
                  ),
                  GoRoute(
                    path: 'sites',
                    builder: (context, state) =>
                        const SitesScreen(mode: ListMode.manage),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settings,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Above the tabs (root navigator): back returns where they came from.
      GoRoute(
        path: '/session/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            SessionPlannerRoute(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/session/:id/results',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            ResultsScreen(sessionId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: selectTarget,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TargetSelectionScreen(),
      ),
      GoRoute(
        path: selectRig,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => EquipmentSelectionScreen(
          forPlanAction: state.uri.queryParameters['for'] == 'plan',
        ),
      ),
      GoRoute(
        path: selectSite,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SitesScreen(),
      ),
      GoRoute(
        path: siteEdit,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => switch (state.extra) {
          RestoredArgsLost() => const RestoredArgsLostRedirect(librarySites),
          final extra => SiteEditorScreen(
            args: extra as SiteEditorArgs? ?? const SiteEditorArgs(),
          ),
        },
      ),
      // The map as a coordinate picker for the site editor (TASK 7.3).
      GoRoute(
        path: sitePick,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => switch (state.extra) {
          RestoredArgsLost() => const RestoredArgsLostRedirect(librarySites),
          final extra => LocationPickerScreen(
            pickOnly: true,
            initial: extra as LatLng?,
          ),
        },
      ),
      if (FeatureScope.metadataImport)
        GoRoute(
          path: metadata,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => switch (state.extra) {
            RestoredArgsLost() => const RestoredArgsLostRedirect(libraryRigs),
            final extra => MetadataImportScreen(
              args: extra as NewRigArgs? ?? const NewRigArgs(),
            ),
          },
        ),
      GoRoute(
        path: planSettings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(overPlan: true),
      ),
      GoRoute(
        path: welcome,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: nightMoon,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NightMoonScreen(),
      ),
      GoRoute(
        path: weather,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WeatherDetailScreen(),
      ),
      // A transient position: map pick or GPS (TASK 7.1).
      GoRoute(
        path: position,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LocationPickerScreen(),
      ),
    ],
  );
}

/// The router's `extra` codec for state restoration (F22 A2). The app's
/// extras (a site to edit, a map position, a rig class) are objects that
/// are not restored: any one is written as a marker and read back as
/// [RestoredArgsLost], so a restored route never opens with defaults that
/// would add or activate a different site or rig.
class RestoredArgsCodec extends Codec<Object?, Object?> {
  const RestoredArgsCodec();

  static const _lost = 'restoredArgsLost';

  @override
  Converter<Object?, Object?> get encoder => const _Encode();

  @override
  Converter<Object?, Object?> get decoder => const _Decode();
}

/// An `extra` that could not be restored.
class RestoredArgsLost {
  const RestoredArgsLost();
}

/// A restored route whose arguments were lost (F22 A2): it goes to
/// [location], its list, where nothing is chosen for the user. (A restored
/// route stack is not run through redirects, so the route's builder does
/// it.)
class RestoredArgsLostRedirect extends StatefulWidget {
  const RestoredArgsLostRedirect(this.location, {super.key});

  final String location;

  @override
  State<RestoredArgsLostRedirect> createState() =>
      _RestoredArgsLostRedirectState();
}

class _RestoredArgsLostRedirectState extends State<RestoredArgsLostRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) GoRouter.of(context).go(widget.location);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _Encode extends Converter<Object?, Object?> {
  const _Encode();

  @override
  Object? convert(Object? input) =>
      input == null ? null : RestoredArgsCodec._lost;
}

class _Decode extends Converter<Object?, Object?> {
  const _Decode();

  @override
  Object? convert(Object? input) =>
      input == RestoredArgsCodec._lost ? const RestoredArgsLost() : null;
}
