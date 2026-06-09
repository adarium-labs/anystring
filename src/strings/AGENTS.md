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
| `<v>_operations.ads/adb` | concrete impls of every formal subprogram of `Anystrings` | the underlying `<v>_String` type, `Null_<v>_String`, all 40+ ops including the 12 character-classification primitives (`Char_Is_Alphanumeric`, `Char_Is_Control`, `Char_Is_Digit`, `Char_Is_Graphic`, `Char_Is_Hex_Digit`, `Char_Is_Letter`, `Char_Is_Line_Terminator`, `Char_Is_Lower`, `Char_Is_Upper`, `Char_Is_Whitespace`, `Char_To_Lower`, `Char_To_Upper`) and the substring-search primitives (`Index_From`, `Index_Reverse`) |
| `<v>_strings.ads` | `package <V>_Strings is new Anystrings (...);` | nothing else; pure instantiation. The character predicates must be wired through the formal names `Is_Alphanumeric`, `Is_Control`, `Is_Digit`, `Is_Graphic`, `Is_Hex_Digit`, `Is_Letter`, `Is_Line_Terminator`, `Is_Lower`, `Is_Upper`, `Is_Whitespace`, `Char_To_Lower`, `Char_To_Upper` — note that the character-level `Char_To_Lower`/`Char_To_Upper` formals are deliberately named distinctly from the existing string-level `To_Lower`/`To_Upper` to keep named instantiation unambiguous. `Index_From` and `Index_Reverse` are also wired here. |
| `string_types.ads` | user-facing facade; **package name is identical across all four dirs** | `String_Type`, `Character_Type`, `Empty_String`, all renames + `"&"` overloads. Re-exports character predicates under their unadorned names (`Is_Digit`, `Is_Letter`, …), overloads `To_Lower`/`To_Upper` on `Character_Type`, and exposes `Index_From`, `Index_Reverse`, `Replace`, `Head`, `Tail` plus their `Standard.String` Latin-1 overloads (`Index_From (S, String, Pos)`, `Replace (S, String, By)`, `Replace (S, P, String)`). |

The package name collision on `string_types.ads` is intentional — it's how directory swap selects a backend without consumer-side changes.

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

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Spec of a formal subprogram | `../anystrings.ads` (root) |
| Reference impl for a new backend | `standard/standard_string_operations.adb` |
| Unicode-code-point semantics example | `uxstring/uxstring_operations.adb` |
| Wide-character conversion gotchas | `wide_wide_string/wide_wide_string_operations.adb` (most recent fix lives here) |

## CONVENTIONS (specific to this layer)
- Operation packages declare a **subtype/rename** of the underlying string type (e.g. `subtype Unbounded_String is Ada.Strings.Unbounded.Unbounded_String;`) so the instantiation file reads cleanly.
- `string_types.ads` uses `renames` aggressively — no new logic lives there. The only inline expression functions allowed are `Is_Equals_Sign` / `Is_Dash` because they collapse trivially per character type.
- `"&"` is **only** declared in `string_types.ads`, never in the operations package, to keep the generic signature free of operator pollution.

## ANTI-PATTERNS
- **Do not** rename the package in `string_types.ads` — it must stay `String_Types` in every backend, otherwise the directory-swap mechanism breaks.
- **Do not** put backend-specific extras (e.g. UXString-only methods) in `string_types.ads`. If you need them, add a **separate** package alongside; keep the four `String_Types` interfaces identical.
- **Do not** introduce a runtime backend selector (tagged dispatch, variant record). The whole point is build-time swap with zero runtime cost.
- **Do not** forget `Index_Latin_1`, `Starts_With_Latin_1`, `Concat_String_Latin_1`, `Concat_Latin_1_String` when adding a backend — these exist so consumers can pass plain `String` literals without a conversion call.
- **Do not** re-implement `Replace`, `Head`, `Tail` per backend — they live in the `Anystrings` generic body and are derived from the formals `Index_From`, `Length`, `Slice`, `Concat_Strings`, and `Concat_String_Character`. Each backend only needs to provide `Index_From` and `Index_Reverse`.

## NOTES
- `Length` and `Element` semantics differ across backends: bytes in `standard`, `Wide_Character` slots in `wide_string`, `Wide_Wide_Character` slots in `wide_wide_string`, **Unicode code points** in `uxstring`. Document this in any new backend's header comment.
- Adding a 5th backend? Update three places: new `src/strings/<name>/` dir with 3 files, new branch in the GPR `String_Type_Choice` case, status row in `README.md`.
