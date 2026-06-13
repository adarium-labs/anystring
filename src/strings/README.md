# `src/strings/` — Backend Implementations

This directory holds the five interchangeable backend instantiations of the
`Anystrings` generic and the build-time-selected `String_Types` facade. Exactly
one backend is included in the build, chosen by `STRING_TYPE` (see root
`README.md`).

For agent-facing notes (what each file must export, anti-patterns, parity
rules), see `AGENTS.md` in this directory.

## Quick start

```bash
# Standard backend — Ada.Strings.Unbounded.Unbounded_String (default)
alr build

# UXStrings — full Unicode (Unicode_Character code points); pulls the uxstrings crate
STRING_TYPE=uxstring alr build

# Wide_Character / Wide_Wide_Character (BMP / full Unicode)
STRING_TYPE=wide_string alr build
STRING_TYPE=wide_wide_string alr build

# VSS Virtual_String — full Unicode; pulls the vss_text crate
STRING_TYPE=vss alr build

# Override how environment-variable names/values are encoded on the wide backends
STRING_TYPE=wide_string ANYSTRING_WIDE_ENV_ENCODING=latin_1 alr build

# Custom backend
STRING_TYPE=custom STRING_PATH=/abs/path/to/my/strings alr build
```

## Status of implementations

| Type               | Status   | Notes                                                                       |
|--------------------|----------|-----------------------------------------------------------------------------|
| `standard`         | Ready    | Default; `Unbounded_String`; `Length`/`Element` operate on **UTF-8 bytes**  |
| `wide_string`      | Ready    | `Wide_Character` code units; BMP only                                       |
| `wide_wide_string` | Ready    | `Wide_Wide_Character` slots; full Unicode                                   |
| `uxstring`         | Ready    | Full Unicode; `Length`/`Element` operate on **code points**; pulls `uxstrings` |
| `vss`              | Ready    | Full Unicode via `VSS.Strings.Virtual_String`; pulls `vss_text`             |
| `custom`           | Ready    | Pick your own directory via `STRING_PATH`                                   |

For `wide_string` and `wide_wide_string`, the environment-variable boundary
encoding is selected at build time via `ANYSTRING_WIDE_ENV_ENCODING`. Allowed
values: `utf_8` (default) and `latin_1`.

## Public surface — what each backend exposes

Since the **FACADE-SPLIT** refactor (Layer 1 + Layer 2), the four OS-touching
addons live in Ada **child packages** of `String_Types`. The strings facade
itself stays strings-only; the addons are opt-in.

| Package                       | What it carries                                                  | Source file in each backend dir   |
|-------------------------------|------------------------------------------------------------------|-----------------------------------|
| `String_Types`                | `String_Type`, `Character_Type`, `Empty_String`, all string ops, UTF-8 boundary types, conversion helpers, character classifiers | `string_types.ads`                |
| `String_Types.Command_Line`   | `Argument_Count`, `Argument`, `Command_Name`, `Exit_Status`, `Set_Exit_Status` | `string_types-command_line.ads`   |
| `String_Types.Environment`    | `Get_Env`, `Set_Env`, `Env_Exists`, `Clear_Env`, `Iterate_Env`, plus filter/processor access types | `string_types-environment.ads`    |
| `String_Types.Directories`    | `Exists`, `Kind`, `Create_Directory`, `Delete_File`, `Rename`, `File_Kind` subtype and constants | `string_types-directories.ads`    |
| `String_Types.Text_IO`        | `File_Type`, `File_Mode`, `Create`, `Open`, `Close`, `Put`, `Put_Line`, `Get_Line`, `End_Of_File`, `New_Line`, `Is_Open` | `string_types-text_io.ads`        |
| `String_Types.Width`          | `Display_Width`, `Grapheme_Count`, iterable `Graphemes`, cluster-indexed `Cluster_Element`/`Cluster_Slice`/`Cluster_Head`/`Cluster_Tail`, width-budget helpers `Head_By_Width`/`Truncate_With_Ellipsis`/`Pad_To_Width`. Opt-in via `ANYSTRING_WITH_WIDTH=true` (UMWI is LGPL-3.0-or-later). | `string_types-width.ads`          |

Every backend directory ships all five files. The left-hand sides of the
child specs are **byte-identical** across backends; only the rename targets
on the right-hand side differ (`Standard_Command_Line`, `Wide_Command_Line`,
…). This is the parity invariant — `FUNC-FACADE-003` and friends — that keeps
`STRING_TYPE` a pure directory swap.

## Consumption pattern

Users opt in to exactly the surfaces they need:

```ada
with String_Types;                use String_Types;
with String_Types.Environment;    use String_Types.Environment;
with String_Types.Text_IO;        use String_Types.Text_IO;

procedure My_Tool is
   S : constant String_Type := To_String_Type ("hello");
   F : File_Type;
begin
   Put_Line (S);
   if Env_Exists (To_String_Type ("HOME")) then
      ...
   end if;
end My_Tool;
```

