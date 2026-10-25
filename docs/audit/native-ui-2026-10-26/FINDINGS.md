# Findings by priority

18findings /16root groups:1P1,9P2,8P3. No correction is implemented. Approval establishes future scope only.

| Finding | Priority | Category | Root | Observed issue |
| --- | --- | --- | --- | --- |
| [UIA-0003](findings/UIA-0003.md) | P1 | A | RC-0003 | Editor completion drops newer accepted local input; Target also conflicts with an open Unsaved dialog |
| [UIA-0001](findings/UIA-0001.md) | P2 | A | RC-0001 | Plan Weather summary omits a known failed refresh and cache qualification |
| [UIA-0002](findings/UIA-0002.md) | P2 | A | RC-0002 | Results read failure has no explicit error/recovery UI outcome |
| [UIA-0004](findings/UIA-0004.md) | P2 | A | RC-0004 | End of available snapshot is inaccurately called the16-day boundary |
| [UIA-0005](findings/UIA-0005.md) | P2 | A | RC-0005 | Map attribution pointer and semantic target is only28dp high |
| [UIA-0010](findings/UIA-0010.md) | P2 | B | RC-0009 | Later forecast columns lose their hour identity |
| [UIA-0013](findings/UIA-0013.md) | P2 | A | RC-0012 | Enabled labels lose required text contrast under active ink feedback |
| [UIA-0015](findings/UIA-0015.md) | P2 | A | RC-0013 | Calibration action footer is unavailable while the Android numeric IME is open |
| [UIA-0016](findings/UIA-0016.md) | P2 | A | RC-0014 | Night browser keyboard focus reaches Previous above the visible viewport |
| [UIA-0018](findings/UIA-0018.md) | P2 | A | RC-0016 | Tonight labels the changed working target Saved while its draft write is pending |
| [UIA-0006](findings/UIA-0006.md) | P3 | A | RC-0006 | Candidates Refresh retains a settled-looking old list with no pending cue |
| [UIA-0007](findings/UIA-0007.md) | P3 | A | RC-0007 | Candidates filtered-empty text falsely diagnoses absent imaging windows |
| [UIA-0008](findings/UIA-0008.md) | P3 | A | RC-0006 | Entry-detail Retry presents the previous failure while its replacement read is pending |
| [UIA-0009](findings/UIA-0009.md) | P3 | A | RC-0008 | Shared date-picker day targets shrink below48dp at320dp |
| [UIA-0011](findings/UIA-0011.md) | P3 | B | RC-0010 | File-size provenance/recovery prose uses a narrow right-aligned numeric-value column |
| [UIA-0012](findings/UIA-0012.md) | P3 | A | RC-0011 | Add Block proposal copy names binning when the DSLR editor offers none |
| [UIA-0014](findings/UIA-0014.md) | P3 | A | RC-0006 | Library count Retry retains the previous failure without pending feedback |
| [UIA-0017](findings/UIA-0017.md) | P3 | A | RC-0015 | Optional-name focus ring remains below its field after a host inset transition |

UIA-0003 isP1 for loss of newer accepted local edits after prior Save/Apply completion. Correct submitted payloads remain stored; no stored-data corruption or native/release crash claim. See [priority adjudication](reviews/UIA-0003-PRIORITY.md).
