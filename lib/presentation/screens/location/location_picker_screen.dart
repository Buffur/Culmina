import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/diagnostics/app_log.dart';
import '../../../core/config/app_identity.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/services/location_service.dart';
import '../../shared/coordinate_input.dart';
import '../../shared/hybrid_icon.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/quantity_text.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/location_feedback.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../shared/app_messages.dart';

class LocationPickerScreen extends StatefulWidget {
  /// With [pickOnly], confirming returns the point to the caller (the site
  /// editor, TASK 7.3) instead of making it the current position.
  const LocationPickerScreen({super.key, this.pickOnly = false, this.initial});

  final bool pickOnly;

  /// Where to start instead of the current position.
  final LatLng? initial;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    final siteVm = context.read<SiteViewModel>();
    _selectedLocation =
        widget.initial ?? LatLng(siteVm.latitude, siteVm.longitude);
  }

  Future<void> _getCurrentLocation() async {
    final siteVm = context.read<SiteViewModel>();
    setState(() => _isLoadingLocation = true);
    try {
      final result = await siteVm.locateDevice();
      if (!mounted) return;
      switch (result) {
        case LocationFound(:final location):
          _moveTo(LatLng(location.latitude, location.longitude), zoom: 10.0);
        case LocationUnavailable(:final reason):
          showLocationFailure(context, siteVm, reason);
      }
    } catch (e) {
      AppLog.error('location', 'Could not get the position', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showMessage(
          SnackBar(content: Text(FailureText.message('get your position', e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _moveTo(LatLng point, {double? zoom}) {
    setState(() => _selectedLocation = point);
    _mapController.move(point, zoom ?? _mapController.camera.zoom);
  }

  Future<void> _enterCoordinates() async {
    final point = await showDialog<LatLng>(
      context: context,
      builder: (_) => _CoordinateEntryDialog(initial: _selectedLocation),
    );
    if (point != null && mounted) _moveTo(point);
  }

  Future<void> _saveLocation() async {
    if (_selectedLocation != null && widget.pickOnly) {
      context.pop(_selectedLocation);
      return;
    }
    if (_selectedLocation != null) {
      final vm = context.read<SiteViewModel>();
      final point = _selectedLocation!;
      final ok = await runWithFeedback(
        context,
        'use the position',
        () => vm.setLocation(point.latitude, point.longitude),
      );
      if (ok && mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final point = _selectedLocation;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: hybridAppBar(
        context,
        title: Text(widget.pickOnly ? 'Pick on map' : 'Choose a position'),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: p.border)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                children: [
                  Text(
                    'Selected point',
                    style: AppTextTheme.of(context).body
                        .copyWith(color: p.textSecondary),
                  ),
                  TextButton(
                    key: const Key('location.coordinates'),
                    onPressed: _enterCoordinates,
                    child: const Text('Edit coordinates'),
                  ),
                ],
              ),
              if (point != null)
                Text(
                  '${QuantityText.degrees(point.latitude, digits: 5)}, ${QuantityText.degrees(point.longitude, digits: 5)}',
                  key: const Key('location.selectedPoint'),
                  style: AppTextTheme.of(context).rowTitle
                      .copyWith(color: p.textPrimary),
                ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('location.usePoint'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: point == null ? null : _saveLocation,
                child: const Text('Use this point'),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // F25 A1: the map is tappable, so it has a label.
          Semantics(
            label: 'Map. Tap to choose a point',
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                backgroundColor: p.surfaceRaised,
                initialCenter: _selectedLocation ?? const LatLng(51.5, -0.1),
                initialZoom: 5.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: AppIdentity.packageName,
                  // TASK 16.3: the app's identifying user agent, with a
                  // contact URL (OSM tile usage policy).
                  tileProvider: NetworkTileProvider(
                    headers: {'User-Agent': AppIdentity.userAgent},
                  ),
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        width: 12,
                        height: 12,
                        child: DecoratedBox(
                          key: const Key('location.marker'),
                          decoration: BoxDecoration(
                            color: p.textPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: p.surfaceRaised,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                // OpenStreetMap tile usage policy: visible attribution linking
                // to the copyright page. Bottom-left, clear of the FAB. F25 A1:
                // the app's own line, which wraps at large text (flutter_map's
                // one-line widget overflowed at 200 %).
                const Padding(
                  padding: EdgeInsets.only(right: 80),
                  child: _OsmAttribution(),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 12,
            child: Material(
              color: p.surfaceRaised,
              shape: const CircleBorder(),
              child: IconButton(
                key: const Key('location.useCurrentPosition'),
                tooltip: _isLoadingLocation
                    ? 'Getting position…'
                    : 'Use current position',
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: HybridIcon(
                  HybridIcons.locate,
                  size: 20,
                  color: p.textPrimary,
                ),
              ),
            ),
          ),
          if (_isLoadingLocation)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Typed latitude/longitude entry (TASK 7.2): works offline, without the map
/// tiles or a location permission.
class _CoordinateEntryDialog extends StatefulWidget {
  const _CoordinateEntryDialog({this.initial});

  final LatLng? initial;

  @override
  State<_CoordinateEntryDialog> createState() => _CoordinateEntryDialogState();
}

class _CoordinateEntryDialogState extends State<_CoordinateEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _latitude = TextEditingController(
    text: widget.initial?.latitude.toStringAsFixed(5),
  );
  late final TextEditingController _longitude = TextEditingController(
    text: widget.initial?.longitude.toStringAsFixed(5),
  );

  @override
  void dispose() {
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      LatLng(
        _coordinateValue(_latitude, widget.initial?.latitude),
        _coordinateValue(_longitude, widget.initial?.longitude),
      ),
    );
  }

  double _coordinateValue(TextEditingController field, double? original) =>
      original != null && field.text == original.toStringAsFixed(5)
      ? original
      : CoordinateInput.parse(field.text)!;

  @override
  Widget build(BuildContext context) {
    const keyboard = TextInputType.numberWithOptions(
      signed: true,
      decimal: true,
    );
    return AlertDialog(
      title: const Text('Enter coordinates'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _latitude,
              decoration: const InputDecoration(
                labelText: 'Latitude (°)',
                helperText: 'Decimal degrees, north positive',
              ),
              keyboardType: keyboard,
              validator: CoordinateInput.validateLatitude,
            ),
            TextFormField(
              controller: _longitude,
              decoration: const InputDecoration(
                labelText: 'Longitude (°)',
                helperText: 'Decimal degrees, east positive',
              ),
              keyboardType: keyboard,
              validator: CoordinateInput.validateLongitude,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Use')),
      ],
    );
  }
}

/// "© OpenStreetMap contributors", linking to the copyright page (the tile
/// usage policy), on the map's surface; it wraps rather than overflows.
class _OsmAttribution extends StatelessWidget {
  const _OsmAttribution();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.bottomLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            onTap: () =>
                launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('© ', style: Theme.of(context).textTheme.bodySmall),
                    Flexible(
                      child: Text(
                        'OpenStreetMap contributors',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
