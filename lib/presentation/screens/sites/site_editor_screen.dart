import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';

import '../../shared/night_time_formatter.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../shared/hybrid_parts.dart';
import '../library/library_parts.dart';
import '../settings/settings_parts.dart';
import '../../shared/app_words.dart';
import '../../shared/geo_controls.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/feature_scope.dart';
import '../../../core/diagnostics/app_log.dart';
import '../../../domain/models/iana_time_context.dart';
import '../../../domain/models/location_profile.dart';
import '../../../domain/services/location_service.dart';
import '../../../domain/services/reverse_geocoder.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/coordinate_input.dart';
import '../../shared/location_feedback.dart';
import '../../shared/site_form_input.dart';
import '../../../core/units/display_units.dart';
import '../../viewmodels/disclosure_viewmodel.dart';
import '../../viewmodels/display_settings_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../shared/app_messages.dart';
import '../../shared/failure_feedback.dart';
import 'zone_picker_dialog.dart';
import '../../navigation/app_router.dart';

/// What the site editor starts from: an existing [site] to edit, or a new
/// site pre-filled with [latitude]/[longitude]/[name] (e.g. "save the
/// current position as a site").
class SiteEditorArgs {
  const SiteEditorArgs({
    this.site,
    this.latitude,
    this.longitude,
    this.name,
    this.activate = true,
  });

  final LocationProfile? site;
  final double? latitude;
  final double? longitude;
  final String? name;

  /// Whether a new site becomes the active one; false when it is added from
  /// the Library, which never changes the site used for planning (TD-090).
  final bool activate;
}

/// Creates or edits a saved site (TASK 7.3). Saving is the explicit user
/// action that writes a site; a new site becomes the active one.
///
/// S7.5 (RG-08 = E2, RG-09 = S3/M2, UX-21): coordinates come from typing,
/// the map or "Use current position" (GPS only on that tap; the fix only
/// fills the form until Save); elevation is optional and unknown when
/// empty; Bortle and SQM sit with the elevation and notes in a collapsed
/// "More (optional)" section, with the map link at the typed coordinates
/// (library.js `siteForm`); leaving with changes asks Cancel · Discard ·
/// Save.
class SiteEditorScreen extends StatefulWidget {
  const SiteEditorScreen({super.key, this.args = const SiteEditorArgs()});

  /// The sky-darkness section's remembered state (DisclosureViewModel).
  static const skyDarknessSection = 'sites.skyDarkness';

  final SiteEditorArgs args;

  @override
  State<SiteEditorScreen> createState() => _SiteEditorScreenState();
}