A unit whose context clause is `with String_Types;` alone gets only the
strings surface — no command-line, no environment, no directories, no
Text_IO. The OS units (`Ada.Command_Line`, `Ada.Environment_Variables`,
`Ada.Directories`, `Ada.Text_IO`, `Ada.Wide_Text_IO`, `Ada.Wide_Wide_Text_IO`)
are **not** in the semantic dependence closure.

## Facade-isolation guarantee

Requirements `FUNC-FACADE-004` (cmdline) and `NFR-FACADE-002` (env / dirs /
Text_IO) make this a hard contract:

> A user compilation unit whose context clause is `with String_Types;` alone
> SHALL NOT have `Ada.Command_Line`, `Ada.Environment_Variables`,
> `Ada.Directories`, `Ada.Text_IO`, `Ada.Wide_Text_IO`, or
> `Ada.Wide_Wide_Text_IO` in its semantic dependence closure.

The witness is built and verified on every backend by
`examples/run_all_backends_demo.sh`, which compiles
`examples/src/anystrings_facade_isolation.adb` (a one-liner whose only context
clause is `with String_Types;`) and greps the resulting `.ali` file for any
forbidden unit name. The script prints `FACADE-ISOLATION PASS` per backend.

## Backend-native text model — read before indexing

> ⚠️ **`Length`, `Element`, and `Slice` on a `String_Type` are backend-native.**
> They count **bytes** on `standard`, **`Wide_Character` code units** on
> `wide_string`, **`Wide_Wide_Character` slots** on `wide_wide_string`, and
> **Unicode code points** on `uxstring` and `vss`. None of the backends
> count graphemes, terminal cells, or UTF-8 bytes uniformly.

Before you index, slice, or compare lengths in code that may run against
more than one backend, read **`docs/text-model.md`**. It gives the full
per-backend table, the portable byte-budget pattern via `To_UTF_8`, and a
list of common mistakes.

## Architecture

The facade is built in four layers:

1. **`Anystrings`** — generic signature package (`src/anystrings.ads`).
   Defines the formal subprograms each backend must supply (e.g. `Length`,
   `Element`, `Slice`, `Concat_Strings`, the character classifiers).
2. **`<prefix>_String_Operations`** — concrete implementations of those
   formals for a single backend (`src/strings/<backend>/<prefix>_string_operations.{ads,adb}`).
3. **`<Prefix>_Strings`** — instantiation of `Anystrings` with the
   operations package (`<prefix>_strings.ads`).
4. **`String_Types`** + child packages — the user-facing facade
   (`string_types.ads` and `string_types-{command_line,environment,directories,text_io}.ads`).
   Pure renames; no logic. The child packages are the result of the
   FACADE-SPLIT refactor (Layer 1 / Layer 2; see
   `docs/tech-specs/facade-split.md`).

The package name `String_Types` is identical across all backend dirs by
design — that is how `STRING_TYPE` is a pure directory swap with zero
consumer-side change.

## How to use a different string type (consumer side)

### Method 1 — `STRING_TYPE` environment variable

When building this crate (or any consumer that pins to it via Alire), set
`STRING_TYPE` to one of `standard`, `wide_string`, `wide_wide_string`,
`uxstring`, `vss`, or `custom`. The parent `anystrings.gpr` selects the
matching `src/strings/<dir>/` source directory.

### Method 2 — GPR `Source_Dirs` override in your own project

If you vendor or fork the crate, add the desired backend dir to
`Source_Dirs`:

```gpr
project My_App is
   for Source_Dirs use ("src", "../anystrings/src/strings/uxstring");
end My_App;
```

The backend's `string_types.ads` is now the one that shows up to your code.

## Adding a sixth backend

Add three files in a new `src/strings/<name>/` directory (plus the four
child-package spec files):

1. `<name>_string_operations.{ads,adb}` — implementations of every formal in
   `src/anystrings.ads`. Use `standard/standard_string_operations.adb` as the
   reference implementation.
2. `<name>_strings.ads` — `package <Name>_Strings is new Anystrings (...);`.
   Pure instantiation, no logic.
3. `string_types.ads` — package name MUST be `String_Types` (not
   `<Name>_String_Types`). Re-export everything the other backends re-export;
   the LHS must match byte-for-byte.
4. `string_types-{command_line,environment,directories,text_io}.ads` — child
   facades. Same parity rule: LHS byte-identical to the other backends; only
   rename targets differ.
5. Plus the per-addon implementation packages
   (`<name>_command_line`, `<name>_environment`, `<name>_directories`,
   `<name>_text_io`, `<name>_utf_8_bridge`, `<name>_utf_8_results`).

Then add a `when "<name>" => ...` branch to the `String_Type_Choice` case in
the root `anystrings.gpr`, and a status row in this README.

Run the full validation gate before declaring it done:

```bash
bash examples/run_all_backends_demo.sh   # includes facade-isolation grep
( cd tests && bash ./run_all_backends.sh )
```

Both must print `ALL-BACKENDS-PASS` / `ALL BACKENDS: PASS`.
