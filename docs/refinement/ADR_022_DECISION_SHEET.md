# ADR-022 decision sheet — night conditions (F13, with F14/F15 conventions)

**Status: ACCEPTED by the owner in full, 2026-10-18 (chat answer «Прийняти все (Recommended)»; recorded in `docs/DECISIONS.md`). The text below is unchanged from the proposal.** *Proposal note:* PROPOSED for the owner's local acceptance (F13 A1–A5). Not an accepted ADR, not
implemented. Prepared 2026-10-18 in the full final-plan run. MF-c (owner, RA.D Q2, 2026-10-17)
and D9 A (owner, 2026-10-18) are accepted semantics and are not asked again; this sheet asks for the
exact predicate derivation, interval/phase rules, weather conventions, caches and the D9 control
matrix. On acceptance it is recorded as ADR-022 in `docs/DECISIONS.md`, amending ADR-010, ADR-012
§4/§6 and ADR-013 G4 where stated.

Current code (2026-10-18): `MoonCalculator.riseSetForNight` uses the **geocentric** geometric
altitude against h₀ = 0.7275 π − 0.5667° (Meeus ch. 15); `conditionsForNight` and
`ImagingOpportunityCalculator` count the Moon as up when its **topocentric centre** altitude
> 0° (airless). The two definitions disagree by up to about 0.8° near the horizon, i.e. several
minutes of "Moon up" (SI-015, AUD-07).

## Numbered choices

