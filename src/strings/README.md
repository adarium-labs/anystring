# Aclida String Abstraction

This directory contains alternative string type implementations for Aclida.

## Overview

Aclida uses a generic string abstraction that allows users to choose their preferred string representation at compile time. By default, Aclida uses `Ada.Strings.Unbounded.Unbounded_String`.

## Quick Start

Set the `ACLIDA_STRING_TYPE` environment variable before building:

```bash
# Use standard Unbounded_String (default)
alr build

# Use UXStrings (requires uxstrings dependency)
ACLIDA_STRING_TYPE=uxstring alr build

# Use a custom implementation
ACLIDA_STRING_TYPE=custom ACLIDA_STRING_PATH=/path/to/my/strings alr build
```

## Status of Implementations

| Type | Status | Notes |
|------|--------|-------|
| `standard` | ✅ Ready | Default, uses `Unbounded_String` |
| `uxstring` | ✅ Ready | Full Unicode support, requires `uxstrings` dependency |
| `wide_string` | 🚧 Template | Requires framework changes for full support |
| `wide_wide_string` | 🚧 Template | Requires framework changes for full support |
| `custom` | ✅ Ready | Specify path via `ACLIDA_STRING_PATH` |

> **Note**: Wide_String and Wide_Wide_String templates are provided but require
> additional framework changes because some internal code uses Character literals.

## Architecture

The string abstraction consists of three layers:

1. **`Aclida.Strings`** - Generic signature package defining all required string operations
2. **`Aclida.*_Operations`** - Operations package providing implementations for a specific string type
3. **`Aclida.*_Strings`** - Instantiation of `Aclida.Strings` with the operations
4. **`Aclida.String_Types`** - Configuration package that re-exports from the chosen instantiation

## Available String Types

### Default: Unbounded_String (src/)

- **Type**: `Ada.Strings.Unbounded.Unbounded_String`
- **Character Type**: `Character`
- **Files**: `aclida-standard_string_operations.ads/adb`, `aclida-standard_strings.ads`
- **Notes**: UTF-8 encoded, Length/Element operate on bytes

### UXStrings (src/strings/uxstring/)

- **Type**: `UXStrings.UXString`
- **Character Type**: `UXStrings.Unicode_Character`
- **Files**: `aclida-uxstring_operations.ads/adb`, `aclida-uxstrings.ads`
- **Notes**: Full Unicode support, Length/Element operate on code points
- **Dependency**: Requires UXStrings library

## How to Use a Different String Type

### Method 1: GPR Source Directory Override

Add the alternative string type directory to your GPR file's Source_Dirs:

```gpr
project My_App is
   for Source_Dirs use ("src", "../aclida/src/strings/uxstring");
end My_App;
```

The alternative `aclida-string_types.ads` in the uxstring directory will override the default one.

### Method 2: Create Your Own Implementation

1. Create an operations package (like `Aclida.My_String_Operations`) that implements all required functions
2. Create an instantiation of `Aclida.Strings` with your operations
3. Create an `Aclida.String_Types` package that re-exports from your instantiation
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
- `To_String_Type(String) -> String_Type` (from Latin-1/UTF-8)
- `To_Latin_1(String_Type) -> String` (to Latin-1/UTF-8)

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

1. Create `src/strings/vss/aclida-vss_operations.ads` with all required operations
2. Create `src/strings/vss/aclida-vss_strings.ads` instantiating `Aclida.Strings`
3. Create `src/strings/vss/aclida-string_types.ads` re-exporting from VSS instantiation
4. Use GPR to select: `for Source_Dirs use ("src", "src/strings/vss")`
