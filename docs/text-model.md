# Text model — what `Length`, `Element`, and `Slice` actually count

> **Audience.** Consumers of the `String_Types` facade who index into strings,
> compute lengths, or slice substrings.
> **Status.** Reference. Tracks roadmap item `UTF8-BOUNDARY-DOCS`.

## 1. The one sentence you must remember

`Length`, `Element`, and `Slice` on a `String_Type` are **backend-native**.
They count the underlying storage unit of whichever backend was selected at
build time. There is no shared, portable notion of "character" across backends.

This is not a bug. It is the consequence of letting consumers swap the
underlying string representation (`Unbounded_String`, `Wide_Unbounded_String`,
`Wide_Wide_Unbounded_String`, `UXString`, `VSS.Strings.Virtual_String`) without
recompilation. Each underlying type counts in its own units; the facade simply
forwards.

## 2. Per-backend semantics

The five bundled backends count different things. The table below is the
authoritative reference; the canonical source is the per-backend operations
package (e.g. `src/strings/standard/standard_string_operations.adb`) cross-checked
against `src/strings/AGENTS.md` (§ NOTES, § Character classification).

| Backend            | Underlying string type                   | `Character_Type`                    | `Length (S)` returns               | `Element (S, I)` returns           | `Slice (S, L, H)` slices  |
|--------------------|------------------------------------------|-------------------------------------|------------------------------------|------------------------------------|---------------------------|
| `standard`         | `Ada.Strings.Unbounded.Unbounded_String` | `Character` (0..255, Latin-1)       | **bytes** (UTF-8 storage)          | i-th **byte** as `Character`       | byte range                |
| `wide_string`      | `Ada.Strings.Wide_Unbounded`             | `Wide_Character` (0..U+FFFF)        | **`Wide_Character` code units**    | i-th `Wide_Character`              | `Wide_Character` range    |
| `wide_wide_string` | `Ada.Strings.Wide_Wide_Unbounded`        | `Wide_Wide_Character` (0..U+10FFFF) | **`Wide_Wide_Character` slots**    | i-th `Wide_Wide_Character`         | `Wide_Wide_Character` rng |
| `uxstring`         | `UXStrings.UXString`                     | `Unicode_Character`                 | **Unicode code points**            | i-th **code point**                | code-point range          |
| `vss`              | `VSS.Strings.Virtual_String`             | `Wide_Wide_Character`               | **Unicode code points**            | i-th **code point**                | code-point range          |

Notes:

- The `standard` backend stores text as UTF-8 bytes (FUNC-CONV-001). `Length`
  on `"héllo"` returns **6**, not 5, because `é` is 2 UTF-8 bytes (`C3 A9`).
  `Element (S, 2)` returns the byte `0xC3`, which is not a printable Latin-1
  character on its own.
- The `wide_string` backend cannot represent code points above U+FFFF in a
  single `Wide_Character`; UTF-8 input above the BMP fails to decode (see
  `Code_Point_Out_Of_Range` in `src/anystrings_utf_8.ads`).
- The `wide_wide_string`, `uxstring`, and `vss` backends count whole Unicode
  scalars; they all return **5** for `Length ("héllo")`.

## 3. What `Length` does NOT count — uniformly across backends

None of the backends count any of the following uniformly:

- **Graphemes.** `"e\u{0301}"` (`e` + combining acute) is one grapheme but two
  code points; `"👨‍👩‍👧"` (family ZWJ sequence) is one grapheme but five code
  points and seventeen UTF-8 bytes. No `Length` reports 1 here.
- **Display columns / terminal cells.** East-Asian wide glyphs occupy two
  cells; combining marks occupy zero; emoji presentation toggles change
  width. `Length` is unaware of all of this.
- **UTF-8 bytes** — only `standard` counts bytes. Every other backend counts
  in its own native unit.
- **Code points** — only `uxstring` and `vss` count code points. `wide_string`
  counts UTF-16-ish code units (without surrogate-pair support, by
  construction); `wide_wide_string` counts code points only because every
  `Wide_Wide_Character` happens to map one-to-one with a scalar in its range.

## 4. Implication for portable code

If your code's correctness depends on a specific unit (bytes, code points,
graphemes), pick **one** of the strategies below — never assume the default.

### 4.1 Portable byte budget — the UTF-8 boundary

For "must fit in N UTF-8 bytes" decisions, route through the UTF-8 boundary:

