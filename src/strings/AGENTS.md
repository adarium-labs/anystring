# src/strings — Backend Implementations

Five interchangeable instantiations of the `Anystrings` generic. Exactly **one** is included in the build, selected by `STRING_TYPE` in the parent GPR. See root `AGENTS.md` for build commands and the contract location.

## STRUCTURE
```
strings/
├── README.md                  # user-facing doc on backend swapping (keep in sync with this file)
├── standard/                  # Ada.Strings.Unbounded.Unbounded_String  (default)
├── wide_string/               # Ada.Strings.Wide_Unbounded
├── wide_wide_string/          # Ada.Strings.Wide_Wide_Unbounded
├── uxstring/                  # UXStrings.UXString (external crate)
└── vss/                       # VSS.Strings.Virtual_String (external crate vss_text)
```

## THE 3-FILE PATTERN (every backend must follow)
| File | Role | Must export |
|------|------|-------------|
| `<v>_operations.ads/adb` | concrete impls of every formal subprogram of `Anystrings` | the underlying `<v>_String` type, `Null_<v>_String`, all 40+ ops including the 12 character-classification primitives (`Char_Is_Alphanumeric`, `Char_Is_Control`, `Char_Is_Digit`, `Char_Is_Graphic`, `Char_Is_Hex_Digit`, `Char_Is_Letter`, `Char_Is_Line_Terminator`, `Char_Is_Lower`, `Char_Is_Upper`, `Char_Is_Whitespace`, `Char_To_Lower`, `Char_To_Upper`), the substring-search primitives (`Index_From`, `Index_Reverse`), and the filesystem-boundary primitives (`File_Kind` enum, `Path_Exists`, `Path_Kind`, `Create_Directory_Path`, `Delete_File_Path`, `Rename_Path`) |
| `<v>_strings.ads` | `package <V>_Strings is new Anystrings (...);` | nothing else; pure instantiation. The character predicates must be wired through the formal names `Is_Alphanumeric`, `Is_Control`, `Is_Digit`, `Is_Graphic`, `Is_Hex_Digit`, `Is_Letter`, `Is_Line_Terminator`, `Is_Lower`, `Is_Upper`, `Is_Whitespace`, `Char_To_Lower`, `Char_To_Upper` — note that the character-level `Char_To_Lower`/`Char_To_Upper` formals are deliberately named distinctly from the existing string-level `To_Lower`/`To_Upper` to keep named instantiation unambiguous. `Index_From` and `Index_Reverse` are also wired here. The filesystem actuals (`File_Kind` actual type plus `Path_Exists`, `Path_Kind`, `Create_Directory_Path`, `Delete_File_Path`, `Rename_Path`) are passed in the same instantiation. |
| `string_types.ads` | user-facing facade; **package name is identical across all four dirs** | `String_Type`, `Character_Type`, `Empty_String`, all renames + `"&"` overloads. Re-exports character predicates under their unadorned names (`Is_Digit`, `Is_Letter`, …), overloads `To_Lower`/`To_Upper` on `Character_Type`, exposes `Index_From`, `Index_Reverse`, `Replace`, `Head`, `Tail` plus their `Standard.String` Latin-1 overloads (`Index_From (S, String, Pos)`, `Replace (S, String, By)`, `Replace (S, P, String)`). Filesystem boundary: re-exports the `File_Kind` subtype, the three named constants (`Directory`, `Ordinary_File`, `Special_File`), and the five filesystem subprograms (`Exists`, `Kind`, `Create_Directory`, `Delete_File`, `Rename`) — all five total: they never propagate exceptions across this boundary. |

The package name collision on `string_types.ads` is intentional — it's how directory swap selects a backend without consumer-side changes.

### Exception: `uxstring` has a private `String_Type`

On the other four backends `String_Type` is a concrete type (`subtype` of the underlying string). On `uxstring` it is a **private type** declared in `UXString_Wrapper` (not in `String_Types`: `Empty_String` must be a constant, see `docs/proof-boundaries.md`), whose full view, a record holding a `UXStrings.UXString`, sits in a `SPARK_Mode => Off` private part. `UXStrings.UXString` has an `Iterable` aspect whose functions read globals, which GNATprove rejects in any SPARK-On unit that mentions the type; hiding it behind the private type is what lets SPARK clients use the length contracts on this backend (see `docs/proof-boundaries.md`).

