# anystrings

A generic Ada string-abstraction library. Write your code against one
facade — `String_Types` — and pick the underlying string representation
(`Ada.Strings.Unbounded`, `Wide_Unbounded`, `Wide_Wide_Unbounded`,
`UXStrings.UXString`, or `VSS.Strings.Virtual_String`) at **build time**
via the `STRING_TYPE` environment variable. Zero runtime cost; no tagged
dispatch.

- License: **Apache-2.0 WITH LLVM-exception**
- Alire crate: **`anystrings`** (`0.3.0-dev`)
- SPARK: signature package `Anystrings` is `SPARK_Mode On`; the
  OS-touching child packages are not.

## Why

Production Ada code is split between codebases that use `Unbounded_String`,
codebases that use `UXString` for code-point indexing, codebases that need
`Wide_Wide_Character`, and codebases that need VSS's grapheme story. Each
choice is the right one in some context and the wrong one in another.
`anystrings` lets a library be parameterised over the choice so the
**library consumer** picks, without touching the library source.

## Supported backends

| `STRING_TYPE` value | Underlying type                                 | `Length` / `Element` counts          |
|---------------------|-------------------------------------------------|--------------------------------------|
| `standard` (default)| `Ada.Strings.Unbounded.Unbounded_String`        | **UTF-8 bytes**                      |
| `wide_string`       | `Ada.Strings.Wide_Unbounded` (`Wide_Character`) | `Wide_Character` **code units**      |
| `wide_wide_string`  | `Ada.Strings.Wide_Wide_Unbounded`               | `Wide_Wide_Character` **slots**      |
| `uxstring`          | `UXStrings.UXString`                            | **Unicode code points**              |
| `vss`               | `VSS.Strings.Virtual_String`                    | **Unicode code points**              |
| `custom`            | your own backend at `STRING_PATH`               | up to you                            |

⚠️ The four columns count **different things**. See
[`docs/text-model.md`](docs/text-model.md) before indexing or slicing.

## Install