```ada
if Length (To_UTF_8 (S)) > 80 then
   --  S would exceed 80 UTF-8 bytes on every backend.
   --  Length is now String's Length (bytes), not String_Type's Length.
   ...
end if;
```

`To_UTF_8` is the formal `with function To_UTF_8 (Source : String_Type) return
String;` (`src/anystrings.ads:101`); each backend re-exports it through
`string_types.ads`. The returned `Standard.String` is portable across
backends — `Length` on it is byte-counted everywhere.

### 4.2 Backend-explicit code

When you genuinely need backend-native indexing (e.g. parsing a known
ASCII-only protocol field on `standard`), keep the assumption local and
comment it:

```ada
--  standard backend only: Length counts UTF-8 bytes and the protocol
--  field is ASCII, so bytes == characters here.
if Length (S) > 80 then
   ...
end if;
```

A reader switching the build to a wide backend will see this comment and
know the assumption no longer holds.

### 4.3 Grapheme-stable iteration

`Length` / `Element` / `Slice` are not grapheme-stable on any backend. If
you need grapheme clusters:

1. Pick the `vss` backend and use VSS's grapheme-cluster iteration (separate
   from `String_Types`; see `vss_text` upstream).
2. Or, opt in to `String_Types.Width` (`ANYSTRING_WITH_WIDTH=true`), which
   exposes UMWI-backed `Display_Width`, `Grapheme_Count`, iterable
   `Graphemes`, cluster-indexed `Cluster_Element`/`Cluster_Slice`/`Cluster_Head`/
   `Cluster_Tail`, and the width-budget helpers `Head_By_Width`,
   `Truncate_With_Ellipsis`, `Pad_To_Width` (FUNC-WIDTH-003 .. FUNC-WIDTH-016).
   The child package is opt-in because UMWI is LGPL-3.0-or-later, so the
   default Apache-only build never pulls it in (NFR-WIDTH-002).

## 5. The UTF-8 boundary API — the safe portable layer

When you need to exchange text between backends, persist it, or feed it to
external tools, use the UTF-8 boundary. It is the only API on this library
whose semantics are identical across backends.

- `src/anystrings_utf_8.ads` — closed enum `UTF_8_Decode_Error` (six failure
  categories per RFC 3629).
- `src/anystrings_utf_8_results.ads` — generic discriminated record
  `UTF_8_Decode_Result` with `Is_Ok`, `Get_Value`, `Get_Error`,
  `Get_Value_Or`.
- Each backend re-exports both through `string_types.ads`:
  - `function To_UTF_8 (Source : String_Type) return String;` — encode, total.
  - `function From_UTF_8 (Source : String) return UTF_8_Decode_Result;` —
    decode, total (no exceptions), returns a discriminated result.

The byte stream produced by `To_UTF_8` is **byte-identical** for the same
abstract text across all backends (modulo what each backend can represent —
e.g. `wide_string` cannot encode supplementary-plane code points).

## 6. Concrete portable-vs-fragile examples

### Fragile — meaning depends on the backend

```ada
declare
   S : constant String_Type := To_String_Type ("héllo");
begin
   if Length (S) > 5 then
      --  TRUE  on 'standard'         (6 UTF-8 bytes: 'h' c3 a9 'l' 'l' 'o').
      --  FALSE on 'wide_string'      (5 Wide_Character code units).
      --  FALSE on 'wide_wide_string' (5 Wide_Wide_Character slots).
      --  FALSE on 'uxstring' / 'vss' (5 Unicode code points).
      ...
   end if;
end;
```

```ada
declare
   E : constant Character_Type := Element (S, 2);
begin
   --  'standard'         : E is the byte 0xC3 (first byte of UTF-8 'é').
   --  'wide_string'      : E is 'é' (Wide_Character U+00E9).
   --  'wide_wide_string' : E is 'é' (Wide_Wide_Character U+00E9).
   --  'uxstring' / 'vss' : E is 'é' (code point U+00E9).
   ...
end;
```

### Portable — same meaning on every backend

```ada
--  Byte budget.
if Length (To_UTF_8 (S)) > 80 then
   ...
end if;

--  Equality and substring search at the String_Type level are portable:
--  they compare/index the same abstract text on every backend, even though
--  the concrete units differ.
if Starts_With (S, To_String_Type ("hé")) then
   ...
end if;

--  Round-trip via UTF-8 is portable. Length is now byte-counted.
declare
   Bytes : constant String                := To_UTF_8 (S);
   Back  : constant UTF_8_Decode_Result   := From_UTF_8 (Bytes);
begin
   if Is_Ok (Back) then
      pragma Assert (Get_Value (Back) = S);  --  always holds
   end if;
end;
```

