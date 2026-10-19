// F10 (C13, SI-004): a FITS GAIN that is not proposed says why, true to
// the rig's class: an ISO class records ISO; an unset class waits for the
// camera type; a gain class refuses only a value above any gain setting.

import 'package:astroplan/domain/services/block_proposal.dart';
import 'package:astroplan/presentation/shared/proposal_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a not-proposed gain names its own reason', () {
    expect(
      ProposalText.evidence(
        const ProposalEvidence.gain(100, GainNotProposed.recordsIso),
      ),
      'Gain 100: not proposed (this rig records ISO, and a gain is not an '
      'ISO)',
    );
    final unset = ProposalText.evidence(
      const ProposalEvidence.gain(100, GainNotProposed.classUnknown),
    );
    expect(unset, "Gain 100: not proposed until the rig's camera type is set");
    expect(unset, isNot(contains('ISO')));
    final high = ProposalText.evidence(
      const ProposalEvidence.gain(20000, GainNotProposed.outOfRange),
    );
    expect(high, contains('above any gain setting'));
    expect(high, isNot(contains('ISO')));
  });
}