Via [Alire](https://alire.ada.dev):

```bash
alr with anystrings
```

The default build uses `STRING_TYPE=standard` and pulls only what
`Ada.Strings.Unbounded` needs. `uxstring` and `vss` builds also pull
`uxstrings ~0.9` and `vss_text ~26` respectively.

## Quick start

`anystrings` exposes a strings-only facade `String_Types`, plus four
opt-in child packages for OS-touching addons.

```ada
with String_Types;                use String_Types;
with String_Types.Command_Line;   use String_Types.Command_Line;
with String_Types.Environment;    use String_Types.Environment;
with String_Types.Text_IO;        use String_Types.Text_IO;

procedure Hello is
   Name : String_Type := Empty_String;
begin
   if Argument_Count >= 1 then
      Name := Argument (1);
   elsif Env_Exists (To_String_Type ("USER")) then
      Name := Get_Env (To_String_Type ("USER"));
   else
      Name := To_String_Type ("world");
   end if;

   Put_Line (To_String_Type ("hello, ") & Name);
end Hello;
```

Build it under different backends without touching the source:

```bash
alr build                          # standard backend
STRING_TYPE=uxstring         alr build
STRING_TYPE=wide_string      alr build
STRING_TYPE=wide_wide_string alr build
STRING_TYPE=vss              alr build
```

The wide backends also accept `ANYSTRING_WIDE_ENV_ENCODING={utf_8,latin_1}`
to control how environment-variable names and values are encoded across the
OS boundary (`utf_8` default).

## Public surface — what each `with` gives you

Since the **FACADE-SPLIT** refactor (`docs/tech-specs/facade-split.md`), the
strings facade is strings-only. OS-touching addons live in Ada **child
packages** of `String_Types` — each is independently opt-in via its own
`with` clause.

| Package                     | What's in it                                                       |
|-----------------------------|--------------------------------------------------------------------|
| `String_Types`              | `String_Type`, `Character_Type`, `Empty_String`, comparison & concat operators, conversion (`To_String_Type`, `To_Latin_1`, `To_UTF_8`, `From_UTF_8` with `UTF_8_Decode_Result`), character classifiers (`Is_Digit`, `Is_Letter`, …), case mapping, substring search & replace, prefix/suffix predicates, hashing |
| `String_Types.Command_Line` | `Argument_Count`, `Argument`, `Command_Name`, `Exit_Status` subtype, `Success`/`Failure` constants, `Set_Exit_Status` |
| `String_Types.Environment`  | `Get_Env`, `Set_Env`, `Env_Exists`, `Clear_Env`, `Iterate_Env`, plus the filter/processor access types |
| `String_Types.Directories`  | `Exists`, `Kind`, `Create_Directory`, `Delete_File`, `Rename`, plus `File_Kind` subtype and `Directory`/`Ordinary_File`/`Special_File` constants — TOTAL by contract (`NFR-DIR-001`): no exceptions cross the boundary |
| `String_Types.Text_IO`      | `File_Type`, `File_Mode`, `Create`, `Open`, `Close`, `Put`, `Put_Line`, `Get_Line`, `New_Line`, `End_Of_File`, `Is_Open`, plus the `In_File`/`Out_File`/`Append_File` mode constants |
| `String_Types.Width`        | `Display_Width`, `Grapheme_Count`, iterable `Graphemes`, cluster-indexed `Cluster_Element`/`Cluster_Slice`/`Cluster_Head`/`Cluster_Tail`, and width-budget helpers `Head_By_Width`/`Truncate_With_Ellipsis`/`Pad_To_Width`. Opt-in via `ANYSTRING_WITH_WIDTH=true` (UMWI is LGPL-3.0-or-later; the default Apache-only build never pulls it in). |

You only pay (in compile time and dependency closure) for the surfaces you
`with` in.

## Facade-isolation guarantee

A unit whose context clause is `with String_Types;` alone — without any of
the four child packages — **does not** pull `Ada.Command_Line`,
`Ada.Environment_Variables`, `Ada.Directories`, `Ada.Text_IO`,
`Ada.Wide_Text_IO`, or `Ada.Wide_Wide_Text_IO` into its semantic dependence
closure. This is enforced as a contract:

- `FUNC-FACADE-004` (`Ada.Command_Line` isolation)
- `NFR-FACADE-002` (the other five OS units)

The witness is `examples/src/anystrings_facade_isolation.adb` — a one-liner
whose only `with` is `String_Types`. The runner
`examples/run_all_backends_demo.sh` builds it under every backend and
greps the resulting `.ali` closure for any of the forbidden unit names; it
fails the run if any leak is detected.

To pull a given OS surface, opt in explicitly:

```ada
with String_Types.Environment;  use String_Types.Environment;
```

## Backend-native text model — read before indexing

> ⚠️ `Length`, `Element`, and `Slice` on a `String_Type` are
> **backend-native**. They count UTF-8 **bytes** on `standard`,
> **`Wide_Character` code units** on `wide_string`, **`Wide_Wide_Character`
> slots** on `wide_wide_string`, and **Unicode code points** on
> `uxstring` and `vss`. None of the backends count graphemes, terminal
> cells, or UTF-8 bytes uniformly.

Before indexing, slicing, or comparing lengths in code expected to run
against more than one backend, read **[`docs/text-model.md`](docs/text-model.md)**.
It gives the full per-backend table, the portable byte-budget pattern via
`To_UTF_8`, and a catalogue of common mistakes.

If you need portable byte budgets, route through the UTF-8 boundary:

```ada
if Length (To_UTF_8 (S)) > 80 then     --  portable: bytes on every backend
   ...
end if;
```

The UTF-8 boundary API (`Anystrings_UTF_8` + `Anystrings_UTF_8_Results`)
lives in `src/anystrings_utf_8.ads` and `src/anystrings_utf_8_results.ads`.
Each backend re-exports `To_UTF_8` and `From_UTF_8` (with a discriminated
`UTF_8_Decode_Result`) through `string_types.ads`.

## Examples

The `examples/` directory is its own Alire crate (path-pinned to `..`):

```bash
cd examples
alr run                                # picks up the default standard build
STRING_TYPE=uxstring  alr build && alr run
```

Notable demos:

| File                                                | What it shows                                                 |
|-----------------------------------------------------|---------------------------------------------------------------|
| `anystrings_examples.adb`                           | End-to-end: I/O, environment, character classification        |
| `anystrings_cmdline_demo.adb`                       | `argv` round-trip through `String_Types.Command_Line`         |
| `anystrings_filesystem_demo.adb`                    | `String_Types.Directories` boundary                           |
| `anystrings_utf_8_demo.adb`                         | `To_UTF_8` / `From_UTF_8` with the result discriminator       |
| `anystrings_env_encoding_regression.adb`            | `ANYSTRING_WIDE_ENV_ENCODING` UTF-8 vs Latin-1                |
| `anystrings_facade_isolation.adb`                   | `with String_Types;`-only — the facade-isolation witness      |

The full validation run (build × every backend, plus the isolation grep)
is:

```bash
bash examples/run_all_backends_demo.sh
```

Expected tail: `ALL-BACKENDS-PASS`, with one `FACADE-ISOLATION PASS` per
backend.

## Tests

The `tests/` directory contains the cross-backend test suite:

```bash
cd tests && bash ./run_all_backends.sh
```

Expected tail: `ALL BACKENDS: PASS`.

## Architecture

The four layers, top-down:

1. **`Anystrings`** (`src/anystrings.ads`) — generic signature package.
   Declares the formal subprograms each backend must supply (`Length`,
   `Element`, `Slice`, `Concat_Strings`, character classifiers, the UTF-8
   boundary types, …). `SPARK_Mode On`.
2. **`<prefix>_String_Operations`** — per-backend concrete
   implementations (`src/strings/<backend>/<prefix>_string_operations.{ads,adb}`).
3. **`<Prefix>_Strings`** — instantiation of `Anystrings` with the
   operations package (`<prefix>_strings.ads`).
4. **`String_Types`** + its four child packages — the user-facing facade
   (`src/strings/<backend>/string_types*.ads`). Pure renames; no logic.

The package name `String_Types` is **identical** in every backend
directory — that is how `STRING_TYPE` is a pure source-directory swap with
zero consumer-side change. The same parity rule applies to the four child
packages: their left-hand sides are byte-identical across backends; only
the rename targets on the right-hand side differ.

For the per-backend implementation details (the 3-file pattern, character
classification semantics, filesystem-boundary path encoding, anti-patterns,
how to add a backend), see [`src/strings/README.md`](src/strings/README.md)
and [`src/strings/AGENTS.md`](src/strings/AGENTS.md).

## Further documentation

| Topic                                        | File                                             |
|----------------------------------------------|--------------------------------------------------|
| Backend-native text model (`Length` etc.)    | [`docs/text-model.md`](docs/text-model.md)       |
| Facade-split design (Layer 1 + Layer 2)      | `docs/tech-specs/facade-split.md`                |
| UTF-8 boundary API design                    | `docs/tech-specs/utf8-boundary-api.md`           |
| Conversion semantics (Latin-1, UTF-8)        | `docs/tech-specs/conv-semantics.md`              |
| Filesystem boundary contract                 | `docs/tech-specs/filesystem-boundary.md`         |
| Command-line bridge                          | `docs/tech-specs/cmdline-access.md`              |
| Functional + non-functional requirements     | `docs/requirements/*.sdoc`                       |
| Per-backend agent notes                      | `src/strings/AGENTS.md`                          |
| Roadmap                                      | `.opencode/roadmap.json` (use `tools/roadmap.ts`)|

## Contributing

This is an early-stage crate. The roadmap lives at
`.opencode/roadmap.json` and is navigated via
`deno run -A tools/roadmap.ts {next,show,list,…}`.

If you add or rework a backend, the parity invariant is non-negotiable:
all five backends must ship the same `String_Types*` left-hand sides, and
the full validation gate
(`examples/run_all_backends_demo.sh` + `tests/run_all_backends.sh`) must
print `ALL-BACKENDS-PASS` / `ALL BACKENDS: PASS`.

## License

Apache-2.0 WITH LLVM-exception. See `alire.toml`.