class _SiteEditorScreenState extends State<SiteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final LocationProfile? _original = widget.args.site;
  late final _name = TextEditingController(
    text: _original?.name ?? widget.args.name,
  );
  late final _latitude = TextEditingController(
    text: _coordinate(_original?.latitude ?? widget.args.latitude),
  );
  late final _longitude = TextEditingController(
    text: _coordinate(_original?.longitude ?? widget.args.longitude),
  );
  late double? _latitudeSource = _original?.latitude ?? widget.args.latitude;
  late double? _longitudeSource = _original?.longitude ?? widget.args.longitude;

  /// F21: elevation is typed in the chosen unit and stored in metres;
  /// an unchanged field keeps the stored value exactly.
  late final DisplayUnits _units =
      context.read<DisplaySettingsViewModel?>()?.units ?? DisplayUnits.metric;
  late final String _elevationShown = _original?.elevation == null
      ? ''
      : _trim(
          double.parse(
            _units.elevationOf(_original!.elevation!).toStringAsFixed(1),
          ),
        );
  late final _elevation = TextEditingController(text: _elevationShown);
  late final _sqm = TextEditingController(
    text: _original?.sqm == null ? '' : _trim(_original!.sqm!),
  );
  late final _notes = TextEditingController(text: _original?.notes);

  late String? _zoneId = _original?.timeZoneId;
  late int? _bortle = _original?.bortleClass;

  /// True once the zone came from the device, for the caption.
  bool _zoneFromDevice = false;
  bool _zoneTouched = false;
  bool _saving = false;
  bool _locating = false;

  Timer? _nameDebounce;
  bool _initialized = false;
  bool _applyingCoordinates = false;
  bool _settingAutomaticName = false;
  String? _automaticName;
  late String _positionSource;

  bool get _mayNameAutomatically =>
      _isNew && (_name.text.trim().isEmpty || _name.text == _automaticName);

  (double, double)? get _validPosition {
    if (CoordinateInput.validateLatitude(_latitude.text) != null ||
        CoordinateInput.validateLongitude(_longitude.text) != null) {
      return null;
    }
    return (
      CoordinateInput.parse(_latitude.text)!,
      CoordinateInput.parse(_longitude.text)!,
    );
  }

  String _coordinateName(double latitude, double longitude) =>
      'Site - ${_coordinate(latitude)}, ${_coordinate(longitude)}';

  void _setAutomaticName(String value) {
    final pristine = _initialized && !_changed;
    _automaticName = value;
    _settingAutomaticName = true;
    _name.text = value;
    _settingAutomaticName = false;
    if (pristine) _opened = _values();
  }

  void _coordinatesEdited() {
    if (_applyingCoordinates) return;
    _nameDebounce?.cancel();
    _lookupGeneration++;
    _nameLookup = _NameLookup.none;
    _offeredAt = null;
    _proposedAttribution = null;
    _positionSource = 'Entered manually · not saved';
    if (_mayNameAutomatically) {
      final point = _validPosition;
      _setAutomaticName(
        point == null ? '' : _coordinateName(point.$1, point.$2),
      );
    }
    _refresh();
    if (_mayNameAutomatically && _validPosition != null) {
      _nameDebounce = Timer(const Duration(milliseconds: 700), () {
        if (!mounted || _saving || _leaving || !_mayNameAutomatically) return;
        final point = _validPosition;
        if (point != null) unawaited(_proposeName(point.$1, point.$2));
      });
    }
  }

  /// F23 A5: the place-name proposal for a position from "Use current
  /// position" — for an empty name only, through the opt-in lookup.
  _NameLookup _nameLookup = _NameLookup.none;
  String? _proposedAttribution;

  /// The position the opt-in offer is for.
  (double, double)? _offeredAt;

  /// Only the newest lookup may answer.
  int _lookupGeneration = 0;

  /// Set once the user chose Discard or the site is saved: the page may go.
  bool _leaving = false;

  /// The form as it opened, to tell whether anything was changed (UX-21).
  late Object _opened = _values();

  Object _values() => (
    _name.text,
    _latitude.text,
    _longitude.text,
    _elevation.text,
    _sqm.text,
    _notes.text,
    _bortle,
    _zoneTouched,
  );

  bool get _changed => _values() != _opened;

  /// Whether the last build saw a change, so [PopScope.canPop] is rebuilt
  /// when a field that does not otherwise rebuild the form (name,
  /// elevation, notes) starts or stops differing (S7.V2, TD-084).
  bool _builtChanged = false;

  static String _coordinate(double? value) => value?.toStringAsFixed(5) ?? '';

  double _preservedCoordinate(TextEditingController field, double? original) =>
      original != null && field.text == _coordinate(original)
      ? original
      : CoordinateInput.parse(field.text)!;

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  bool get _isNew => _original == null;

  @override
  void initState() {
    super.initState();
    _positionSource = _original != null
        ? 'From saved site'
        : _validPosition != null
        ? 'From selected position — verify or replace'
        : 'Choose a position to name this site automatically.';
    if (_isNew) {
      _automaticName = widget.args.name;
      final point = _validPosition;
      if (_name.text.trim().isEmpty && point != null) {
        _setAutomaticName(_coordinateName(point.$1, point.$2));
      }
    }
    _opened; // include locally generated initial labels in the pristine state
    _initialized = true;
    if (_isNew) {
      _prefillDeviceZone();
      // Inherited coordinates need the same automatic enrichment as a map/GPS
      // result. Never look up an existing saved record or a known carried name.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            !_mayNameAutomatically ||
            (widget.args.name?.trim().isNotEmpty ?? false)) {
          return;
        }
        final point = _validPosition;
        if (point != null) unawaited(_proposeName(point.$1, point.$2));
      });
    }
    // The sky-darkness summary and the map link follow the typing.
    for (final c in [_latitude, _longitude]) {
      c.addListener(_coordinatesEdited);
    }
    for (final c in [_sqm, _elevation]) {
      c.addListener(_refresh);
    }
    // The back guard follows every field (S7.V2); only a flip rebuilds.
    for (final c in [_name, _elevation, _notes]) {
      c.addListener(_guardChanged);
    }
    _name.addListener(_nameEdited);
  }

  /// A typed name is the user's: the proposal, its source line and any
  /// pending answer give way to it.
  void _nameEdited() {
    if (_settingAutomaticName) return;
    _nameDebounce?.cancel();
    _lookupGeneration++;
    _automaticName = null;
    _proposedAttribution = null;
    setState(() => _nameLookup = _NameLookup.none);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _guardChanged() {
    if (mounted && _changed != _builtChanged) setState(() {});
  }

  /// A new site's zone defaults to the device zone (owner decision, TASK
  /// 7.3) — only as a pre-filled choice the user can change.
  Future<void> _prefillDeviceZone() async {
    final zone = await context.read<SiteViewModel>().deviceZoneId();
    if (!mounted || _zoneTouched) return;
    if (IanaTimeContext.tryCreate(zone) == null) return;
    setState(() {
      _zoneId = zone;
      _zoneFromDevice = true;
    });
  }

  @override
  void dispose() {
    _nameDebounce?.cancel();
    for (final c in [_name, _latitude, _longitude, _elevation, _sqm, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickZone() async {
    final choice = await showZonePicker(context, current: _zoneId);
    if (choice == null || !mounted) return;
    setState(() {
      _zoneId = choice.zoneId;
      _zoneTouched = true;
      _zoneFromDevice = false;
    });
  }

  Future<void> _pickOnMap() async {
    final lat = CoordinateInput.parse(_latitude.text);
    final lon = CoordinateInput.parse(_longitude.text);
    final start = (lat != null && lon != null && lat.abs() <= 90)
        ? LatLng(
            _preservedCoordinate(_latitude, _latitudeSource),
            _preservedCoordinate(_longitude, _longitudeSource),
          )
        : null;
    final point = await context.push<LatLng>(AppRouter.sitePick, extra: start);
    if (point == null || !mounted) return;
    _applyFix(point.latitude, point.longitude, source: 'From map · not saved');
  }

  /// "Use current position" (S7.5): the device position fills the
  /// coordinates, asked for only on this tap; nothing is stored until Save
  /// (trap 2: a GPS fix is transient). F23 A6 (CRUX-03): the fix fills them
  /// only if neither coordinate changed while it was found; a typed edit or
  /// a map pick meanwhile is kept, and the fix is offered, not applied. A
  /// fix that arrives after the editor closed writes nothing.
  Future<void> _useCurrentPosition() async {
    final siteVm = context.read<SiteViewModel>();
    final asked = (_latitude.text, _longitude.text);
    setState(() => _locating = true);
    try {
      final result = await siteVm.locateDevice();
      if (!mounted) return;
      switch (result) {
        case LocationFound(:final location):
          if ((_latitude.text, _longitude.text) == asked) {
            _applyFix(location.latitude, location.longitude);
          } else {
            _offerFix(location.latitude, location.longitude);
          }
        case LocationUnavailable(:final reason):
          showLocationFailure(context, siteVm, reason);
      }
    } catch (e) {
      AppLog.error('location', 'Could not get the position', error: e);
      if (mounted) {
        showFailure(context, FailureText.message('get your position', e));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Fills the coordinates from a fix, then proposes a name for them.
  void _applyFix(
    double latitude,
    double longitude, {
    String source = 'From device GPS · not saved',
  }) {
    _nameDebounce?.cancel();
    _applyingCoordinates = true;
    _latitudeSource = latitude;
    _longitudeSource = longitude;
    _latitude.text = _coordinate(latitude);
    _longitude.text = _coordinate(longitude);
    _applyingCoordinates = false;
    _lookupGeneration++;
    setState(() {
      _positionSource = source;
      _nameLookup = _NameLookup.none;
      _proposedAttribution = null;
      if (_mayNameAutomatically) {
        _setAutomaticName(_coordinateName(latitude, longitude));
      }
    });
    unawaited(_proposeName(latitude, longitude));
  }

  /// Enrich only this new draft's generated label. A late result cannot
  /// replace a user label, a newer position, or a site being saved.
  Future<void> _proposeName(double latitude, double longitude) async {
    if (!_mayNameAutomatically) return;
    _nameDebounce?.cancel();
    final generation = ++_lookupGeneration;
    final requestedFields = (_latitude.text, _longitude.text);
    _offeredAt = (latitude, longitude);
    if (!context.read<SettingsViewModel>().placeNameLookup) {
      setState(() => _nameLookup = _NameLookup.offer);
      return;
    }
    setState(() => _nameLookup = _NameLookup.looking);
    ReverseGeocodeResult result;
    try {
      result = await context.read<SiteViewModel>().lookUpPlaceName(
        latitude,
        longitude,
      );
    } catch (e) {
      result = ReverseGeocodeFailed('$e');
    }
    if (!mounted || _saving || _leaving || generation != _lookupGeneration) {
      return;
    }
    if ((_latitude.text, _longitude.text) != requestedFields ||
        !_mayNameAutomatically) {
      return;
    }
    setState(() {
      switch (result) {
        case PlaceNameFound(:final name, :final attribution):
          _proposedAttribution = attribution;
          _nameLookup = _NameLookup.found;
          _setAutomaticName(name);
        case PlaceNameNotFound():
          _nameLookup = _NameLookup.notFound;
        case ReverseGeocodeFailed(:final reason):
          AppLog.warning('location', 'Place-name lookup failed: $reason');
          _nameLookup = _NameLookup.failed;
      }
    });
  }

  /// The user's explicit opt-in from the offer: the same setting as in
  /// Settings, then the lookup for the offered position.
  Future<void> _turnOnPlaceNames() async {
    final at = _offeredAt;
    final generation = _lookupGeneration;
    final on = await runWithFeedback(
      context,
      'save the place-name setting',
      () => context.read<SettingsViewModel>().setPlaceNameLookup(true),
    );
    if (!on ||
        !mounted ||
        at == null ||
        generation != _lookupGeneration ||
        _offeredAt != at ||
        !_mayNameAutomatically) {
      return;
    }
    setState(() => _nameLookup = _NameLookup.none);
    await _proposeName(at.$1, at.$2);
  }

  String? get _nameHelper => switch (_nameLookup) {
    _NameLookup.looking => 'Looking up a place name…',
    _NameLookup.found =>
      'Filled automatically · ${_proposedAttribution ?? 'place-name lookup'}',
    _NameLookup.notFound =>
      'No place name found. The coordinate name can be saved.',
    _NameLookup.failed =>
      'Name lookup failed. The coordinate name can be saved.',
    _NameLookup.offer => 'Place names are off.',
    _NameLookup.none =>
      _validPosition == null && _isNew
          ? 'Choose a position to fill the name.'
          : null,
  };

  Future<void> _nameAction() async {
    final point = _validPosition;
    if (point == null || !_mayNameAutomatically) return;
    if (!context.read<SettingsViewModel>().placeNameLookup) {
      _offeredAt = point;
      final on = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          key: const Key('siteEditor.placeNameOffer'),
          title: const Text('Use place names automatically?'),
          content: const Text(
            'Turning this on sends selected coordinates to OpenStreetMap '
            'Nominatim to find a place name. The setting also applies to '
            'future positions and can be changed in Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Turn on place names'),
            ),
          ],
        ),
      );
      if (on != true || !mounted) return;
      await _turnOnPlaceNames();
    } else {
      await _proposeName(point.$1, point.$2);
    }
  }

  /// The coordinates were edited while the fix was found: they stay, and
  /// the fix is the user's choice, until they use it or close the message.
  void _offerFix(double latitude, double longitude) {
    ScaffoldMessenger.of(context).showMessage(
      SnackBar(
        key: const Key('siteEditor.positionFound'),
        content: Text(
          'Position found: ${_coordinate(latitude)}, '
          '${_coordinate(longitude)}. Your edited coordinates are kept.',
        ),
        persist: true,
        showCloseIcon: true,
        action: SnackBarAction(
          label: 'Use position',
          onPressed: () {
            if (mounted) _applyFix(latitude, longitude);
          },
        ),
      ),
    );
  }

  Future<void> _openMap() async {
    final url = SiteFormInput.mapLink(_latitude.text, _longitude.text);
    if (url == null) return;
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLog.error('sites', 'Could not open the light-pollution map', error: e);
      if (mounted) {
        showFailure(context, FailureText.message('open the map', e));
      }
    }
  }

  /// Back with changes (UX-21, S5.8's prompt): Cancel stays, Discard leaves,
  /// Save saves and leaves when it succeeds.
  Future<void> _onBack() async {
    if (_leaving) return;
    if (!_changed) {
      setState(() => _leaving = true);
      context.pop();
      return;
    }
    final label = _name.text.trim().isEmpty
        ? (_isNew ? AppWords.newSite : _original!.name)
        : _name.text.trim();
    final choice = await askUnsavedChanges(context, plan: label, library: true);
    if (!mounted) return;
    switch (choice) {
      case UnsavedChoice.cancel:
        return;
      case UnsavedChoice.discard:
        setState(() => _leaving = true);
        context.pop();
      case UnsavedChoice.save:
        await _save();
    }
  }

  Future<void> _save() async {
    // A hidden (collapsed) SQM field is not validated by the form: open the
    // section so the message shows next to the value.
    if (SiteFormInput.validateSqm(_sqm.text) != null) {
      await context.read<DisclosureViewModel>().setOpen(
        SiteEditorScreen.skyDarknessSection,
        true,
      );
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!mounted) return;
    if (_isNew && _name.text.trim().isEmpty) {
      final point = _validPosition;
      if (point != null) _setAutomaticName(_coordinateName(point.$1, point.$2));
    }
    if (!_formKey.currentState!.validate()) return;
    final siteVm = context.read<SiteViewModel>();
    final LocationProfile site;
    try {
      site = LocationProfile.userEdit(
        original: _original,
        name: _name.text.trim(),
        latitude: _preservedCoordinate(_latitude, _latitudeSource),
        longitude: _preservedCoordinate(_longitude, _longitudeSource),
        elevation: _elevation.text == _elevationShown
            ? _original?.elevation
            : switch (CoordinateInput.parse(_elevation.text)) {
                final v? => _units.metresFrom(v),
                null => null,
              },
        timeZoneId: _zoneId,
        notes: SiteFormInput.optionalText(_notes.text),
        bortleClass: _bortle,
        sqm: CoordinateInput.parse(_sqm.text),
        today: siteVm.today,
      );
    } on ArgumentError catch (e) {
      showFailure(context, SiteFormInput.refused(e));
      return;
    }
    _lookupGeneration++;
    setState(() => _saving = true);
    final saved = await runWithFeedback(
      context,
      'save the site',
      () => siteVm.saveSite(site, activate: widget.args.activate),
    );
    if (!mounted) return;
    if (saved) {
      setState(() => _leaving = true);
      // S9.8 (D9-5): a save says so; the message outlives this page.
      showDone(context, 'Site saved');
      context.pop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const numberKeyboard = TextInputType.numberWithOptions(
      signed: true,
      decimal: true,
    );
    _builtChanged = _changed;
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _onBack},
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: PopScope(
          canPop: _leaving || !_builtChanged,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _onBack();
          },
          child: _form(context, numberKeyboard),
        ),
      ),
    );
  }

  Widget _form(BuildContext context, TextInputType numberKeyboard) {
    final p = AppPalette.of(context);
    final style = libraryInputStyle(context);
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) >= 1.5 ||
        MediaQuery.sizeOf(context).width < 360;
    final latitude = LibraryField(
      label: 'Latitude (°)',
      top: 0,
      child: TextFormField(
        key: const Key('siteEditor.latitude'),
        controller: _latitude,
        style: style,
        keyboardType: numberKeyboard,
        validator: CoordinateInput.validateLatitude,
      ),
    );
    final longitude = LibraryField(
      label: 'Longitude (°)',
      top: 0,
      child: TextFormField(
        key: const Key('siteEditor.longitude'),
        controller: _longitude,
        style: style,
        keyboardType: numberKeyboard,
        validator: CoordinateInput.validateLongitude,
      ),
    );
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: Text(_isNew ? AppWords.newSite : AppWords.editSite),
      ),
      // library.js `saveBar`: Cancel and Save site, always in reach.
      bottomNavigationBar: LibrarySaveBar(
        saveKey: const Key('siteEditor.save'),
        cancelKey: const Key('siteEditor.cancel'),
        saveLabel: AppWords.saveSite,
        onCancel: _saving ? null : _onBack,
        onSave: _saving ? null : _save,
      ),
      body: Form(
        key: _formKey,
        child: HybridPlanInputs(
          child: SingleChildScrollView(
            key: const Key('siteEditor.scroll'),
            padding: settingsPagePadding,
            // Every field is built, so Save validates them all.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DocumentSection(
                  key: const Key('siteEditor.positionGroup'),
                  children: [
                    const GeoHeading('Position'),
                    const SizedBox(height: AppSpacing.sm),
                    GeoPositionActions(
                      locating: _locating,
                      onLocate: _useCurrentPosition,
                      onMap: _pickOnMap,
                    ),
                    const SizedBox(height: AppSpacing.itemGap),
                    if (_positionSource.startsWith('From device GPS') ||
                        _positionSource.startsWith('From map')) ...[
                      SettingsCopy(_positionSource),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (stacked) ...[
                      latitude,
                      const SizedBox(height: AppSpacing.itemGap),
                      longitude,
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppSpacing.itemGap,
                        children: [
                          Expanded(child: latitude),
                          Expanded(child: longitude),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DocumentSection(
                  key: const Key('siteEditor.identityGroup'),
                  children: [
                    const GeoHeading('Site name and time zone'),
                    const SizedBox(height: AppSpacing.sm),
                    LibraryField(
                      label: 'Name',
                      top: 0,
                      hint: _nameHelper,
                      child: TextFormField(
                        key: const Key('siteEditor.name'),
                        controller: _name,
                        maxLines: 1,
                        style: style,
                        decoration: InputDecoration(
                          suffixIcon:
                              _mayNameAutomatically && _validPosition != null
                              ? IconButton(
                                  key: const Key('siteEditor.lookupName'),
                                  tooltip: _nameLookup == _NameLookup.offer
                                      ? 'Turn on place names'
                                      : 'Look up place name',
                                  onPressed: _nameLookup == _NameLookup.looking
                                      ? null
                                      : _nameAction,
                                  icon: const Icon(
                                    Icons.place_outlined,
                                    size: 18,
                                  ),
                                )
                              : null,
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: SiteFormInput.validateName,
                      ),
                    ),
                    LibraryField(
                      label: 'Time zone',
                      top: AppSpacing.itemGap,
                      hint: _zoneFromDevice
                          ? 'From device — check for this site.'
                          : 'Used for local dates and daylight-saving changes.',
                      // A select that opens the searchable zone list.
                      child: Semantics(
                        button: true,
                        child: InkWell(
                          key: const Key('siteEditor.zone'),
                          borderRadius: BorderRadius.circular(6),
                          onTap: _pickZone,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              contentPadding: hybridSelectPadding,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _zoneId ??
                                        'Unknown — night uses mean solar time',
                                    style: style,
                                  ),
                                ),
                                hybridSelectIcon(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SettingsCopy(
                      !_isNew
                          ? 'Saved plans and Logbook entries keep their recorded site.'
                          : widget.args.activate
                          ? 'Save also selects this site for planning.'
                          : 'Save adds this site to Library without selecting it.',
                    ),
                  ],
                ),
                // RG-08 = E2, RG-09 = S3: optional, without prominence; empty
                // is unknown. One remembered section (library.js More).
                const SizedBox(height: AppSpacing.md),
                DocumentSection(
                  key: const Key('siteEditor.moreGroup'),
                  children: [
                    CollapsibleSection(
                      key: const Key('siteEditor.more'),
                      sectionKey: SiteEditorScreen.skyDarknessSection,
                      title: 'More (optional)',
                      topRule: false,
                      titleStyle: AppTextTheme.of(context).body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary,
                      ),
                      summary: _moreSummary(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LibraryField(
                            label:
                                'Elevation (${_units.elevation.symbol}, optional)',
                            hint:
                                'Above sea level, '
                                '${_units.elevation == ElevationUnit.feet ? 'in feet' : 'in metres'}. '
                                'Empty stays unknown.',
                            top: 0,
                            child: TextFormField(
                              key: const Key('siteEditor.elevation'),
                              controller: _elevation,
                              style: style,
                              keyboardType: numberKeyboard,
                              validator: (t) =>
                                  SiteFormInput.validateElevation(t, _units),
                            ),
                          ),
                          if (FeatureScope.lightPollutionContext)
                            ..._skyDarknessFields(),
                          LibraryField(
                            label: 'Notes (optional)',
                            child: TextFormField(
                              key: const Key('siteEditor.notes'),
                              controller: _notes,
                              style: style,
                              minLines: 3,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Bortle 4 · SQM 21.2 · 160 m", or what the section holds.
  String _moreSummary() {
    final sqm = CoordinateInput.parse(_sqm.text);
    final set = [
      if (_elevation.text.trim().isNotEmpty)
        '${_elevation.text.trim()} ${_units.elevation.symbol}',
      if (_bortle != null) 'Bortle $_bortle',
      if (sqm != null) 'SQM ${_sqm.text.trim()}',
    ];
    return set.isEmpty ? 'Elevation, sky darkness and notes' : set.join(' · ');
  }

  /// Bortle and SQM with their source (TASK 7.3); a hidden value is kept
  /// unchanged on save. The map opens at the typed coordinates.
  List<Widget> _skyDarknessFields() {
    final original = _original;
    final style = libraryInputStyle(context);
    // S9.7: the source and a readable date, never an ISO string.
    String? sourceCaption(String? source, CalendarDate? date) => source == null
        ? null
        : 'Source: $source'
              '${date == null ? '' : ' · ${NightTimeFormatter.recordedDate(date)}'}';
    final link = SiteFormInput.mapLink(_latitude.text, _longitude.text);
    return [
      LibraryField(
        label: 'Bortle class',
        hint: _bortle != null && _bortle == original?.bortleClass
            ? sourceCaption(original?.bortleSource, original?.bortleDate)
            : null,
        child: DropdownButtonFormField<int?>(
          key: const Key('siteEditor.bortle'),
          initialValue: _bortle,
          isExpanded: true,
          style: style,
          icon: hybridSelectIcon(context),
          decoration: const InputDecoration(
            contentPadding: hybridSelectPadding,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Unknown')),
            for (var b = 1; b <= 9; b++)
              DropdownMenuItem(value: b, child: Text('Bortle $b')),
          ],
          onChanged: (value) => setState(() => _bortle = value),
        ),
      ),
      LibraryField(
        label: 'SQM (mag/arcsec²)',
        hint:
            sourceCaption(original?.sqmSource, original?.sqmDate) ??
            'Empty = unknown. 15 to 23.',
        child: TextFormField(
          key: const Key('siteEditor.sqm'),
          controller: _sqm,
          style: style,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: SiteFormInput.validateSqm,
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          key: const Key('siteEditor.mapLink'),
          onPressed: link == null ? null : _openMap,
          child: const Text('Look it up on lightpollutionmap.app'),
        ),
      ),
      const SettingsCopy(
        'Bortle and SQM are never converted into each other.',
        top: AppSpacing.xs,
      ),
    ];
  }
}

/// Where the site editor's name proposal stands (F23 A5).
enum _NameLookup { none, offer, looking, found, notFound, failed }
