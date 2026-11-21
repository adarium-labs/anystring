# tools/ucd — generated Unicode case tables

`src/anystrings_ucd_case.ads/.adb` are generated from the Unicode Character
Database (UCD) files in `data/<version>/` by `ucd_generator`. They are
committed. Do not edit them by hand.

They provide:

- the simple lower-case and upper-case mappings (`UnicodeData.txt`, fields 12
  and 13), used by `Simple_To_Lower` on every backend;
- the full lower-case and upper-case mappings (`SpecialCasing.txt`,
  unconditional entries), used by `To_Lower` and `To_Upper` on every backend
  (`Anystrings_Simple_Case`);
- the `Final_Sigma` entry and the `Cased` and `Case_Ignorable` properties
  (`DerivedCoreProperties.txt`), used for the Final_Sigma rule.

The tables are root locale only. The language-specific `SpecialCasing`
conditions (`lt`, `tr`, `az`) are not generated.

## Layout

| Path | What |
|---|---|
| `ucd_generator.gpr` | the generator project; plain GNAT, no dependencies |
| `src/ucd_generator.adb` | parses the UCD files and writes the two generated files |
| `regenerate.sh` | builds the generator and regenerates `src/` |
| `data/15.1.0/` | UnicodeData, SpecialCasing, DerivedCoreProperties (unmodified), the Unicode License v3 and a README with source URLs |

## Regenerating

```sh
alr exec -- tools/ucd/regenerate.sh        # uses the Alire toolchain (gprbuild, gnat)
tools/ucd/regenerate.sh                    # same, when gprbuild is on PATH
```

The output is deterministic. After regenerating, `git diff --exit-code` on
`src/anystrings_ucd_case.ads src/anystrings_ucd_case.adb` must be clean if
the data did not change.

The generator checks that every table is strictly ascending (it sorts the
`SpecialCasing` tables, which are grouped by script) and that there is exactly
one `Final_Sigma` entry. It stops with an error otherwise.

## Changing the Unicode version

1. Fetch `UnicodeData.txt`, `SpecialCasing.txt` and `DerivedCoreProperties.txt`
   from `https://www.unicode.org/Public/<version>/ucd/` into
   `data/<version>/`, and `https://www.unicode.org/license.txt` as
   `LICENSE.txt`. Write a README there like `data/15.1.0/README.md`.
2. Run `alr exec -- tools/ucd/regenerate.sh <version>`. The version is taken
   from the directory name and written into the generated files.
3. Run the gate: all backends build, the tests pass, and `tools/prove.sh`
   proves the generated unit.

Keep the old `data/` directory; do not overwrite it.

## Verification done for UCD 15.1.0

Checked once, against the VSS 26.2 tables (VSS is a dependency of the vss
backend only, so it was used from a temporary probe, not from the library or
the tests): for every scalar value U+0000..U+10FFFF outside the surrogates,
the generated simple lower and upper mappings and the full lower and upper
mappings equal VSS's `Get_Simple_Lowercase_Mapping`,
`Get_Simple_Uppercase_Mapping`, `Get_Lowercase_Mapping` and
`Get_Uppercase_Mapping`; and the standard `Full_Map` equals VSS's
`To_Lowercase` and `To_Uppercase` transforms on a set of strings that
includes word-final, initial and isolated capital sigma. That found no
differences after the table sort in the generator was fixed.