Consequences for this layer:
- `uxstring/string_types.ads` has real declarations for every operation (no renames of `UXString`-typed subprograms) and `string_types.adb` (SPARK Off) has the bodies: unwrap with `UXString_Wrapper.Convert.To_UXString`, call `UXString_Operations` / `UXString_Strings`, wrap with `From_UXString`. The operation set and signatures in terms of `String_Type` are still identical to the other backends.
- `UTF_8_Decode_Result` and `WWS_Decode_Result` are private on uxstring too (they hold a `String_Type`); use `Is_Ok` / `Get_Value` / `Get_Value_Or` / `Get_Error`.
- The children `String_Types.Command_Line`, `.Directories`, `.Environment`, `.Text_IO`, `.Width` are wrappers with bodies, because the full view is not visible outside `UXString_Wrapper`; their bodies convert through `UXString_Wrapper.Convert`. Their specs are `SPARK_Mode => Off`.
- Every unit that mentions `UXStrings.UXString` (`uxstring_operations`, the `UXString_Strings` / result instances, the bridges, the OS-boundary units) must be `SPARK_Mode => Off`, otherwise `tools/prove.sh` aborts with the `Iterable` error. A leading `pragma SPARK_Mode (Off);` is how the instance units are marked.
- Consumers on this backend must not use `UXStrings` operations, string literals, indexing or `for ... of` on a `String_Type`; go through `String_Types` (`To_String_Type`, `Element`, `Length`, ...).

### Character classification & case-mapping semantics

The 12 character-level primitives have backend-specific behaviour because each backend's `Character_Type` has a different range:

| Backend | `Character_Type` | Predicate source | `Is_Whitespace` | `Is_Line_Terminator` |
|---------|------------------|------------------|-----------------|----------------------|
| `standard` | `Character` (0..255) | `Ada.Characters.Handling` | ASCII SP/HT/LF/VT/FF/CR | LF, CR only |
| `wide_string` | `Wide_Character` (0..U+FFFF) | `Ada.Wide_Characters.Handling` | ASCII SP/HT/LF/VT/FF/CR | LF, CR only |
| `wide_wide_string` | `Wide_Wide_Character` (0..U+7FFFFFFF) | `Ada.Wide_Wide_Characters.Handling`, guarded against surrogates / non-scalar | ASCII + Unicode `Space_Separator` (via `Is_Space`) | LF, CR, NEL (U+0085), LS (U+2028), PS (U+2029) |
| `uxstring` | `Unicode_Character` (subtype of `Wide_Wide_Character`) | `Ada.Wide_Wide_Characters.Handling`, guarded | same as `wide_wide_string` | same as `wide_wide_string` |
| `vss` | `Wide_Wide_Character` | `Ada.Wide_Wide_Characters.Handling`, guarded | same as `wide_wide_string` | same as `wide_wide_string` |

Notes:

