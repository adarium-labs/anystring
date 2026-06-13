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
