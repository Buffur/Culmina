# Culmina visual references

Owner-provided references for AM-01 and AM-04 (2026-10-18). Paths below resolve inside this directory; the project-root reference is `docs/Examples/`. These are visual/interaction examples, not Culmina runtime screenshots or acceptance evidence. Use existing Culmina tokens, real fonts, field-mode contrast conventions and accessible text alternatives.

| Reference | Applicable principle / task | Boundary |
| --- | --- | --- |
| [Familiar camera parameters](capture_parameters_reference.jpg) | AM-04 / F06: exposure, ISO, WB and focus labels; simple Phone/DSLR hierarchy | Camera UI reference, not a Culmina capture controller, recommended values or runtime evidence |
| [Night time slider](night_time_slider_reference.jpg) | F15 A5: readable time cursor, twilight/darkness band, explicit selected time and interval boundaries | No simulator/playback requirement; the cursor browses without changing a plan |
| [Moon calendar and interval bands](image.png) | F15 A1: month/selection hierarchy, separate Sun/Moon/dark intervals and concise duration | Culmina's SessionNight/frame definitions and model remain authoritative |
| [Weather overview](image%201.png) | F14 A3: selected period, readable hourly progression, icons with values and details below | No decorative mascot, general household weather dashboard or inferred observing score |
| [Multi-day chart](0ec88488-5e6e-4cf1-b0a8-10a1df272161.png) | F14 A3: aligned periods and explicit plotted values | Plot actual available data; unknown gaps are not interpolated into certainty |
| [Night forecast cards](d6634e6c-9f83-4675-a3a6-48771d48e290.png) | F14: night-focused cards and clear selected-night/detail hierarchy | No additional provider, aurora product, quality index or reliability promise |
| [Hourly weather and compact metrics](e6eca682-5e23-46f6-9deb-ce6f70a87b02.png) | F14 A3: compact hourly weather and consistent time alignment | Retain cloud/temperature/dew/wind/precip relevance; UV/AQI/feels-like gauges are not scope |
| [Gain chart reference](570b24b5-0229-4e09-a178-543889e51c0f.png) | F11: understandable axes and planned reference point in secondary detail | Do not adopt an absolute-SNR claim. Primary output is an ideal relative stacking estimate for comparable light frames |
| [Moonlit reference sources](moonlit-main/README.md) | Calendar/timeline/location layout reference only | No production dependency, imported engine/vendor assets or replacement astronomy/time semantics. Preserve the supplied sources/licences |

The slider JPEG is an unmodified copy of the image attached by the owner, SHA-256 `2f39f95dcfde1ee23bff505df88b90316b64ec08aae5a47de1d280be8edad0bf`. Original temporary/host paths are deliberately not project dependencies. Other supplied images and Moonlit are retained as received; no design or scientific endorsement is inferred from their contents.

Production acceptance uses actual implemented screens under the roadmap's U/W criteria. The P3 sketches are proposals from the earlier baseline; AM-01's current F criteria and amended SP contracts take precedence where they change those layouts.
