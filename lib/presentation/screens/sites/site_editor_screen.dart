import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';

import '../../shared/night_time_formatter.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/app_words.dart';

import 'dart:async';

import 'package:flutter/material.dart';
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
/// empty; Bortle and SQM sit in a collapsed "Sky darkness (optional)"
/// section with the map link at the typed coordinates; leaving with
/// changes asks Cancel · Discard · Save.
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

  /// F23 A5: the place-name proposal for a position from "Use current
  /// position" — for an empty name only, through the opt-in lookup.
  _NameLookup _nameLookup = _NameLookup.none;
  String? _proposedName;
  String? _proposedAttribution;

  /// The position the opt-in offer is for.
  (double, double)? _offeredAt;

  /// Only the newest lookup may answer.
  int _lookupGeneration = 0;

  /// Set once the user chose Discard or the site is saved: the page may go.
  bool _leaving = false;

  /// The form as it opened, to tell whether anything was changed (UX-21).
  late final Object _opened = _values();

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

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  bool get _isNew => _original == null;

  @override
  void initState() {
    super.initState();
    _opened; // the state before any edit
    if (_isNew) _prefillDeviceZone();
    // The sky-darkness summary and the map link follow the typing.
    for (final c in [_latitude, _longitude, _sqm]) {
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
    if (_nameLookup == _NameLookup.none) return;
    if (_nameLookup == _NameLookup.found && _name.text == _proposedName) {
      return;
    }
    if (_name.text.trim().isEmpty && _nameLookup != _NameLookup.found) return;
    _lookupGeneration++;
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
        ? LatLng(lat, lon)
        : null;
    final point = await context.push<LatLng>(AppRouter.sitePick, extra: start);
    if (point == null || !mounted) return;
    setState(() {
      _latitude.text = _coordinate(point.latitude);
      _longitude.text = _coordinate(point.longitude);
    });
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
  void _applyFix(double latitude, double longitude) {
    _latitude.text = _coordinate(latitude);
    _longitude.text = _coordinate(longitude);
    unawaited(_proposeName(latitude, longitude));
  }

  /// F23 A5: a new site's name from the consented place-name lookup. Never
  /// over a name already there or typed meanwhile, never for coordinates
  /// changed meanwhile; with place names off, the opt-in is offered and
  /// nothing is sent. Not finding a name never blocks typing or Save.
  Future<void> _proposeName(double latitude, double longitude) async {
    if (_name.text.trim().isNotEmpty) return;
    if (!context.read<SettingsViewModel>().placeNameLookup) {
      setState(() {
        _nameLookup = _NameLookup.offer;
        _offeredAt = (latitude, longitude);
      });
      return;
    }
    final generation = ++_lookupGeneration;
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
    if (!mounted || generation != _lookupGeneration) return;
    final stillThere =
        (_latitude.text, _longitude.text) ==
        (_coordinate(latitude), _coordinate(longitude));
    if (!stillThere || _name.text.trim().isNotEmpty) {
      setState(() => _nameLookup = _NameLookup.none);
      return;
    }
    setState(() {
      switch (result) {
        case PlaceNameFound(:final name, :final attribution):
          _proposedName = name;
          _proposedAttribution = attribution;
          _nameLookup = _NameLookup.found;
          _name.text = name;
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
    final on = await runWithFeedback(
      context,
      'save the place-name setting',
      () => context.read<SettingsViewModel>().setPlaceNameLookup(true),
    );
    if (!on || !mounted || at == null) return;
    setState(() => _nameLookup = _NameLookup.none);
    await _proposeName(at.$1, at.$2);
  }

  String? get _nameHelper => switch (_nameLookup) {
    _NameLookup.looking => 'Looking up a place name…',
    _NameLookup.found =>
      'Suggested by ${_proposedAttribution ?? 'a lookup'}; '
          'change it freely.',
    _NameLookup.notFound =>
      'No place name found for this position; '
          'enter a name.',
    _NameLookup.failed => 'No place name: the lookup failed. Enter a name.',
    _NameLookup.none || _NameLookup.offer => null,
  };

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
    final label = _name.text.trim().isEmpty
        ? (_isNew ? AppWords.newSite : _original!.name)
        : _name.text.trim();
    final choice = await askUnsavedChanges(context, plan: label);
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
    if (!mounted || !_formKey.currentState!.validate()) return;
    final siteVm = context.read<SiteViewModel>();
    final LocationProfile site;
    try {
      site = LocationProfile.userEdit(
        original: _original,
        name: _name.text.trim(),
        latitude: CoordinateInput.parse(_latitude.text)!,
        longitude: CoordinateInput.parse(_longitude.text)!,
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
    return PopScope(
      canPop: _leaving || !_builtChanged,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: _form(context, numberKeyboard),
    );
  }

  Widget _form(BuildContext context, TextInputType numberKeyboard) {
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: Text(_isNew ? AppWords.newSite : AppWords.editSite),
      ),
      // S9.2: one primary Save, always in reach (DESIGN_SYSTEM §9).
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton(
            key: const Key('siteEditor.save'),
            onPressed: _saving ? null : _save,
            child: const Text(AppWords.saveSite),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              key: const Key('siteEditor.name'),
              controller: _name,
              decoration: InputDecoration(
                labelText: 'Name',
                helperText: _nameHelper,
                helperMaxLines: 3,
              ),
              textCapitalization: TextCapitalization.words,
              validator: SiteFormInput.validateName,
            ),
            if (_nameLookup == _NameLookup.offer)
              _PlaceNameOffer(onTurnOn: _turnOnPlaceNames),
            TextFormField(
              controller: _latitude,
              decoration: const InputDecoration(
                labelText: 'Latitude (°)',
                helperText: 'Decimal degrees, north positive',
              ),
              keyboardType: numberKeyboard,
              validator: CoordinateInput.validateLatitude,
            ),
            TextFormField(
              controller: _longitude,
              decoration: const InputDecoration(
                labelText: 'Longitude (°)',
                helperText: 'Decimal degrees, east positive',
              ),
              keyboardType: numberKeyboard,
              validator: CoordinateInput.validateLongitude,
            ),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  key: const Key('siteEditor.useCurrentPosition'),
                  onPressed: _locating ? null : _useCurrentPosition,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use current position'),
                ),
                TextButton.icon(
                  onPressed: _pickOnMap,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Pick on map'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Time zone'),
              subtitle: Text(
                _zoneId == null
                    ? 'Unknown — night uses mean solar time'
                    : _zoneFromDevice
                    ? '$_zoneId (device zone)'
                    : _zoneId!,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickZone,
            ),
            // RG-08 = E2: optional, without prominence; empty is unknown.
            TextFormField(
              controller: _elevation,
              decoration: InputDecoration(
                labelText: 'Elevation (${_units.elevation.symbol})',
                helperText:
                    'Optional · ${_units.elevation == ElevationUnit.feet ? 'feet' : 'metres'} '
                    'above sea level; empty is unknown',
              ),
              keyboardType: numberKeyboard,
              validator: (t) => SiteFormInput.validateElevation(t, _units),
            ),
            if (FeatureScope.lightPollutionContext) _skyDarknessSection(),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Bortle and SQM (RG-09 = S3): one collapsed, remembered section whose
  /// summary states what is stored; each value with its source and date;
  /// the map at the typed coordinates. Unknown by default, no conversion.
  Widget _skyDarknessSection() {
    final sqm = CoordinateInput.parse(_sqm.text);
    final summary = [
      if (_bortle != null) 'Bortle $_bortle',
      if (sqm != null) 'SQM ${_sqm.text.trim()}',
    ];
    final link = SiteFormInput.mapLink(_latitude.text, _longitude.text);
    return CollapsibleSection(
      sectionKey: SiteEditorScreen.skyDarknessSection,
      title: 'Sky darkness (optional)',
      summary: summary.isEmpty ? 'Unknown' : summary.join(' · '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._skyDarknessFields(),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('siteEditor.mapLink'),
              onPressed: link == null ? null : _openMap,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Look it up on lightpollutionmap.app'),
            ),
          ),
        ],
      ),
    );
  }

  /// Bortle and SQM with their source (TASK 7.3); a hidden value is kept
  /// unchanged on save.
  List<Widget> _skyDarknessFields() {
    final original = _original;
    // S9.7: the source and a readable date, never an ISO string.
    String? sourceCaption(String? source, CalendarDate? date) => source == null
        ? null
        : 'Source: $source'
              '${date == null ? '' : ' · ${NightTimeFormatter.recordedDate(date)}'}';
    return [
      DropdownButtonFormField<int?>(
        initialValue: _bortle,
        decoration: InputDecoration(
          labelText: 'Bortle class',
          helperText: _bortle != null && _bortle == original?.bortleClass
              ? sourceCaption(original?.bortleSource, original?.bortleDate)
              : null,
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Unknown')),
          for (var b = 1; b <= 9; b++)
            DropdownMenuItem(value: b, child: Text('Bortle $b')),
        ],
        onChanged: (value) => setState(() => _bortle = value),
      ),
      TextFormField(
        controller: _sqm,
        decoration: InputDecoration(
          labelText: 'SQM (mag/arcsec²)',
          helperText:
              sourceCaption(original?.sqmSource, original?.sqmDate) ??
              'Empty = unknown',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: SiteFormInput.validateSqm,
      ),
    ];
  }
}

/// Where the site editor's name proposal stands (F23 A5).
enum _NameLookup { none, offer, looking, found, notFound, failed }

/// Place names are off: what a name suggestion would send, and the opt-in.
/// Nothing is sent until the user turns it on.
class _PlaceNameOffer extends StatelessWidget {
  const _PlaceNameOffer({required this.onTurnOn});

  final VoidCallback onTurnOn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('siteEditor.placeNameOffer'),
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A name can be suggested for this position. Place names are '
            'off: turning them on sends the chosen position to '
            'OpenStreetMap Nominatim, as in Settings.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextButton(
            onPressed: onTurnOn,
            child: const Text('Turn on place names'),
          ),
        ],
      ),
    );
  }
}
