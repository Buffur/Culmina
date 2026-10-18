// Site editor field validation (TASK 7.3). S7.5 (RG-08 = E2): elevation is
// optional; the light-pollution map opens at the typed coordinates only.

import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/presentation/shared/site_form_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('name is required', () {
    expect(SiteFormInput.validateName('Backyard'), isNull);
    expect(SiteFormInput.validateName('   '), isNotNull);
    expect(SiteFormInput.validateName(null), isNotNull);
  });

  test('elevation is optional (empty = unknown), in metres, -500..9000', () {
    expect(SiteFormInput.validateElevation('295'), isNull);
    expect(SiteFormInput.validateElevation('-430'), isNull);
    expect(SiteFormInput.validateElevation(''), isNull);
    expect(SiteFormInput.validateElevation('  '), isNull);
    expect(SiteFormInput.validateElevation('high'), isNotNull);
    expect(SiteFormInput.validateElevation('9001'), isNotNull);
  });

  test('SQM is optional (empty = unknown), 15..23', () {
    expect(SiteFormInput.validateSqm(''), isNull);
    expect(SiteFormInput.validateSqm('21,2'), isNull);
    expect(SiteFormInput.validateSqm('14.9'), isNotNull);
    expect(SiteFormInput.validateSqm('dark'), isNotNull);
  });

  test('the map link: only for valid typed coordinates', () {
    expect(
      SiteFormInput.mapLink('46.05', '14,51').toString(),
      'https://lightpollutionmap.app/?lat=46.0500&lng=14.5100&zoom=10',
    );
    expect(SiteFormInput.mapLink('', '14.51'), isNull);
    expect(SiteFormInput.mapLink('95', '14.51'), isNull);
    expect(SiteFormInput.mapLink('46.05', '200'), isNull);
  });

  test(
    'a refused site value reads as its field message, not the raw error',
    () {
      String refusal(Object? Function() build) {
        try {
          build();
        } on ArgumentError catch (e) {
          return SiteFormInput.refused(e);
        }
        fail('not refused');
      }

      LocationProfile site({
        double latitude = 46,
        double elevation = 295,
        int? bortle,
        double? sqm,
      }) => LocationProfile(
        id: 1,
        name: 'Home',
        latitude: latitude,
        longitude: 14.5,
        elevation: elevation,
        bortleClass: bortle,
        sqm: sqm,
      );

      expect(
        refusal(() => site(latitude: 95)),
        'Latitude must be between -90 and 90',
      );
      expect(
        refusal(() => site(elevation: 9001)),
        'Elevation must be between -500 and 9000 m',
      );
      expect(
        refusal(() => site(bortle: 10)),
        'Bortle class must be between 1 and 9',
      );
      expect(refusal(() => site(sqm: 24)), 'SQM must be between 15 and 23');
      expect(
        SiteFormInput.refused(ArgumentError.value(1, 'other')),
        "The site can't be saved: check its values.",
      );
    },
  );

  test('optional text trims to null', () {
    expect(SiteFormInput.optionalText('  '), isNull);
    expect(SiteFormInput.optionalText(' Gate code 12 '), 'Gate code 12');
  });
}
