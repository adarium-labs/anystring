# Anystrings String Abstraction

This directory contains alternative string type implementations for Anystrings.

## Overview

Anystrings uses a generic string abstraction that allows users to choose a preferred string representation at compile time. By default, it uses `Ada.Strings.Unbounded.Unbounded_String`.

## Quick Start

Set the `STRING_TYPE` environment variable before building:

```bash
# Use standard Unbounded_String (default)
alr build

# Use UXStrings (requires uxstrings dependency)
STRING_TYPE=uxstring alr build

# Select how wide / wide_wide environment names and values are encoded
STRING_TYPE=wide_string ANYSTRING_WIDE_ENV_ENCODING=latin_1 alr build

# Use a custom implementation
STRING_TYPE=custom STRING_PATH=/path/to/my/strings alr build
```

## Status of Implementations

| Type | Status | Notes |
|------|--------|-------|
| `standard` | ✅ Ready | Default, uses `Unbounded_String` |
| `uxstring` | ✅ Ready | Full Unicode support, requires `uxstrings` dependency |
| `wide_string` | ✅ Ready | Uses `Wide_Character` and builds as a selectable variant |
| `wide_wide_string` | ✅ Ready | Uses `Wide_Wide_Character` and builds as a selectable variant |
| `custom` | ✅ Ready | Specify path via `STRING_PATH` |

For `wide_string` and `wide_wide_string`, environment operations are selected at build time through
`ANYSTRING_WIDE_ENV_ENCODING`. Supported values are `utf_8` (default) and `latin_1`.

## Architecture

The string abstraction consists of three layers:

1. **`Anystrings`** - Generic signature package defining all required string operations
2. **`*_Operations`** - Operations package providing implementations for a specific string type
3. **`*_Strings`** - Instantiation of `Anystrings` with the operations
4. **`String_Types`** - Configuration package that re-exports from the chosen instantiation

## Available String Types

### Default: Unbounded_String (src/)

- **Type**: `Ada.Strings.Unbounded.Unbounded_String`
- **Character Type**: `Character`
- **Files**: `standard_string_operations.ads/adb`, `standard_strings.ads`
- **Notes**: UTF-8 encoded, Length/Element operate on bytes

### UXStrings (src/strings/uxstring/)

- **Type**: `UXStrings.UXString`
- **Character Type**: `UXStrings.Unicode_Character`
- **Files**: `uxstring_operations.ads/adb`, `uxstrings.ads`
- **Notes**: Full Unicode support, Length/Element operate on code points
- **Dependency**: Requires UXStrings library

## How to Use a Different String Type

### Method 1: GPR Source Directory Override

Add the alternative string type directory to your GPR file's Source_Dirs:

```gpr
project My_App is
   for Source_Dirs use ("src", "../anystrings/src/strings/uxstring");
end My_App;
```

The alternative `string_types.ads` in the selected implementation directory overrides the default one.

### Method 2: Create Your Own Implementation

1. Create an operations package that implements all required functions
2. Create an instantiation of `Anystrings` with those operations
3. Create a `String_Types` package that re-exports from that instantiation
4. Use GPR to include your implementation directory

## Required Operations

To implement a new string type, you must provide these operations:

### Core Operations
- `Length(Source) -> Natural`
- `Is_Empty(Source) -> Boolean`
- `Element(Source, Index) -> Character_Type`
- `Concat_Strings(Left, Right) -> String_Type`
- `Concat_String_Character(Left, Right) -> String_Type`
- `Concat_Character_String(Left, Right) -> String_Type`

### Comparison Operations
- `"="`, `"<"`, `"<="`, `">"`, `">="` for String_Type

### Conversion Operations
- `To_String_Type(String) -> String_Type` (from Latin-1)
- `To_Latin_1(String_Type) -> String` (to Latin-1, replacing non-Latin-1 code points as needed)

### Extended Operations
- `Hash(Key) -> Hash_Type`
- `Slice(Source, Low, High) -> String_Type`
- `Index(Source, Pattern) -> Natural`
- `Index_Latin_1(Source, Pattern : String) -> Natural`
- `To_Lower(Source) -> String_Type`
- `To_Upper(Source) -> String_Type`
- `Starts_With(Source, Prefix) -> Boolean`
- `Starts_With_Latin_1(Source, Prefix : String) -> Boolean`
- `Ends_With(Source, Suffix) -> Boolean`
- `Trim(Source) -> String_Type`
- `From_Character(C) -> String_Type`

### Latin-1 Concatenation
- `Concat_String_Latin_1(String_Type, String) -> String_Type`
- `Concat_Latin_1_String(String, String_Type) -> String_Type`

## Example: Adding VSS Support

To add support for VSS (Virtual String Subsystem):

1. Create `src/strings/vss/vss_operations.ads` with all required operations
2. Create `src/strings/vss/vss_strings.ads` instantiating `Anystrings`
3. Create `src/strings/vss/string_types.ads` re-exporting from the VSS instantiation
4. Use GPR to select: `for Source_Dirs use ("src", "src/strings/vss")`
