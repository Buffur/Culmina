# Full browser-prototype backup representation — 2026-10-20

Changed only new `preview-backup.js` and `preview-backup.css`. The parent wires `mountBackupTools({storage, phone, announce})` in the workspace. It returns cleanup and listens for the phone's bubbling `culmina-backup` event. The stylesheet is loaded once by the module. Status/gesture insets, the established token/font system, 48 px controls, natural enlarged-text scrolling and phone-scoped focus are retained.

## Boundary and behavior

This is a truthful representation of the existing native backup intent, using its own `culmina-browser-preview-backup` version 1 JSON format. It explicitly does not read/write a native database, .astroplan backup or session manifest. It includes exactly five prototype localStorage keys: saved Plan (including every archived plan), working navigation draft, Library, Logbook and Settings. Missing keys are explicit nulls; unsaved example fixtures are not silently claimed as saved data. Site coordinates and notes are mentioned before download. No upload/network provider is involved.

Download validates current data first. Restore checks a maximum-4 MB local file, rejects unknown record keys and malformed data through existing module validators, presents actual plan/Library/Logbook/settings counts, offers download of current data, and waits for explicit confirmation. Cancel writes nothing. Confirmation compares the original five raw values with the review baseline before any mutation. It only replaces those listed keys. Refused writes trigger best-effort rollback; refused rollback is reported as possible partial changes, not success. Successful restore offers explicit reload to display restored records/settings. Concurrent stale-file reads cannot replace a newer review.

Pure testable exports: `previewBackupKeys`, `validatePreviewBackup(value)`, `capturePreviewBackup(storage)`, `restorePreviewBackup(storage, backup, baseline)`.

## Actual checks

`backup-checks.json` records five grouped checks, all passing in a fresh isolated headless Microsoft Edge profile on localhost:4173. Owner 127.0.0.1 origin/storage untouched.

1. Valid empty and populated backups pass; unknown keys and an invalid archived plan fail. Restoration keeps an unrelated key. Changed baseline blocks restoration. A refused second write fully rolls back; a refused rollback reports `rollbackComplete:false`.
2. Actual local download parses as the declared browser-preview backup format.
3. Invalid upload, valid review and Cancel leave storage empty.
4. Phone review at light/dark/field, 100/200% text: no horizontal overflow or <48 px controls. Screenshots alongside this report; light capture was visually inspected.
5. Explicit confirmation restores the checked target/draft and shows the reload action; closing releases inert background controls. No browser page errors.

`node --check` passes for the module. This is browser evidence, not native restore, Android/device accessibility, database transaction or platform share-sheet acceptance. Web Storage is not a multi-key transaction, which is why rollback failures have their own visible outcome.
