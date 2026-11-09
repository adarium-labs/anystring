# Proof boundaries: length contracts on `String_Types`

The `String_Types` facade (`src/strings/<backend>/string_types.ads`) carries
length contracts so that a SPARK client can prove, for example,
`Length (A & B) = Length (A) + Length (B)` and the absence of overflow in `&`.
This page records what GNATprove proves, what is trusted, and what is not
claimed.

## Contracts (identical meaning on every backend)

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
| `To_String_Type (Source : String)` | `Post => Length (To_String_Type'Result) = Source'Length` (not on uxstring, see below) |
| `To_Latin_1 (Source)` | `Post => To_Latin_1'Result'First = 1 and then To_Latin_1'Result'Length = Length (Source)` (wide_string, wide_wide_string, vss only, see below) |

## Proof status

| Backend | Facade body | GNATprove on the root project | Contracts |
|---------|-------------|-------------------------------|-----------|
| `standard` | `string_types.ads` expression functions + `string_types.adb`, SPARK On | 80 checks, 0 unproved | Proved from the SPARK contracts of `Ada.Strings.Unbounded` |
| `wide_string` | `string_types.adb`, `SPARK_Mode => Off` | 20 checks, 0 unproved (spec-level only) | Trusted (see below) |
| `wide_wide_string` | `string_types.adb`, `SPARK_Mode => Off` | 20 checks, 0 unproved (spec-level only) | Trusted (see below) |
| `uxstring` | `string_types.adb`, `SPARK_Mode => Off` | aborts: `uxstrings1.ads:44:58` (dependency crate, pre-existing) | Trusted (see below) |
| `vss` | `string_types.adb`, `SPARK_Mode => Off` | aborts: `vss_text_io.ads:47:13`, `:48:13` (dependency crate, pre-existing) | Trusted (see below) |

Pre-existing aborts are the same messages as on the base commit `648d2cf`.

## Off bodies (trusted, checked at run time)

The following bodies are `SPARK_Mode => Off`. Their contracts are declared in
the SPARK-On specification and are trusted, not proved. The test suite
(`tests/src/length_contracts_test.adb`) is built with `-gnata`, so the
Pre/Post of these bodies are evaluated at run time.

- `wide_string/string_types.adb`
- `wide_wide_string/string_types.adb`
- `uxstring/string_types.adb`
- `vss/string_types.adb`

Declarations that are not SPARK-clean and carry no contract are marked
`SPARK_Mode => Off` on the specification (vss only):
`From_Wide_Wide_String_With_Substitute`, `From_Wide_Wide_String_Policy`,
`Index_From (Pattern : String)`, `Replace` (two `String` overloads). They
use `VSS` types that hold access types. No client may rely on them in SPARK.

## Not claimed

- **`To_String_Type` on uxstring.** The ingress is `UXStrings.From_UTF_8`,
  which decodes UTF-8. A Latin-1 byte above 0x7F is not one unit, so
  `Length (To_String_Type (S)) = S'Length` does not hold. `To_String_Type`
  stays a plain renaming without a `Post` on this backend.
- **`To_Latin_1` length on standard and uxstring.** Standard `To_Latin_1`
  decodes UTF-8 and writes `?` for code points above U+00FF. uxstring
  `To_String` falls back to UTF-8 when Latin-1 conversion fails. Neither
  preserves the length, so neither backend gets the `Post`. `To_Latin_1`
  stays a plain renaming there.
- **Length units.** `Length` counts bytes on `standard`, Wide_Character
  slots on `wide_string`, Wide_Wide_Character slots on `wide_wide_string`,
  code points on `uxstring` and `vss`. The contracts are stated in these
  units; they do not promise character counts.
- **`Empty_String`.** `Length (Empty_String) = 0` is not proved by a SPARK
  client in this change. The AUnit test checks it at run time only.
- **Generic `Anystrings`.** The generic signature
  (`src/anystrings.ads`) is unchanged. Its formals carry no contracts.
