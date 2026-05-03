# src/strings — Backend Implementations

Four interchangeable instantiations of the `Anystrings` generic. Exactly **one** is included in the build, selected by `STRING_TYPE` in the parent GPR. See root `AGENTS.md` for build commands and the contract location.

## STRUCTURE
```
strings/
├── README.md                  # user-facing doc on backend swapping (keep in sync with this file)
├── standard/                  # Ada.Strings.Unbounded.Unbounded_String  (default)
├── wide_string/               # Ada.Strings.Wide_Unbounded
├── wide_wide_string/          # Ada.Strings.Wide_Wide_Unbounded
└── uxstring/                  # UXStrings.UXString (external crate)
```

## THE 3-FILE PATTERN (every backend must follow)
| File | Role | Must export |
|------|------|-------------|
| `<v>_operations.ads/adb` | concrete impls of every formal subprogram of `Anystrings` | the underlying `<v>_String` type, `Null_<v>_String`, all 30+ ops |
| `<v>_strings.ads` | `package <V>_Strings is new Anystrings (...);` | nothing else; pure instantiation |
| `string_types.ads` | user-facing facade; **package name is identical across all four dirs** | `String_Type`, `Character_Type`, `Empty_String`, all renames + `"&"` overloads |

The package name collision on `string_types.ads` is intentional — it's how directory swap selects a backend without consumer-side changes.

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

## NOTES
- `Length` and `Element` semantics differ across backends: bytes in `standard`, `Wide_Character` slots in `wide_string`, `Wide_Wide_Character` slots in `wide_wide_string`, **Unicode code points** in `uxstring`. Document this in any new backend's header comment.
- Adding a 5th backend? Update three places: new `src/strings/<name>/` dir with 3 files, new branch in the GPR `String_Type_Choice` case, status row in `README.md`.
