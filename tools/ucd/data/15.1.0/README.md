# Unicode Character Database 15.1.0 — case data

Vendored copies of the Unicode Character Database files used by
`tools/ucd/ucd_generator` to generate `src/anystrings_ucd_case.ads/.adb`.

| File | Source | Used for |
|---|---|---|
| `UnicodeData.txt` | https://www.unicode.org/Public/15.1.0/ucd/UnicodeData.txt | simple upper / lower mappings (fields 12, 13) |
| `SpecialCasing.txt` | https://www.unicode.org/Public/15.1.0/ucd/SpecialCasing.txt | unconditional full mappings; the `Final_Sigma` entry |
| `DerivedCoreProperties.txt` | https://www.unicode.org/Public/15.1.0/ucd/DerivedCoreProperties.txt | `Cased`, `Case_Ignorable` (Final_Sigma context) |
| `LICENSE.txt` | https://www.unicode.org/license.txt | Unicode License v3, which governs the data files |

Version: Unicode 15.1.0 (UCD 15.1.0). The files are unmodified copies.

Fetch again with the same URLs if this version is ever replaced; add a new
`data/<version>/` directory rather than editing these files.
