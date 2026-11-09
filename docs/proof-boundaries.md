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
| `uxstring` | 18 / 0 | 43 / 0 | `String_Type` is a private wrapper, see "uxstring: private wrapper type" |

## uxstring: private wrapper type

`UXStrings.UXString` cannot be mentioned by any SPARK-On unit. GNATprove
(`--mode=all`, the 15.1 default) aborts with

```
uxstrings1.ads:44:58: error: function associated to aspect Iterable with dependency on globals is not allowed in SPARK
   44 |     Iterable          => (First => First, Next => Next, Has_Element => Has_Element, Element => Element),
  delayed type aspect on "UXString" is required to be in SPARK
```

Cause. `UXStrings.UXString` is declared in a package that has no SPARK
annotations (`uxstrings1.ads`). The functions named in its `Iterable` aspect
(`First`, `Next`, `Has_Element`, `Element`) therefore get a conservative
"reads globals" contract, and SPARK requires the delayed `Iterable` aspect of a
type visible in SPARK to be globals-free. Even
`subtype S is UXStrings.UXString;` in a SPARK-On unit triggers it;
`--mode=check` does not report it. The crate must not be modified here.

What fixes it, and why it is not hiding anything. On uxstring `String_Type` is a
private type; its full view (a record holding a `UXStrings.UXString`) is in the
`SPARK_Mode => Off` private part of `String_Types`. SPARK clients see an
abstract private type plus the declared contracts, and never see
`UXStrings.UXString`. This is the same trust model as the other backends'
Off bodies: the contracts are declared in SPARK, the implementation is outside
SPARK, and the tests (built with `-gnata`) check the contracts at run time.

Units that mention `UXStrings.UXString` and are therefore `SPARK_Mode => Off`
(a leading `pragma SPARK_Mode (Off);` on the instance units, an aspect on the
others):
- `uxstring_operations.ads`, `uxstring_strings.ads` (the `Anystrings`
  instance), `uxstring_utf_8_results.ads`, `uxstring_wws_decode_results.ads`
  (result instances), `uxstring_utf_8_bridge.ads`, `uxstring_wws_bridge.ads`
- the OS-boundary units `uxstring_environment.ads`, `uxstring_text_io.ads`,
  `uxstring_command_line.ads`, `uxstring_directories.ads`, `uxstring_width.ads`

Checked by removal, one at a time: the pragma on `uxstring_operations.ads`, on each of the three instance units, and on the two bridges (both together) is needed; without it gnatprove aborts with the message above. The OS-boundary units were not minimised individually.

### Public API difference on the uxstring backend

`String_Type` is no longer `subtype String_Type is UXStrings.UXString`.
Consumers of `String_Types` that stay on its surface are unaffected. These
stop compiling and must go through `String_Types`:

| Before (uxstring only) | Now |
|------------------------|-----|
| passing a `String_Type` to a `UXStrings` subprogram | `To_UTF_8` / `To_Wide_Wide_String` and rebuild, or use the `String_Types` operation |
| `for C of S loop` over a `String_Type` | `for I in 1 .. Length (S) loop ... Element (S, I)` |
| `S (I)` (Constant_Indexing) | `Element (S, I)` |
| a string literal `"abc"` as a `String_Type` | `To_String_Type ("abc")` |
| `UTF_8_Decode_Result` / `WWS_Decode_Result` as plain records | private; use `Is_Ok`, `Get_Value`, `Get_Value_Or`, `Get_Error` |
| `Env_Processor` / `Env_Filter` callbacks taking a `UXString` | same names, callbacks take `String_Types.String_Type` |
| `String_Types.Width.Grapheme.Slice`, `Width_Slice_Result.Result` of type `UXString` | same fields, now `String_Type` |

`String_Types.Command_Line`, `.Directories`, `.Environment`, `.Text_IO` and
`.Width` are now thin wrappers (real declarations plus bodies) instead of
renames, for the same reason. Their specs are `SPARK_Mode => Off`.

The other four backends are unchanged. The interface-identity rule between
`string_types.ads` files therefore holds for the operation set and signatures
in terms of `String_Type`, but not for the representation of `String_Type`
(a private type on uxstring, a concrete type elsewhere).

## Off units (trusted, checked at run time)

The following are `SPARK_Mode => Off`. Their contracts are declared in SPARK
specifications and are trusted, not proved. The test suite
(`tests/src/length_contracts_test.adb`) is built with `-gnata`, so the Pre/Post
of these bodies are evaluated at run time.

Length-contract bodies:
- `wide_string/string_types.adb`
- `wide_wide_string/string_types.adb`
- `uxstring/string_types.adb` (every operation of the facade: unwrap, call the
  `UXStrings`-typed implementation, wrap)
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
