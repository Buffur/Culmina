// Tests for NominatimReverseGeocoder (TASK 7.2): identifying user agent,
// rounded-coordinate cache, at most one request per second, attribution, and
// failures reported (not swallowed) and not cached.

import 'dart:async';
import 'dart:convert';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/services/nominatim_reverse_geocoder.dart';
import 'package:astroplan/domain/services/reverse_geocoder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A clock the test advances by hand; `delay` advances it too.
class _ManualClock extends Clock {
  DateTime now = DateTime.utc(2026, 9, 23, 20);

  @override
  DateTime nowUtc() => now;
}

String _found(String city) => json.encode({
  'address': {'city': city, 'country': 'Slovenia'},
});

void main() {
  late _ManualClock clock;
  late List<http.Request> requests;
  late List<Duration> delays;

  NominatimReverseGeocoder build(
    Future<http.Response> Function(http.Request) handler,
  ) {
    return NominatimReverseGeocoder(
      client: MockClient((request) {
        requests.add(request);
        return handler(request);
      }),
      clock: clock,
      delay: (d) async {
        delays.add(d);
        clock.now = clock.now.add(d);
      },
    );
  }

  setUp(() {
    clock = _ManualClock();
    requests = [];
    delays = [];
  });

  test('a found name carries the OpenStreetMap attribution', () async {
    final geocoder = build(
      (_) async => http.Response(_found('Ljubljana'), 200),
    );

    final result = await geocoder.placeNameFor(46.0569, 14.5058);

    expect(result, isA<PlaceNameFound>());
    final found = result as PlaceNameFound;
    expect(found.name, 'Ljubljana');
    expect(found.attribution, '© OpenStreetMap contributors');
  });

  test('sends the identifying user agent and rounded coordinates', () async {
    final geocoder = build(
      (_) async => http.Response(_found('Ljubljana'), 200),
    );

    await geocoder.placeNameFor(46.05691, 14.50579);

    final request = requests.single;
    expect(request.headers['User-Agent'], AppIdentity.userAgent);
    expect(AppIdentity.userAgent, contains(AppIdentity.packageName));
    expect(AppIdentity.userAgent, isNot(contains('com.example')));
    expect(request.url.host, 'nominatim.openstreetmap.org');
    expect(request.url.queryParameters['lat'], '46.06');
    expect(request.url.queryParameters['lon'], '14.51');
  });

  test(
    'coordinates that round to the same key are answered from the cache',
    () async {
      final geocoder = build(
        (_) async => http.Response(_found('Ljubljana'), 200),
      );

      final first = await geocoder.placeNameFor(46.0569, 14.5058);
      final second = await geocoder.placeNameFor(46.0571, 14.5061);

      expect(requests, hasLength(1));
      expect((second as PlaceNameFound).name, (first as PlaceNameFound).name);
    },
  );

  // F23 A1 (TD-097): the place-name keys in their documented precedence
  // (Nominatim `addressdetails`: city, town, village and municipality are
  // one group, then county and state). The first non-empty text wins; an
  // absent, empty or non-text value falls through to the next.
  group('the place name, by key precedence', () {
    Future<ReverseGeocodeResult> answer(Map<String, Object?> address) => build(
      (_) async => http.Response(json.encode({'address': address}), 200),
    ).placeNameFor(46.05, 14.5);

    String? nameOf(ReverseGeocodeResult r) =>
        r is PlaceNameFound ? r.name : null;

    test('a municipality-only answer names the place (Ljubljana, '
        'S11.4 S11P-01)', () async {
      final r = await answer({'municipality': 'Ljubljana', 'country': 'SI'});
      expect(nameOf(r), 'Ljubljana');
      expect((r as PlaceNameFound).attribution, '© OpenStreetMap contributors');
    });

    test('a settlement name comes before the municipality', () async {
      expect(
        nameOf(await answer({'village': 'Ig', 'municipality': 'Ig obcina'})),
        'Ig',
      );
      expect(
        nameOf(await answer({'town': 'Kamnik', 'municipality': 'Kamnik M'})),
        'Kamnik',
      );
    });

    test('the municipality comes before the county and the state', () async {
      expect(
        nameOf(
          await answer({
            'municipality': 'Ljubljana',
            'county': 'Central Slovenia',
            'state': 'Slovenia S',
          }),
        ),
        'Ljubljana',
      );
    });

    test('the existing precedence is unchanged', () async {
      expect(
        nameOf(await answer({'city': 'C', 'town': 'T', 'village': 'V'})),
        'C',
      );
      expect(nameOf(await answer({'town': 'T', 'village': 'V'})), 'T');
      expect(nameOf(await answer({'county': 'K', 'state': 'S'})), 'K');
      expect(nameOf(await answer({'state': 'S'})), 'S');
    });

    test('an empty or non-text value falls through to the next key', () async {
      expect(
        nameOf(await answer({'city': '  ', 'municipality': 'Ljubljana'})),
        'Ljubljana',
      );
      expect(nameOf(await answer({'city': 42, 'town': 'Kamnik'})), 'Kamnik');
    });

    test('no usable key: no name, so the coordinates are shown', () async {
      expect(
        await answer({'country': 'Slovenia', 'municipality': ''}),
        isA<PlaceNameNotFound>(),
      );
      expect(await answer({'road': 'Main St'}), isA<PlaceNameNotFound>());
    });
  });

  test('"no name here" is cached', () async {
    final geocoder = build(
      (_) async => http.Response('{"error":"Unable to geocode"}', 200),
    );

    expect(await geocoder.placeNameFor(40.0, -30.0), isA<PlaceNameNotFound>());
    expect(await geocoder.placeNameFor(40.0, -30.0), isA<PlaceNameNotFound>());
    expect(requests, hasLength(1));
  });

  group('failures are reported and not cached', () {
    Future<void> expectFailureThenRetry(
      Future<http.Response> Function(http.Request) failing,
    ) async {
      var fail = true;
      final geocoder = build(
        (r) => fail
            ? failing(r)
            : Future.value(http.Response(_found('Ljubljana'), 200)),
      );

      expect(
        await geocoder.placeNameFor(46.05, 14.51),
        isA<ReverseGeocodeFailed>(),
      );
      fail = false;
      expect(await geocoder.placeNameFor(46.05, 14.51), isA<PlaceNameFound>());
      expect(requests, hasLength(2), reason: 'the failure was not cached');
    }

    test('HTTP error', () async {
      await expectFailureThenRetry((_) async => http.Response('busy', 503));
    });

    test('network exception (offline)', () async {
      await expectFailureThenRetry(
        (_) async => throw http.ClientException('offline'),
      );
    });

    test('malformed body', () async {
      await expectFailureThenRetry((_) async => http.Response('<html>', 200));
    });

    test('timeout', () async {
      final geocoder = NominatimReverseGeocoder(
        client: MockClient((_) => Completer<http.Response>().future),
        timeout: const Duration(milliseconds: 10),
      );
      expect(
        await geocoder.placeNameFor(46.05, 14.51),
        isA<ReverseGeocodeFailed>(),
      );
    });
  });

  test('at most one request per second, sent one at a time', () async {
    var inFlight = 0;
    var maxInFlight = 0;
    final sentAt = <DateTime>[];
    final geocoder = build((_) async {
      inFlight++;
      maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
      sentAt.add(clock.now);
      await Future<void>.delayed(Duration.zero);
      inFlight--;
      return http.Response(_found('Somewhere'), 200);
    });

    // Three different places requested at once.
    final results = await Future.wait([
      geocoder.placeNameFor(46.0, 14.0),
      geocoder.placeNameFor(47.0, 15.0),
      geocoder.placeNameFor(48.0, 16.0),
    ]);

    expect(results, everyElement(isA<PlaceNameFound>()));
    expect(requests, hasLength(3));
    expect(maxInFlight, 1);
    for (var i = 1; i < sentAt.length; i++) {
      expect(
        sentAt[i].difference(sentAt[i - 1]),
        greaterThanOrEqualTo(const Duration(seconds: 1)),
      );
    }
    expect(delays, hasLength(2));
  });

  test('no wait when the previous request is more than a second old', () async {
    final geocoder = build((_) async => http.Response(_found('A'), 200));

    await geocoder.placeNameFor(46.0, 14.0);
    clock.now = clock.now.add(const Duration(seconds: 5));
    await geocoder.placeNameFor(47.0, 15.0);

    expect(requests, hasLength(2));
    expect(delays, isEmpty);
  });

  test(
    'a duplicate queued behind its twin is answered from the cache',
    () async {
      final geocoder = build((_) async => http.Response(_found('A'), 200));

      await Future.wait([
        geocoder.placeNameFor(46.0, 14.0),
        geocoder.placeNameFor(46.0, 14.0),
      ]);

      expect(requests, hasLength(1));
    },
  );
}
