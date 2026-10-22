# Local Lucide subset

Seven original SVG assets were retrieved from `https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/{id}.svg` on 2026-10-22: `thermometer`, `droplets`, `wind`, `cloud-rain`, `moon`, `sun`, `cloud`.

`../../icons.js` embeds exactly their inner SVG geometry so the preview has no icon-network dependency. The source files retain their original 24×24 / stroke 2 metadata; the helper presents the same geometry at 20×20 with a consistent 1.7 CSS px non-scaling stroke. The icons are decorative beside text and are hidden from the accessibility tree. The actual scientific Moon phase glyph is separate and unchanged.

The adjacent `LICENSE` is an unmodified copy of the [upstream Lucide LICENSE](https://github.com/lucide-icons/lucide/blob/main/LICENSE), retrieved on the same date. It contains the ISC notice (Copyright (c) 2026 Lucide Icons and Contributors), the Feather-derived icon list and its additional MIT notice (Copyright (c) 2013-present Cole Bemis). `moon` is in that list. Retain this complete file when copying this subset or its embedded bodies. No Tabler or Iconify assets are bundled.

Browser proposal only. Keeping these local SVGs permits the same geometry to be reused after a separately authorized future platform migration; this package introduces no Flutter dependency or migration.
