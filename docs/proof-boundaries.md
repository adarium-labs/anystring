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
| `Null_String_Value` | `Global => null`; `Post => Length (Null_String_Value'Result) = 0` |
| `Empty_String` | `Empty_String : constant String_Type := Null_String_Value;` on every backend, so `Length (Empty_String) = 0` is provable. On uxstring `String_Type` and `Null_String_Value` come from `UXString_Wrapper` (see below) |
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
| `wide_wide_string` | 20 / 0 | 49 / 0 | Off bodies: spec-level checks only; `String_Type` is a private wrapper (`String_Empty_Value`, text-model section 9.6) |
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
private type declared in `UXString_Wrapper`; its full view (a record holding a
`UXStrings.UXString`) is in that package's `SPARK_Mode => Off` private part. SPARK clients see an
abstract private type plus the declared contracts, and never see
`UXStrings.UXString`. This is the same trust model as the other backends'
Off bodies: the contracts are declared in SPARK, the implementation is outside
SPARK, and the tests (built with `-gnata`) check the contracts at run time.

Why the type lives in its own package. `String_Types.Empty_String` must be a
constant. A constant of a private type cannot be initialised in the visible
part of the package that declares the type, and a deferred constant would hide
its value from SPARK. As a function (the first version of this change) it broke
consumers at run time: a record component such as
`Msg : Failure_Text := Empty_String`, with `Failure_Text` a subtype with a
`Dynamic_Predicate`, copied the function result into the component without
`Adjust` and then finalized the temporary, so the `UXString` buffer was freed
twice (`malloc(): unaligned fastbin chunk detected`, found with an
AddressSanitizer build of aclida). `UXString_Wrapper` (with `Elaborate_Body`)
declares the private type, `Length` and `Null_String_Value`;
`String_Types.Empty_String` is `constant := Null_String_Value`, like the other
backends. `UXString_Wrapper.Convert` (SPARK Off) gives the bodies of
`String_Types` and its children the conversions to and from `UXStrings.UXString`.
The regression test is `tests/src/empty_string_default_test.adb`.

Units that mention `UXStrings.UXString` and are therefore `SPARK_Mode => Off`
(a leading `pragma SPARK_Mode (Off);` on the instance units, an aspect on the
others):
- `uxstring_wrapper.ads` (private part only), `uxstring_wrapper-convert.ads`,
  `uxstring_operations.ads`, `uxstring_strings.ads` (the `Anystrings`
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
(a private type on uxstring and wide_wide_string, a concrete type on standard, wide_string and vss).

## Case mapping: arithmetic proved, glue trusted

`To_Lower` / `To_Upper` size their result in a first pass and write it in a
second (see `src/strings/AGENTS.md`). The length contract of the facade is
trusted (the facade bodies are Off), but every index, length and overflow check
behind it is proved, on every backend, by two `SPARK_Mode => On` units that
`anystrings.gpr` analyses with the rest of the library:

| Unit | What it holds | Checks proved (standard run) |
|------|---------------|------------------------------|
| `anystrings_simple_case` | `Final_Sigma`, `Map_At`, the sizes of a mapped run in code points / UTF-16 units / UTF-8 bytes, the builders `Full_Map`, `Full_Map_UTF_16`, `Put_Mapped_UTF_8` | 26 subprograms, 0 unproved |
| `anystrings_utf_8_case` | the `standard` walker: `Decode`, `Run_Last`, pieces, `Case_Length` (pass 1), `Case_Map` (pass 2), `Simple_Lower` | 12 subprograms, 0 unproved |

How the second pass is shown to stay inside the first pass's buffer. A ghost
function (`Prefix_Size` in the first unit, `Rest_Size` in the second) is the size
of the part of the mapping already written (resp. still to write). Every loop
keeps its running count equal to it, the buffer length is the whole size, and
the postcondition of the ghost function bounds each step by what is left. The
same invariant bounds every sum by `12 * N` in `Long_Long_Integer`, so no sum
overflows whatever `N <= Natural'Last` is. An index is only formed after the
test that it exists (`K < Run'Last` before `K + 1`; `Step <= S'Last - I + 1`
before `I + (Step - 1)`), so a source of `Natural'Last` elements is handled
like any other. The ghost code and the postconditions of these two units are not
executed (`Assertion_Policy (Ghost => Ignore, Post => Ignore)` in the unit): run
at `-gnata` they would make each loop quadratic or recursive. Their `Pre` is
still checked at run time.

Not proved, by design of the units around them:
- `Anystrings_UTF_8_Replace.Decode_Replacing` and `From_UTF_16` (`SPARK_Mode`
  Off bodies) state in their `Post` that every code point is at most U+10FFFF.
  The builders take that as a precondition (`Is_Valid`); the postcondition is
  trusted for the body, and the precondition is checked at run time in the tests.
- The glue bodies (`To_Lower`, `To_Upper`, `Full_*_Length`, `Simple_To_Lower` of
  each backend) convert between the backend type and `String` or
  `Wide_Wide_String`, and call the proved functions. They contain no arithmetic.
  The `Natural (Full_Lower_Length (Source))` conversion in the facade `Post` is
  part of a subprogram skipped as `body is SPARK_Mode => Off`.

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
- **Generic `Anystrings`.** The generic signature (`src/anystrings.ads`) is
  unchanged. Its formals carry no contracts.