## 7. Common mistakes

- Treating `Length (S)` as "the number of characters the user would see".
  No — it is the backend-native count. Use grapheme tooling for user-visible
  width.
- Using `Slice (S, 1, 10)` to take the "first ten characters". On `standard`
  this slices the first ten **bytes** and can split a multi-byte UTF-8
  sequence — the result may not even be valid UTF-8.
- Comparing `Length (S)` against a fixed constant in code expected to run
  on multiple backends. The constant is meaningful in **one** unit only.
- Indexing into a `standard` string and expecting a code point back. You
  get a byte. Build with `STRING_TYPE=uxstring` (or `vss`) if you need
  code-point indexing.
- Relying on `Length` to detect emptiness — prefer `Is_Empty (S)` (also
  re-exported by every `string_types.ads`); it is `O(1)` and unambiguous.

## 8. Where the per-backend behaviour lives

| Concern                           | File                                                                       |
|-----------------------------------|----------------------------------------------------------------------------|
| Generic formal `Length`/`Element`/`Slice` declarations | `src/anystrings.ads:41,47,116` |
| Per-backend `Length`/`Element`/`Slice` implementations | `src/strings/<backend>/<prefix>_string_operations.adb` |
| Backend semantics summary         | `src/strings/AGENTS.md` (§ NOTES, § Character classification)              |
| UTF-8 boundary types              | `src/anystrings_utf_8.ads`, `src/anystrings_utf_8_results.ads`             |
| Per-backend UTF-8 bridge          | `src/strings/<backend>/<prefix>_utf_8_bridge.{ads,adb}`                    |
| Facade-isolation witness program  | `examples/src/anystrings_facade_isolation.adb`                             |
| Roadmap entry                     | `UTF8-BOUNDARY-DOCS` (`.opencode/roadmap.json`)                            |

## 9. The API edge: `To_String_Type`, argv, environment, Text_IO

This section records what each back end does with the `String` that crosses
the API edge. The rules below are the decisions of 2026-11-17.

### 9.1 Ingress through the shared replacement decoder (all five back ends)

Command-line arguments, `Command_Name`, environment names and values, the
checked `From_UTF_8` and the valid lines of Text_IO are decoded with algorithm
R (`Anystrings_UTF_8_Replace`): one U+FFFD per maximal ill-formed subpart. A
leading U+FEFF is kept. No ingress path raises.

### 9.2 `To_String_Type (String)` per back end

| Back end           | Reads the `String` as                       | Ill-formed input                           |
|--------------------|---------------------------------------------|--------------------------------------------|
| `standard`         | bytes, stored as given                      | kept as bytes (`To_Wide_Wide_String` gives U+FFFD per subpart) |
| `wide_string`      | Latin-1 (one code point per byte)           | a byte above 7F is one code point          |
| `wide_wide_string` | Latin-1 (one code point per byte)           | a byte above 7F is one code point          |
| `uxstring`         | UTF-8, decoded with R (human decision)      | ill-formed subparts become U+FFFD; never raises |
| `vss`              | Latin-1 (`Latin_1_To_WWS`)                  | a byte above 7F is one code point          |

### 9.3 Cross-backend `To_String_Type` inconsistency (follow-up issue, not fixed here)

The same `String` value gives different code points on different back ends.
For example `"C3 A9"` is one code point, U+00E9, on `standard` (read as bytes
and decoded by `To_Wide_Wide_String`) and on `uxstring`, and two code points,
U+00C3 and U+00A9, on `wide_string`, `wide_wide_string` and `vss`. The API-edge
convention in `AGENTS.md` (Latin-1) is followed by the wide and vss back ends,
not by `uxstring`. Aligning the back ends is a follow-up issue; the decision
for `uxstring` is recorded here and in `AGENTS.md`.

### 9.4 Text_IO: Latin-1 fallback for invalid lines (deliberate exception)

A valid UTF-8 line read by `Get_Line` is decoded with R, so a leading U+FEFF is
kept. A line that is not valid UTF-8 is read as Latin-1 on the back ends that
decode Text_IO lines (`uxstring`, `wide_string`, `wide_wide_string`, `vss`);
`standard` keeps the bytes. This is a deliberate exception to R, for files: a
file may hold legacy Latin-1 text, and reading it as Latin-1 loses nothing.
Argv and environment do not have this exception.