| # | Choice | Recommendation (R) | Alternative considered |
| --- | --- | --- | --- |
| N1 | One Moon-up predicate (MF-c) | The Moon is up at an instant when its **topocentric** geometric centre altitude h_t (ellipsoid, sea level, Meeus ch. 40, as now) satisfies **h_t > −(0.2725 π + 0.5667°)**, π = the equatorial horizontal parallax at that instant. Derivation: MF-c means the upper limb on the apparent horizon with standard refraction R = 34′ = 0.5667°; the topocentric semidiameter is s ≈ 0.2725 π (Meeus ch. 55, k = 0.2725), so the limb condition is h_t + s + R > 0. Near the horizon the parallax in altitude is π cos h ≈ π, so h_t ≈ h_geo − π and the condition is h_geo > 0.7275 π − 0.5667°, which is exactly Meeus' h₀: the same event, not a copied threshold in another frame. Residual difference of the two forms below 1″·cos-terms (cos h ≈ 0.9999 within 1° of the horizon) and the topocentric augmentation of s (< 0.3 %, < 3″) | Keep h₀ on geocentric altitude for rise/set and switch counts to it (rejected: two frames for one sample stream, and the counts need the topocentric position for separation) |
| N2 | Where N1 applies | Everywhere the Moon is "up": rise/set (`riseSetForNight` evaluated on the same topocentric samples), up-time counts and annotations (CALC-29/43), the Moon gate G4 (ADR-013), the closest approach "while both up", the moon-free intervals (N4), Night & Moon text and the calendar. The target's own altitude rules are unchanged | — |
| N3 | Sampling and equality | The night's existing 5-minute grid on [SessionNight.start, end] (ADR-007 §9); a crossing is reported at the first sample after it; a sample exactly at the threshold counts as **down** (strict >). A batch computation and a single-night computation must give identical samples (one function) | Root-finding to the second (rejected: the plan's resolution is the grid; text says "about") |
| N4 | Moon-free intervals | Dark samples = Sun at or below the plan's darkness limit (preference, default −18°; the existing rule). Moon-free = dark ∧ ¬N1. Merge consecutive samples into intervals. Classify: `noDark` (no dark sample; known absence, not missing data); `none` (dark exists, no moon-free sample); `allNight` (every dark sample moon-free, one interval); `evening` (one interval starting at the first dark sample, ending before the last); `morning` (one interval ending at the last dark sample, starting after the first); `middle` (one interval touching neither end); `mixed` (two or more intervals, each listed); `unknown` (no site/night). Durations are sample counts × 5 min | Treat `middle` as `mixed` (rejected: it is one interval and reads clearly) |
| N5 | Phase name | From the phase longitude λ (Moon − Sun apparent ecliptic longitude, `phaseLongitudeDeg`) at the night's reference instant = SessionNight start + 12 h (local midnight, the instant `illuminationAtMidnight` already uses). Eight names in 45° bins centred on 0/45/…/315°: New (337.5–22.5), Waxing crescent, First quarter (67.5–112.5), Waxing gibbous, Full (157.5–202.5), Waning gibbous, Last quarter (247.5–292.5), Waning crescent. The name never substitutes for N4 | Name only the four principal phases within ±1 day (rejected: most nights would have no name) |
| N6 | Forecast slicing (F14) | Per night, the hourly rows whose UTC instant lies in [dark start, dark end] (the N4 dark span; when there is no dark span, astronomical night is absent and the card says so; the sunset-to-sunrise span is used only for the "No dark time" card's text). Instantaneous variables (temperature, dew point, humidity, cloud cover total/low/mid/high, wind speed, visibility) are taken at their instant. Preceding-hour variables (precipitation probability, wind gusts — Open-Meteo convention recorded in RA_R2C, not re-fetched in this session) describe (t − 1 h, t] and are included when that hour overlaps the dark span by at least 30 minutes. A partial first/last hour is shown as partial; a missing variable or hour is a gap, never zero or clear. Dew-risk duration = number of in-span instants with T − Td ≤ the dew margin, × 1 h, labelled "about" | Interpolate to the 5-minute grid (rejected: invents precision) |
| N7 | Multi-night horizon (F14 A1) | One request per site with `forecast_days = 16` (the provider's maximum, as now) and `timezone = UTC`. A night is **complete** only when every hour of its dark span is returned; the first night is usually partial (past hours) and the last is truncated: both are labelled. Never "16 nights" | — |
| N8 | Weather cache identity (F14 A2) | Key = (latitude and longitude rounded to 0.01°, provider model id, `forecast_days`, cache format version 2). The site id is not part of the identity. A response is attached only if its request key equals the current site's key when it arrives (late responses for an edited site are dropped). Version-1 keys (TD-049) are deleted on first read; no migration of their content | Keep site-id keys and invalidate on edit (rejected: the race remains) |
| N9 | Two time labels (F14 A4) | Retrieval age = now − fetched time ("Updated 3 h ago"), as now. Lead time = the night's evening date − the site-local date of the fetch, in whole days ("forecast made 2 days ahead"; 0 = "made on the day"). Neither is a reliability score | Hours of lead (rejected: false precision) |
| N10 | Moon calendar cache (F15 A1) | Month computed in an isolate; cache key = (latitude/longitude rounded to 0.01°, IANA zone id, darkness limit, calculator version, year-month). Invalidated by any key change; never by weather | — |
| N11 | D9 control matrix (F13 A5, SP08) | **Edit the active plan:** Home subtitle (site/night), Planner context. **Browse only (no write):** Night & Moon calendar day, week view, time slider, forecast overview card, "View this night" — each labelled "Viewing Fri 18 Dec · Your plan: Tonight". **Adopt:** only "Plan this night" in a browse view. Adoption: a never-saved draft → its night changes (feedback "Plan moved to Fri 18 Dec"); a saved, unchanged plan → a guarded copy for that night (feedback "Copy made for Fri 18 Dec; the saved plan is unchanged"); a saved plan with unsaved changes → Save / Discard / Cancel first: Save failure or Cancel stops; Discard restores the saved plan before copying; an explicit Save writes normally, then the copy. The original snapshot/result is never retimed. Back without adopting changes nothing | Let calendar taps edit the plan directly (rejected by D9 A) |
| N12 | D9 renders | The existing P3 proposal renders (FINALIZATION_REVIEW §19, SP08) illustrate N11; the implemented screens' renders are F15/F17/F18 evidence and need the owner's visual acceptance there | — |

## Reference vectors

| ID | Case | Expected |
| --- | --- | --- |
| M1 | Any instant: threshold for π = 0.95° | −(0.2725 × 0.95 + 0.5667) = −0.8256° topocentric |
| M2 | Equivalence: for each 5-minute sample of three nights (Ljubljana 46.05 N, Tromsø 69.65 N, Quito 0.18 S) the topocentric predicate (N1) and the geocentric h₀ predicate agree except within one sample of a crossing | no disagreement more than one grid step from a crossing |
| M3 | USNO rise/set (Ljubljana, three dates, from the existing authoritative fixtures in `test/fixtures/astronomy/`) | each N1 crossing within one 5-minute step of the reference time |
| M4 | Polar: a Moon that never rises / never sets in a polar night | no event; all samples down / up; moon-free `allNight` / `none` |
| M5 | Batch = single | identical sample lists |
| M6 | Classification vectors (synthetic sample streams) | `noDark`, `none`, `allNight`, `evening`, `morning`, `middle`, `mixed` as N4 |
| M7 | Phase bins | λ = 0 → New; 22.4 → New; 22.6 → Waxing crescent; 90 → First quarter; 180 → Full; 270 → Last quarter; 337.6 → New |
| W1 | Dark span 19:10–04:50 UTC, hourly rows 18:00…06:00 | instants 20:00…04:00 in span; the 05:00 gust row (04:00–05:00) included (50 min overlap), the 20:00 gust row (19:00–20:00) included (50 min) |
| W2 | A null cloud value at 23:00 | a gap at 23:00; summary "1 h without forecast", never 0 % |
| W3 | Lead | fetched 2026-12-16 10:00 local, night 2026-12-18 → "made 2 days ahead" |

## What acceptance means

Accepting (all, or with numbered changes) lets F13 change the Moon calculations and `night_text`
and lets F14/F15/F17/F18 implement N6–N11. No new provider, seeing/transparency score, universal
"good night" threshold, simulator or astronomy engine is introduced.
