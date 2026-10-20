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
import '../../shared/location_feedback.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../shared/failure_feedback.dart';
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

  void _saveLocation() {
    if (_selectedLocation != null && widget.pickOnly) {
      context.pop(_selectedLocation);
      return;
    }
    if (_selectedLocation != null) {
      context.read<SiteViewModel>().setLocation(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: Text(widget.pickOnly ? 'Pick on map' : 'Choose a position'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location_alt),
            tooltip: 'Enter coordinates',
            onPressed: _enterCoordinates,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Use this point',
            onPressed: _selectedLocation != null ? _saveLocation : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          // F25 A1: the map is tappable, so it has a label.
          Semantics(
            label: 'Map. Tap to choose a point',
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
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
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_pin,
                          color: Theme.of(context).colorScheme.error,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                // OpenStreetMap tile usage policy: visible attribution linking
                // to the copyright page. Bottom-left, clear of the FAB. F25 A1:
                // the app's own line, which wraps at large text (flutter_map's
                // one-line widget overflowed at 200 %).
                const _OsmAttribution(),
              ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
        icon: const Icon(Icons.my_location),
        label: const Text('Use current position'),
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
        CoordinateInput.parse(_latitude.text)!,
        CoordinateInput.parse(_longitude.text)!,
      ),
    );
  }

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
  );
}