### 9.5 Egress to Latin-1 on standard: malformed and overlong sequences

`To_Latin_1` and `To_Latin_1_If_Possible` decode the stored UTF-8 with algorithm R
(`Anystrings_UTF_8_Replace.Decode_Replacing`), the same decoder as
`To_Wide_Wide_String`: one U+FFFD per maximal ill-formed subpart, so decoding
resynchronises after each replacement. An overlong sequence, an encoded surrogate
and a sequence above U+10FFFF are ill-formed like any other malformed sequence. A
code point above U+00FF is written as `?`. Well-formed input is unchanged.

Example, the overlong encoding of © (U+00A9) as `E0 80 A9`:

| Bytes | Decoded as | Written by `To_Latin_1` |
|---|---|---|
| `E0` | one U+FFFD (lead of an overlong form, no valid second byte) | `?` |
| `80` | one U+FFFD (stray continuation byte) | `?` |
| `A9` | one U+FFFD (stray continuation byte) | `?` |

So `To_Latin_1` gives `???`, not the byte `A9`. `To_Latin_1_If_Possible` gives
the same string with status `Lossy` and three replacements. `F0 80 80 AF`
(overlong `/`) gives `????` in the same way.

An encoded surrogate, `ED A0 80`, gives three replacements as well, one per byte:
`ED` is a lead byte with no valid second byte (`A0` is outside `80..9F`), so it is
one U+FFFD on its own, and `A0` and `80` are stray continuation bytes. So
`To_Latin_1` gives `???`.

### 9.6 Scalar values only: every constructor and mutator

On `wide_string`, `wide_wide_string`, `uxstring` and `vss`, every public operation
that builds or changes a `String_Type` from a `Character_Type` or a `Wide_Wide_String`
stores only Unicode scalar values (U+0000..U+D7FF, U+E000..U+10FFFF). A non-scalar
value is stored as U+FFFD, the replacement of `From_Wide_Wide_String`. The policy
covers `From_Character`, `"&"` and `Append_Character` / `Prepend_Character` with a
character, and the `Head` / `Tail` padding, which appends the pad character. The replacement happens in the constructor, so no stored value holds a
surrogate or a value above U+10FFFF.

Per back end:

- `wide_wide_string` and `uxstring`: a `Character_Type` value above U+10FFFF or in
  U+D800..U+DFFF is stored as U+FFFD.
- `wide_string`: a lone surrogate is stored as U+FFFD. Characters are code units, so
  two surrogates passed one character at a time give two U+FFFD, not one code point;
  `From_Wide_Wide_String` works the same way per element.
- `vss`: already conforming (the character is converted with `To_Valid_Virtual_Character`).
- `standard`: **not covered**. A `Character` is one byte (section 9.2), and a byte at
  or above 16#80# is stored as given, so `From_Character` and `"&"` with such a byte
  can leave ill-formed UTF-8 in the storage. Replacing it with U+FFFD (three bytes)
  would break the `Length` postconditions of `Append_Character` and `Prepend_Character`
  and the byte model of `Element`. This needs a decision; it is not changed here.
  The same holds for `To_String_Type` and the Latin-1 `"&"` on `standard` (section 9.2).

The Latin-1 inputs (`To_String_Type`, `"&"` with a `String`, `Replace` with a `String`)
store only scalar values on `wide_string`, `wide_wide_string` and `vss` (they read
Latin-1 code points up to U+00FF) and on `uxstring` (UTF-8 with algorithm R, section 9.2).

## 10. Known issues

### 10.1 `Display_Width` sums cluster widths in `Natural`, unguarded (outside KI-046)

**Symptom.** `Display_Width` accumulates the per-cluster widths in a `Natural`
with no overflow guard. A string whose total display width exceeds
`Natural'Last` (2 147 483 647 cells) raises `Constraint_Error` instead of
returning a width. At 2 cells per wide cluster that takes more than about 1 G
clusters, so the string alone is several GB; it is a limit case, not a case
seen in practice.

**Affected units** (the accumulation line; same shape in each):

| Back end | Unit | Line |
|---|---|---|
| standard | `standard_width.adb` | `Total := Total + C.Width;` |
| wide_string | `wide_width.adb` | `Total := Total + C.Width;` |
| wide_wide_string | `wide_wide_width.adb` | `Total := Total + Cl.Width;` |
| uxstring | `uxstring_width.adb` | `Total := Total + Cl.Width;` |
| vss | `vss_width.adb` | `Total := Total + Cl.Width;` |

