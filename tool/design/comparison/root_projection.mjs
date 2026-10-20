// Maps only exported native fixture records into the approved browser shapes.
// No astronomy, weather, fit or storage calculation is performed here.
const types = { light: 'Light', dark: 'Dark', flat: 'Flat', bias: 'Bias', darkFlat: 'DarkFlat' };
const sensitivity = camera => ['astroColour', 'astroMono'].includes(camera) ? 'gain'
  : ['phone', 'dslrMirrorless'].includes(camera) ? 'iso' : null;
const iso = ms => ms == null ? null : new Date(ms).toISOString();

export function projectRoots(f) {
  if (!f.library || !f.settings || !f.logbook?.manifest || !f.plan?.fit) {
    throw new Error('All-root comparison requires native library/settings/logbook/fit DTOs');
  }
  const s = f.planSnapshot, p = s.preferences, fit = f.plan.fit;
  const rigs = Object.fromEntries(f.library.rigs.map(r => [String(r.nativeId), {
    ...r, camera: r.cameraClass, sensitivity: sensitivity(r.cameraClass),
    source: r.provenance.record,
  }]));
  const targets = f.library.targets.map(t => ({ ...t, aliasIds: t.aliasIds ?? [], aliasNames: t.aliasNames ?? [] }));
  const blocks = s.blocks.map((b, i) => ({
    id: `b${i + 1}`, type: types[b.frameType], exposure: String(b.exposureS),
    count: b.frameCount, filter: b.filterName ?? '', binning: b.binning,
    iso: b.gainKind === 'iso' ? b.gainValue : null,
    gain: b.gainKind === 'gain' ? b.gainValue : null,
    whiteBalance: b.wb?.mode === 'auto' ? 'Auto' : b.wb?.mode === 'kelvin' ? 'Kelvin' : 'Unrecorded',
    kelvin: b.wb?.kelvinK ?? null, tint: b.wb?.tint ?? null,
    focus: b.focusMode ?? 'Unrecorded',
    placement: b.frameType === 'light' || b.calibrationPolicy === 'inWindow' ? 'window'
      : b.calibrationPolicy === 'library' ? 'library' : 'outside',
  }));
  const assumptions = {
    perFrameOverhead: p.perFrameOverheadS,
    outsideSetup: (p.setupMin ?? 0) * 60,
    fitMargin: p.fixedMarginS ?? fit.availableMs / 1000 * p.feasibilityMarginPercent / 100,
    // Null remains unknown. The native estimate, not a made-up file size, renders storage.
    bytesPerFrame: f.plan.overrides?.bytesPerFrame ?? null,
  };
  const plan = {
    version: 1, target: s.target.catalogId, rig: String(s.rig.id),
    site: s.site.name, night: f.selectedEveningDate, blocks,
  };
  const entries = f.logbook.manifest.sessions.map(entry => {
    const snap = entry.plan_snapshot;
    if (!snap) throw new Error(`No native snapshot for comparison entry ${entry.id}`);
    const dark = snap.skyDarkness ?? {}, nativeResult = entry.results;
    const entryBlocks = entry.blocks.map(b => ({
      id: `b${b.id}`, type: types[b.frame_type], filter: b.filter_name,
      exposureS: b.exposure_s, planned: b.frame_count,
      sensitivity: b.gain_value, binning: b.binning,
    }));
    return {
      id: `example-native-${entry.id}`, example: true, name: entry.name,
      plan: {
        takenAtUtc: iso(snap.takenAtUtcMs), zone: entry.time_zone_id,
        night: { evening: entry.evening_date, startUtc: iso(snap.night.startUtcMs), endUtc: iso(snap.night.endUtcMs) },
        darknessLimitDeg: snap.preferences.darknessLimitDeg,
        minAltitudeDeg: snap.preferences.minAltitudeDeg,
        site: { name: snap.site.name, latDeg: snap.site.latitudeDeg, lonDeg: snap.site.longitudeDeg,
          elevationM: snap.site.elevationM ?? null, bortle: dark.bortleClass ?? null, sqm: dark.sqmMagArcsec2 ?? null },
        target: { name: entry.labels.target, raDec: null },
        rig: { name: entry.labels.rig, cameraClass: snap.rig.cameraClass,
          sensitivity: sensitivity(snap.rig.cameraClass), focalLengthMm: snap.rig.focalLengthMm,
          focalRatio: snap.rig.focalRatio, pixelUm: snap.rig.pixelPitchUm },
        blocks: entryBlocks,
      },
      result: nativeResult.result_kind == null && entry.status !== 'abandoned' ? null : {
        outcome: entry.status === 'abandoned' ? 'notDone' : nativeResult.result_kind,
        counts: Object.fromEntries(entry.blocks.filter(b => b.frame_type === 'light').map(b => [`b${b.id}`, b.confirmed_frames])),
        reason: nativeResult.not_done_reason,
        environmentalNotes: nativeResult.environmental_notes,
        processingNotes: nativeResult.processing_notes,
        recordedAtUtc: iso(entry.completed_at_utc_ms), local: false,
      },
    };
  });
  return {
    plan, assumptions, rigs, targets, entries,
    library: { rigs: f.library.rigs, sites: f.library.sites,
      targets: targets.filter(t => !t.bundled).map(t => ({ ...t, id: `local-native-target-${t.nativeId}` })) },
    settings: f.settings, fit,
    verdict: ({ fits: 'Fits', tight: 'Tight', doesNotFit: 'Doesn’t fit', noWindow: 'No window',
      needsInput: 'Needs window', nothingToFit: 'Needs a block' })[fit.state],
  };
}
