# Proof boundaries: length contracts on `String_Types`

The `String_Types` facade (`src/strings/<backend>/string_types.ads`) carries
length contracts so that a SPARK client can prove, for example,
`Length (A & B) = Length (A) + Length (B)` and the absence of overflow in `&`.
This page records what GNATprove proves, what is trusted, and what is not
claimed.

`tools/prove.sh` runs two GNATprove projects per backend: the library
(`anystrings.gpr`) and a proof-only SPARK client (`proof/prove_client.gpr`).
Both use `--no-subprojects`, so dependency crates are never analysed.

## Contracts

| Declaration | Contract |
|-------------|----------|
| `Length (Source)` | `Global => null` |
| `Is_Empty (Source)` | `Post => Is_Empty'Result = (Length (Source) = 0)` |
| `"&"` String & String | `Pre => Length (Right) <= Natural'Last - Length (Left)`; `Post => Length ("&"'Result) = Length (Left) + Length (Right)` |
| `"&"` String & Character, Character & String | `Pre => Length < Natural'Last`; `Post` adds 1 |
| `"&"` String & String (Latin-1), String & String_Type | `Pre` and `Post` in terms of `'Length` of the Latin-1 operand |
| `Concat`, `Append_Character`, `Prepend_Character` | same as the `"&"` overloads they wrap |
| `Append (Source, New_Item)` (new) | `Pre => Length (New_Item) <= Natural'Last - Length (Source)`; `Post => Length (Source) = Length (Source'Old) + Length (New_Item)` |
| `Slice (Source, Low, High)` | `Pre => Low - 1 <= Length (Source) and then High <= Length (Source)`; `Post => Length (Slice'Result) = (if High < Low then 0 else High - Low + 1)` |
| `To_String_Type (Source : String)` | standard, wide_string, wide_wide_string, vss: `Post => Length (To_String_Type'Result) = Source'Length`. uxstring: the same equality, **conditional** on ASCII input (see below) |
| `To_Latin_1 (Source)` | `Post => To_Latin_1'Result'First = 1 and then To_Latin_1'Result'Length = Length (Source)` (wide_string, wide_wide_string, vss only, see below) |

### Asymmetry: `To_String_Type` on uxstring

`UXStrings.From_UTF_8` decodes UTF-8. A Latin-1 byte above 0x7F is not one
code point, so the unconditional equality is false on uxstring. The uxstring
declaration therefore carries

```ada
Post =>
  (if (for all C of Source => Character'Pos (C) < 128)
   then Length (To_String_Type'Result) = Source'Length);
```

Standard, wide_string, wide_wide_string and vss keep the unconditional
equality: their ingress maps each Latin-1 byte to one unit.

## Proof status

Both projects were proved with `--mode=all --level=2 --checks-as-errors=on`.

| Backend | Library: checks / unproved | Client: checks / unproved | Notes |
|---------|----------------------------|---------------------------|-------|
| `standard` | 80 / 0 | 109 / 0 | Bodies SPARK On, proved from `Ada.Strings.Unbounded` contracts |
| `wide_string` | 20 / 0 | 49 / 0 | Off bodies: spec-level checks only |
| `wide_wide_string` | 20 / 0 | 49 / 0 | Off bodies: spec-level checks only |
| `vss` | 10 / 0 | 42 / 0 | Off bodies and OS-boundary units, see below |
| `uxstring` | aborts | aborts | Blocked: see "uxstring blocker" |

## uxstring blocker

GNATprove cannot be run to completion on the uxstring backend without
changing the dependency crate or the facade's type.

```
uxstrings1.ads:44:58: error: function associated to aspect Iterable with dependency on globals is not allowed in SPARK
   44 |     Iterable          => (First => First, Next => Next, Has_Element => Has_Element, Element => Element),
  delayed type aspect on "UXString" is required to be in SPARK
```

With-chain. `UXStrings.UXString` is a tagged private type whose `Iterable`
functions read globals. In `--mode=all` any SPARK-On unit that mentions the
type (even `subtype S is UXStrings.UXString;` alone) makes gnatprove require
that delayed aspect to be SPARK. The facade `string_types.ads` must mention
`String_Type` in its contracts, so it is on the chain. The SPARK-Off
experiments that were tried (facade, `UXString_Operations`, all uxstring
children) did not remove the message; `--mode=check` is clean.

Options, none taken here:
1. Upstream fix in `uxstrings` (make the `Iterable` functions SPARK-legal). The
   crate must not be modified here.
2. Change `String_Type` on uxstring to a private type. That breaks the
   identical-interface rule, and a tagged-type derivation then needs
   primitive overrides ("type must be declared abstract or "Set"
   overridden").
3. Keep uxstring SPARK Off at the facade. The contracts would then be
   unusable from SPARK clients on this backend.

## Off units (trusted, checked at run time)

The following are `SPARK_Mode => Off`. Their contracts are declared in SPARK
specifications and are trusted, not proved. The test suite
(`tests/src/length_contracts_test.adb`) is built with `-gnata`, so the Pre/Post
of these bodies are evaluated at run time.

Length-contract bodies:
- `wide_string/string_types.adb`
- `wide_wide_string/string_types.adb`
- `uxstring/string_types.adb`
- `vss/string_types.adb`

OS-boundary units (not part of the length surface; SPARK Off so their
access-type globals do not enter the analysis; vss only):
- `vss/vss_text_io.ads`, `vss/vss_environment.ads`, `vss/vss_command_line.ads`
- `vss/string_types-text_io.ads`, `vss/string_types-environment.ads`,
  `vss/string_types-command_line.ads`, `vss/string_types-directories.ads`

Declarations marked `SPARK_Mode => Off` on the specification (vss only):
`From_Wide_Wide_String_With_Substitute`, `From_Wide_Wide_String_Policy`,
`Index_From (Pattern : String)`, `Replace` (two `String` overloads). They
use VSS types with access-type globals. No client may rely on them in SPARK.

## Not claimed

- **`To_String_Type` equality on non-ASCII input for uxstring.** See the
  asymmetry above: the Post is conditional on ASCII.
- **`To_Latin_1` length on standard and uxstring.** Standard `To_Latin_1`
  decodes UTF-8 and writes `?` for code points above U+00FF. uxstring
  `To_String` falls back to UTF-8 when Latin-1 conversion fails. Neither
  preserves the length, so neither backend gets the `Post`.
- **Length units.** `Length` counts bytes on `standard`, Wide_Character
  slots on `wide_string`, Wide_Wide_Character slots on `wide_wide_string`,
  code points on `uxstring` and `vss`. The contracts make no character-count
  promise.
- **`Length (Empty_String) = 0` is not provable by a SPARK client.** The
  constant is initialised from a non-static aggregate. The GNAT runtime
  declares `Ada.Strings.Unbounded.Length` with no postcondition, so
  `Length (Null_Unbounded_String) = 0` is also unprovable (gnatprove:
  `medium: assertion might fail`). The AUnit test checks it at run time only.
  Making it provable needs `Empty_String` to become a function with a
  postcondition, which changes the public surface.
- **Generic `Anystrings`.** The generic signature (`src/anystrings.ads`) is
  unchanged. Its formals carry no contracts.