`Head_By_Width` is not affected: its accumulator never exceeds `Max_Cells`, and
its test reads `Cl.Width > Max_Cells - Acc` (changed with the KI-046 width
pass). The other width operations accumulate cluster counts or indexes, which
are bounded by the string length.

**Options.**

1. A `Pre` on `Display_Width` bounding the input length (for example
   `Length (S) <= Natural'Last / Max_Cluster_Width`), so the sum cannot
   overflow. Cheapest; moves the limit into the contract.
2. A wider result type (`Long_Long_Natural`, or a dedicated subtype). Changes
   the signature on all five `string_types-width.ads` files and every caller,
   so it must be done in one change.
3. Documented saturation at `Natural'Last`. No signature change, but callers
   can no longer tell "exactly `Natural'Last`" from "more".

**Before choosing.** Audit the per-cluster width bounds that `umwi` returns
(`Cl.Width`, today assumed to be 0, 1 or 2 in the `Grapheme` record comment in
`standard_width.ads`). The bound that option 1 relies on comes from `umwi`, so
it has to be confirmed there first (`umwi` is an external crate and is not
changed from this repository).

**Scope.** This is outside KI-046 and was not changed by it. KI-046 only made
the cluster-walk indexes and the `Head_By_Width` budget test overflow-free.

### 10.2 The width boundary fix is covered functionally, not at `Positive'Last`

The KI-046 width pass makes every cluster walk exit before it forms
`Last_Byte + 1`, which would overflow when the last cluster ends at
`Positive'Last`. The width operations take `Unbounded_*`, `UXString` and
`Virtual_String` values, whose bytes are always indexed `1 .. Length`, so no
test can put the bytes at `Positive'Last` (the decoder and UTF-16 scans take
plain `String` / `Wide_String` and do have such tests, in
`Ingress_Boundary_Test`). `Width_Clusters_Test.Test_Walks_End_At_The_Last_Cluster`
checks the exit on a string whose last cluster is multi-byte; it is functional
coverage of the exit, and does not reproduce the overflow.

## 11. Case mapping

`To_Lower` and `To_Upper` on a `String_Type` are the full Unicode case mapping
(UnicodeData simple mappings, unconditional SpecialCasing entries, and the
Final_Sigma rule of Unicode §3.13) on every backend. The result is the same code
points on `standard`, `wide_string`, `wide_wide_string`, `uxstring` and `vss`,
from the generated UCD 15.1.0 tables. The length may change (U+00DF upper-cases to `SS`; U+0130 lower-cases to U+0069 U+0307),
so the length is part of the contract: `Full_Lower_Length (S)` and `Full_Upper_Length (S)`
give the length of the result in the backend's `Length` unit (UTF-8 bytes on standard,
UTF-16 units on wide_string, code points elsewhere), and the postcondition of
`To_Lower` / `To_Upper` is `Length (To_Lower (S)) = Full_Lower_Length (S)`. The
precondition is `Full_Lower_Length (S) <= Natural'Last`; nothing is clamped.

How the code points are read depends on the storage:

- `standard` maps each maximal run of well-formed UTF-8 on its own. An ill-formed
  sequence (for example an overlong form, a surrogate or a stray continuation byte)
  is copied unchanged and ends the run, so the bytes that were not understood are
  kept.
- `wide_string` reads surrogate pairs as one code point. A lone surrogate reads as
  U+FFFD, as in `To_UTF_8`.
- `wide_wide_string` maps one code point per `Wide_Wide_Character`. A value that is
  not a scalar value is copied unchanged.
- `uxstring` and `vss` store scalar values only.

`Simple_To_Lower` maps one code point to one code point and keeps the length
(`src/strings/AGENTS.md`, the 25 code points of `standard`). On `standard` a mapping whose UTF-8 length
differs is not applied.

Character level: on `standard` a `Character` is one byte of UTF-8, so `Char_Is_Lower`,
`Char_Is_Upper`, `Char_To_Lower` and `Char_To_Upper` are ASCII only. A byte at or
above 16#80# is neither lower nor upper case and is returned unchanged by the
mapping: the lead byte C3 of U+00C9 is not turned into E3. The per-backend table is in
`src/strings/AGENTS.md`.