- `Is_Graphic` is not provided by `Ada.Wide_Characters.Handling` or `Ada.Wide_Wide_Characters.Handling`; the wide / wide_wide / uxstring / vss backends approximate it as `not Is_Control`.
- All wide and wide_wide based backends guard against code points outside U+0000..U+10FFFF and the UTF-16 surrogate range U+D800..U+DFFF. Classifiers return `False` for these; `Char_To_Lower` / `Char_To_Upper` return the input unchanged. This is required because `Ada.Wide_Wide_Characters.Handling` raises `Constraint_Error` on non-scalar arguments.
- `standard` cannot classify code points > U+00FF (e.g. Arabic-Indic digits, Greek capitals); attempting to construct such a `Character` value raises `Constraint_Error` at construction time.
- `wide_string` *can* classify Unicode code points in the BMP via `Ada.Wide_Characters.Handling`, but is treated as ASCII-only for `Is_Whitespace` and `Is_Line_Terminator` by contract, for symmetry with `standard`.
- `Simple_To_Lower` (not a generic formal; declared in each `string_types.ads` with `Post => Length (Simple_To_Lower'Result) = Length (Source)`, trusted because the bodies are SPARK Off) maps one code point to one code point with the UCD Simple_Lowercase_Mapping, from the generated table `src/anystrings_ucd_case.adb` (UCD 15.1.0, see `tools/ucd/README.md`) through the shared unit `src/anystrings_simple_case.adb`. Every backend uses that unit, because the GNAT tables behind `Ada.Wide_Wide_Characters.Handling.To_Lower` miss U+0130 and U+1E9E. The string-level `To_Lower` / `To_Upper` use the full mapping (table below). On `standard`, `Length` counts bytes, so a mapping whose UTF-8 length differs is not applied and the code point is kept unchanged. Those are the 25 code points below (Unicode 15.1 simple lower-case mappings, checked against the library's table on every scalar value U+0080..U+10FFFF). The rule: the two forms fall in different UTF-8 length classes (1 byte < U+0080 ≤ 2 bytes < U+0800 ≤ 3 bytes < U+10000 ≤ 4 bytes).

| Code point | Name | Simple lower | Bytes |
|---|---|---|---|
| U+0130 | LATIN CAPITAL LETTER I WITH DOT ABOVE | U+0069 | 2 → 1 |
| U+023A | LATIN CAPITAL LETTER A WITH STROKE | U+2C65 | 2 → 3 |
| U+023E | LATIN CAPITAL LETTER T WITH DIAGONAL STROKE | U+2C66 | 2 → 3 |
| U+1E9E | LATIN CAPITAL LETTER SHARP S | U+00DF | 3 → 2 |
| U+2126 | OHM SIGN | U+03C9 | 3 → 2 |
| U+212A | KELVIN SIGN | U+006B | 3 → 1 |
| U+212B | ANGSTROM SIGN | U+00E5 | 3 → 2 |
| U+2C62 | LATIN CAPITAL LETTER L WITH MIDDLE TILDE | U+026B | 3 → 2 |
| U+2C64 | LATIN CAPITAL LETTER R WITH TAIL | U+027D | 3 → 2 |
| U+2C6D | LATIN CAPITAL LETTER ALPHA | U+0251 | 3 → 2 |
| U+2C6E | LATIN CAPITAL LETTER M WITH HOOK | U+0271 | 3 → 2 |
| U+2C6F | LATIN CAPITAL LETTER TURNED A | U+0250 | 3 → 2 |
| U+2C70 | LATIN CAPITAL LETTER TURNED ALPHA | U+0252 | 3 → 2 |
| U+2C7E | LATIN CAPITAL LETTER S WITH SWASH TAIL | U+023F | 3 → 2 |
| U+2C7F | LATIN CAPITAL LETTER Z WITH SWASH TAIL | U+0240 | 3 → 2 |
| U+A78D | LATIN CAPITAL LETTER TURNED H | U+0265 | 3 → 2 |
| U+A7AA | LATIN CAPITAL LETTER H WITH HOOK | U+0266 | 3 → 2 |
| U+A7AB | LATIN CAPITAL LETTER REVERSED OPEN E | U+025C | 3 → 2 |
| U+A7AC | LATIN CAPITAL LETTER SCRIPT G | U+0261 | 3 → 2 |
| U+A7AD | LATIN CAPITAL LETTER L WITH BELT | U+026C | 3 → 2 |
| U+A7AE | LATIN CAPITAL LETTER SMALL CAPITAL I | U+026A | 3 → 2 |
| U+A7B0 | LATIN CAPITAL LETTER TURNED K | U+029E | 3 → 2 |
| U+A7B1 | LATIN CAPITAL LETTER TURNED T | U+0287 | 3 → 2 |
| U+A7B2 | LATIN CAPITAL LETTER J WITH CROSSED-TAIL | U+029D | 3 → 2 |
| U+A7C5 | LATIN CAPITAL LETTER S WITH HOOK | U+0282 | 3 → 2 |

`To_Lower` and `To_Upper` are the full Unicode case mapping on every backend: the UnicodeData simple mappings, the unconditional SpecialCasing entries and the Final_Sigma rule (Unicode §3.13). All five backends call the same code, `Anystrings_Simple_Case.Full_Map`, on the same generated tables, so they return the same code points for the same text. The mapping changes byte length on `standard` (U+0130 lower-cases to U+0069 U+0307, 2 → 3 bytes; U+00DF upper-cases to `SS`), so `To_Lower` / `To_Upper` have no `Length` postcondition.

Only the way each backend reads the code points differs:

| Backend | Code points read from storage | Ill-formed storage |
|---|---|---|
| `standard` | UTF-8 bytes; each maximal run of well-formed sequences is mapped on its own (Final_Sigma context stays inside the run) | an ill-formed sequence is copied unchanged and ends the run; byte length may change only in mapped runs |
| `wide_string` | UTF-16 code units: a surrogate pair is one code point (via `To_Wide_Wide_String`) | a lone surrogate reads as U+FFFD, as in `To_UTF_8` |
| `wide_wide_string` | one code point per `Wide_Wide_Character` | a value that is not a scalar value is copied unchanged |
| `uxstring` | code points (`To_Wide_Wide_String`), mapped and rebuilt; no new dependency | none (UXString stores scalar values only) |
| `vss` | code points (`To_Wide_Wide_String`), mapped and rebuilt; `VSS.Transformers.Casing` is no longer used | none (VSS stores scalar values only) |

Length of the mapping (contract). `Full_Lower_Length (S)` and `Full_Upper_Length (S)` give the length of `To_Lower (S)` and `To_Upper (S)` in the backend's `Length` unit, without building the result. They are computed in two passes (count, then fill an exactly sized buffer), in `Long_Long_Integer`, so no size is over-allocated and no sum can overflow. The facade states the contract:

- `To_Lower` / `To_Upper`: `Pre => Full_Lower_Length (Source) <= Long_Long_Integer (Natural'Last)` (resp. Upper), and `Post => Length (To_Lower'Result) = Natural (Full_Lower_Length (Source))`.
- The precondition is not clamped and there is no exception path: a string whose mapping would be longer than `Natural'Last` is outside the contract.
- The bodies are SPARK Off, so the contract is trusted there (as `Simple_To_Lower`); `pragma Assume` is not used.

| Backend | Length unit of `Full_*_Length` and `Length` |
|---|---|
| `standard` | UTF-8 bytes |
| `wide_string` | UTF-16 code units |
| `wide_wide_string`, `uxstring`, `vss` | code points |

Character level (case predicates and mapping). On `standard` a `Character` is one byte of UTF-8, so `Char_Is_Lower`, `Char_Is_Upper`, `Char_To_Lower` and `Char_To_Upper` are ASCII only: a byte ≥ 16#80# is neither lower nor upper case and is returned unchanged by the mapping, so the lead byte of U+00C9 (C3) is never altered or taken for a letter case.

| Backend | `Is_Lower` / `Is_Upper` | `Char_To_Lower` / `Char_To_Upper` |
|---|---|---|
| `standard` | ASCII a–z / A–Z only; bytes ≥ 16#80# are neither | ASCII only; bytes ≥ 16#80# unchanged |
| `wide_string` | `Ada.Wide_Characters.Handling` (GNAT tables) | `Ada.Wide_Characters.Handling` (GNAT tables) |
| `wide_wide_string`, `uxstring`, `vss` | `Ada.Wide_Wide_Characters.Handling`, guarded against non-scalars | same tables, guarded |

`Char_Is_Letter` and `Char_Is_Alphanumeric` on `standard` still use the Latin-1 letter categories of `Ada.Characters.Handling`. They are letter categories, not case, so this change leaves them alone.

### Unicode case data and dependencies

The case tables are generated, not hand-written: `src/anystrings_ucd_case.ads/.adb` from the UCD 15.1.0 files vendored in `tools/ucd/data/15.1.0`. Regenerate with `alr exec -- tools/ucd/regenerate.sh` (or `tools/ucd/regenerate.sh` when `gprbuild` is on PATH); the output is deterministic, so `git diff --exit-code` on the two files is clean for unchanged data. Changing the Unicode version is described in `tools/ucd/README.md`. Do not edit the generated files. The shared case code (`src/anystrings_simple_case.adb`) uses only these tables.

Which external crate each backend's library closure reaches (checked from the ALI dependency records of the library build):

| Backend | VSS in the closure | Other external crate |
|---|---|---|
| `standard` | no | none |
| `wide_string` | no | none |
| `wide_wide_string` | no | none |
| `uxstring` | no | `uxstrings` |
| `vss` | yes (its operations use `VSS.Strings`; `To_Lower`/`To_Upper` use the generated tables) | `vss_text` |

`alire.toml` still declares `vss_text` and `uxstrings` as dependencies, because the `vss` and `uxstring` backends need them. The default `standard` build therefore links neither.

### Filesystem boundary path encoding

The five filesystem operations (`Exists`, `Kind`, `Create_Directory`, `Delete_File`, `Rename`) accept `String_Type` paths and hand them to `Ada.Directories` as `Standard.String`. Each backend converts the path with the SAME encoding helper it uses for environment variables and command-line arguments, so the same byte-stream invariants apply:

| Backend | Path encoding helper | Egress bytes |
|---------|---------------------|--------------|
| `standard` | `Ada.Strings.Unbounded.To_String` | byte-identity (storage is UTF-8 per FUNC-CONV-001) |
| `wide_string` | private `To_UTF_8` in `wide_string_operations.adb` | UTF-8 |
| `wide_wide_string` | private `To_UTF_8` in `wide_wide_string_operations.adb` | UTF-8 |
| `uxstring` | `UXString_Operations.To_UTF_8` (fully-qualified to disambiguate from `UXStrings.To_UTF_8`) | UTF-8 |
| `vss` | private `To_UTF_8_String` in `vss_operations.adb` | UTF-8 |

There is no decode boundary for these operations — they only return `Boolean` / `File_Kind`, never paths back. The five operations are TOTAL by contract (NFR-DIR-001): any runtime error (`Name_Error`, `Use_Error`, `Status_Error`, anything else) is absorbed and translated into `False` / `Special_File` returns. Behaviour is specified for POSIX filesystems only (NFR-DIR-004); Windows path quirks are out of scope.

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Spec of a formal subprogram | `../anystrings.ads` (root) |
| Reference impl for a new backend | `standard/standard_string_operations.adb` |
| Unicode-code-point semantics example | `uxstring/uxstring_operations.adb` |
| Wide-character conversion gotchas | `wide_wide_string/wide_wide_string_operations.adb` (most recent fix lives here) |

## CONVENTIONS (specific to this layer)
- Operation packages declare a **subtype/rename** of the underlying string type (e.g. `subtype Unbounded_String is Ada.Strings.Unbounded.Unbounded_String;`) so the instantiation file reads cleanly.
- `string_types.ads` uses `renames` aggressively (except on `uxstring`, where each operation is a real declaration with a wrapper body, see above) — no new logic lives there. The only inline expression functions allowed are `Is_Equals_Sign` / `Is_Dash` because they collapse trivially per character type.
- `"&"` is **only** declared in `string_types.ads`, never in the operations package, to keep the generic signature free of operator pollution.

## ANTI-PATTERNS
- **Do not** rename the package in `string_types.ads` — it must stay `String_Types` in every backend, otherwise the directory-swap mechanism breaks.
- **Do not** put backend-specific extras (e.g. UXString-only methods) in `string_types.ads`. If you need them, add a **separate** package alongside; keep the four `String_Types` interfaces identical.
- **Do** expose OS-touching addon surfaces (cmdline, environment, directories, Text_IO) through Ada **child packages** of `String_Types` — e.g. `string_types-command_line.ads` (the source file uses a hyphen per Ada's filename convention; the Ada package is `String_Types.Command_Line`). This is the carve-out introduced by the FACADE-SPLIT (Layer 1) refactor (see `docs/tech-specs/facade-split.md`). The parity invariant extends to children: every backend MUST ship the same child specs with identical left-hand-side signatures; only the rename targets on the right-hand side differ.
- **Do not** introduce a runtime backend selector (tagged dispatch, variant record). The whole point is build-time swap with zero runtime cost.
- **Do not** forget `Index_Latin_1`, `Starts_With_Latin_1`, `Concat_String_Latin_1`, `Concat_Latin_1_String` when adding a backend — these exist so consumers can pass plain `String` literals without a conversion call.
- **Do not** re-implement `Replace`, `Head`, `Tail` per backend — they live in the `Anystrings` generic body and are derived from the formals `Index_From`, `Length`, `Slice`, `Concat_Strings`, and `Concat_String_Character`. Each backend only needs to provide `Index_From` and `Index_Reverse`.

## NOTES
- `Length` and `Element` semantics differ across backends: bytes in `standard`, `Wide_Character` slots in `wide_string`, `Wide_Wide_Character` slots in `wide_wide_string`, **Unicode code points** in `uxstring`. Document this in any new backend's header comment.
- Adding a 5th backend? Update three places: new `src/strings/<name>/` dir with 3 files, new branch in the GPR `String_Type_Choice` case, status row in `README.md`.
