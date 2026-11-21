-------------------------------------------------------------------------------
--  Standard_String_Operations - Operations for Unbounded_String
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Provides operations required for instantiating Strings with
--  Ada.Strings.Unbounded.Unbounded_String.
--
--  @description
--  This package wraps Unbounded_String operations to match the signature
--  required by the Strings generic package. Note that we use
--  Unbounded_String instead of Standard.String because String is an
--  unconstrained array type which cannot be used as a generic formal
--  private type.
--
--  For UTF-8 support, string content is assumed to be UTF-8 encoded.
--  Length and Element operate on bytes (Character values), not Unicode
--  code points. For full Unicode support, use the VSS or UXStrings
--  instantiation.

with Ada.Containers;
with Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Hash;
with Ada.Characters.Handling;
with Anystrings_Conv;

package Standard_String_Operations is

   subtype Unbounded_String is Ada.Strings.Unbounded.Unbounded_String;

   ---------------------------------------------------------------------------
   --  Core Operations (required by Strings signature)
   ---------------------------------------------------------------------------

   --  Empty string constant
   Null_Unbounded_String : constant Unbounded_String := Ada.Strings.Unbounded.Null_Unbounded_String;

   --  Returns the length of the string
   function Length (Source : Unbounded_String) return Natural renames Ada.Strings.Unbounded.Length;

   --  Returns True if the string is empty
   function Is_Empty (Source : Unbounded_String) return Boolean
   is (Ada.Strings.Unbounded.Length (Source) = 0);

   --  Returns the character at position Index (1-indexed)
   function Element (Source : Unbounded_String; Index : Positive) return Character
   renames Ada.Strings.Unbounded.Element;

   --  Concatenation of two strings
   function Concat_Strings (Left : Unbounded_String; Right : Unbounded_String) return Unbounded_String
   renames Ada.Strings.Unbounded."&";

   --  Concatenation of a string and a character
   function Concat_String_Character (Left : Unbounded_String; Right : Character) return Unbounded_String
   renames Ada.Strings.Unbounded."&";

   --  Concatenation of a character and a string
   function Concat_Character_String (Left : Character; Right : Unbounded_String) return Unbounded_String
   renames Ada.Strings.Unbounded."&";

   --  Concatenation of Unbounded_String and Latin-1 String
   function Concat_String_Latin_1 (Left : Unbounded_String; Right : String) return Unbounded_String
   renames Ada.Strings.Unbounded."&";

   --  Concatenation of Latin-1 String and Unbounded_String
   function Concat_Latin_1_String (Left : String; Right : Unbounded_String) return Unbounded_String
   renames Ada.Strings.Unbounded."&";

   --  Comparison operators
   function "=" (Left, Right : Unbounded_String) return Boolean renames Ada.Strings.Unbounded."=";

   function "<" (Left, Right : Unbounded_String) return Boolean renames Ada.Strings.Unbounded."<";

   function "<=" (Left, Right : Unbounded_String) return Boolean renames Ada.Strings.Unbounded."<=";

   function ">" (Left, Right : Unbounded_String) return Boolean renames Ada.Strings.Unbounded.">";

   function ">=" (Left, Right : Unbounded_String) return Boolean renames Ada.Strings.Unbounded.">=";

   ---------------------------------------------------------------------------
   --  Conversion Operations
   ---------------------------------------------------------------------------

   --  Convert from String to Unbounded_String
   --
   --  The `standard` backend stores its bytes verbatim. By project convention
   --  (FUNC-CONV-001) the caller passes a well-formed UTF-8 byte sequence;
   --  this function is byte-identity and performs no validation.
   --  @relation FUNC-CONV-001
   function To_Unbounded_String (Source : String) return Unbounded_String
   renames Ada.Strings.Unbounded.To_Unbounded_String;

   --  Byte-identity extraction of the underlying Unbounded_String contents.
   --
   --  This is the raw-bytes accessor used internally by the operations
   --  package (Index, Trim, To_Lower, …) and bound to the `To_UTF_8` formal
   --  of the Anystrings generic instantiation (per FUNC-CONV-003: the
   --  storage is UTF-8, so emission is byte-identity).
   function To_String (Source : Unbounded_String) return String renames Ada.Strings.Unbounded.To_String;

   --  Latin-1 egress: decode UTF-8 storage then transliterate each code
   --  point to a single Latin-1 byte. Code points greater than U+00FF are
   --  replaced by the single byte '?' (16#3F#) per FUNC-CONV-006.
   --
   --  Total; never raises.
   --  @relation FUNC-CONV-006, FUNC-CONV-007
   function To_Latin_1 (Source : Unbounded_String) return String;

   --  Latin-1 egress with loss detection.
   --
   --  Same transliteration as To_Latin_1, but the returned record reports
   --  whether any code point was replaced by '?' and how many. See
   --  Anystrings_Conv.Latin_1_Conv_Result.
   --
   --  Total; never raises.
   --  @relation FUNC-CONV-008, FUNC-CONV-009
   function To_Latin_1_If_Possible
     (Source : Unbounded_String) return Anystrings_Conv.Latin_1_Conv_Result;

   ---------------------------------------------------------------------------
   --  Extended Operations (used by String_Types)
   ---------------------------------------------------------------------------

   --  Hash function for use with hashed containers
   function Hash (Key : Unbounded_String) return Ada.Containers.Hash_Type renames Ada.Strings.Unbounded.Hash;

   --  Slice extraction
   function Slice (Source : Unbounded_String; Low : Positive; High : Natural) return Unbounded_String
   renames Ada.Strings.Unbounded.Unbounded_Slice;

   --  Index/search operations (returns 0 if not found)
   function Index (Source : Unbounded_String; Pattern : Unbounded_String) return Natural;

   function Index_Latin_1 (Source : Unbounded_String; Pattern : String) return Natural;

   function Index_From
     (Source      : Unbounded_String;
      Pattern     : Unbounded_String;
      Starting_At : Positive) return Natural;

   function Index_Reverse (Source : Unbounded_String; Pattern : Unbounded_String) return Natural;

   --  Case conversion

   --  @summary Full Unicode case mapping of UTF-8 storage. The results are the
   --  same as the vss backend's, from the generated UCD 15.1.0 tables.
   --
   --  @description
   --  Each maximal run of well-formed UTF-8 is mapped by
   --  Anystrings_UTF_8_Case (on Anystrings_Simple_Case), with Final_Sigma
   --  decided inside the run. That unit is SPARK_Mode On and proved free of
   --  run-time errors, whatever the length of the source; this body only
   --  converts to and from String.
   --  Ill-formed bytes are copied unchanged and end the run. The byte length of
   --  the result may differ from the input (e.g. U+0130 lower-cases to U+0069
   --  U+0307). Its length is Full_Lower_Length (Source) / Full_Upper_Length
   --  (the facade states it as the postcondition of To_Lower / To_Upper).
   function To_Lower (Source : Unbounded_String) return Unbounded_String;

   --  @summary Simple lower-case mapping, one code point in, one code point out.
   --
   --  @description
   --  Decodes the stored UTF-8 one code point at a time and maps each with the
   --  Unicode simple lower-case mapping. A mapping that would change the UTF-8
   --  byte length of its code point is not applied, so the result has the same
   --  Length (bytes) as Source. Bytes that are not part of a well-formed
   --  sequence are copied unchanged.
   function Simple_To_Lower (Source : Unbounded_String) return Unbounded_String;

   --  @summary Length, in bytes, of To_Lower (Source) / To_Upper (Source), computed
   --  without building the result (pass 1 of the two-pass mapping).
   function Full_Lower_Length (Source : Unbounded_String) return Long_Long_Integer;

   function Full_Upper_Length (Source : Unbounded_String) return Long_Long_Integer;

   function To_Upper (Source : Unbounded_String) return Unbounded_String;

   --  Prefix/suffix checking
   function Starts_With (Source : Unbounded_String; Prefix : Unbounded_String) return Boolean;

   function Starts_With_Latin_1 (Source : Unbounded_String; Prefix : String) return Boolean;

   function Ends_With (Source : Unbounded_String; Suffix : Unbounded_String) return Boolean;

   --  Trim whitespace from both ends
   function Trim (Source : Unbounded_String) return Unbounded_String;

   --  Create a single-character string
   function From_Character (C : Character) return Unbounded_String;

   ---------------------------------------------------------------------------
   --  UTF-8 Boundary Operations (FUNC-UTF8-003, FUNC-UTF8-008, NFR-UTF8-007)

   --  @summary Emit the UTF-8 bytes held in the storage.
   --
   --  @description
   --  Per FUNC-CONV-001 / FUNC-CONV-003 the `standard` backend stores its
   --  bytes as a UTF-8 byte sequence (caller's responsibility — guaranteed
   --  by the From_UTF_8 ingestion path, by the Ada.Command_Line bridge per
   --  FUNC-CMDLINE-008, and by the UTF-8 source-file convention recorded in
   --  the root AGENTS.md). To_UTF_8 is therefore byte-identity: it returns
   --  Ada.Strings.Unbounded.To_String (Source) verbatim, with no
   --  transcoding step.
   --
   --  This is observationally equivalent to the prior
   --  Ada.Strings.UTF_Encoding.Strings.Encode-based body on ASCII input,
   --  but produces correct (non-double-encoded) output on UTF-8 input —
   --  the previous behaviour treated stored bytes as Latin-1 code points
   --  and re-encoded them, producing systematic mojibake on any non-ASCII
   --  argv or environment value (FUNC-CONV-011 amendment to FUNC-UTF8-003).
   --
   --  ASCII (U+0000..U+007F) passes through byte-for-byte (FUNC-UTF8-005,
   --  FUNC-CONV-005). Surrogates cannot occur in a Character (range
   --  0..255), so FUNC-UTF8-007 is satisfied vacuously. The result is
   --  well-formed UTF-8 whenever the storage was well-formed UTF-8
   --  (FUNC-UTF8-006).
   --
   --  @param Source  The Unbounded_String whose stored bytes (UTF-8) are
   --                 to be returned.
   --  @return        The stored UTF-8 byte sequence.
   --  @relation FUNC-UTF8-003, FUNC-UTF8-005, FUNC-UTF8-006, FUNC-CONV-001,
   --            FUNC-CONV-003, FUNC-CONV-011, NFR-UTF8-007, NFR-UTF8-010
   function To_UTF_8 (Source : Unbounded_String) return String;

   --  Wide_Wide_String Boundary

   --  @summary Decode the UTF-8 storage as a Wide_Wide_String of code-points.
   --
   --  @description
   --  Total; never raises. Decodes the stored UTF-8 bytes with the shared
   --  replacement algorithm (Anystrings_UTF_8_Replace.Decode_Replacing):
   --  one U+FFFD per maximal ill-formed subpart (Unicode section 3.9).
   function To_Wide_Wide_String (Source : Unbounded_String) return Wide_Wide_String;

   --  @summary Number of code points To_Wide_Wide_String (Source) yields.
   --
   --  @description
   --  Equal to To_Wide_Wide_String (Source)'Length for any stored bytes.
   --  Linear, allocation-free.
   function Code_Point_Length (Source : Unbounded_String) return Natural;

   --  @summary Encode a Wide_Wide_String as UTF-8 storage.
   --
   --  @description
   --  Total; never raises. Each Wide_Wide_Character is encoded as a 1..4
   --  byte UTF-8 sequence per RFC 3629. Wide_Wide_Character values in the
   --  surrogate range U+D800..U+DFFF and values greater than U+10FFFF are
   --  substituted with U+FFFD before encoding.
   function From_Wide_Wide_String (Source : Wide_Wide_String) return Unbounded_String;

   --  Wide_Wide_String Boundary - Per-call invalid-code-point policy (Tier 2)

   --  @summary Encode a Wide_Wide_String as UTF-8 storage, substituting
   --  caller-supplied Substitute for invalid code-points.
   --
   --  @description
   --  Total; never raises. Same encoding logic as From_Wide_Wide_String
   --  but replaces the backend default substitute (U+FFFD) with Substitute.
   --  Substitute is assumed to be a valid Unicode scalar; the wrapper in
   --  string_types.ads enforces this via precondition.
   function From_Wide_Wide_String_With_Substitute
     (Source     : Wide_Wide_String;
      Substitute : Wide_Wide_Character) return Unbounded_String;

   --  @summary Encode a Wide_Wide_String as UTF-8 storage, dropping
   --  invalid code-points.
   --
   --  @description
   --  Total; never raises. Iterates Source and encodes only valid
   --  code-points; surrogates and values > U+10FFFF are dropped. Output
   --  length may be shorter than Source.
   function From_Wide_Wide_String_Skip_Invalid
     (Source : Wide_Wide_String) return Unbounded_String;

   --  Character Classification & Case Mapping
   ---------------------------------------------------------------------------
   --  Delegates to Ada.Characters.Handling, except the case predicates and
   --  mapping, which are ASCII only (see below). Length/Element on this backend
   --  count bytes (Latin-1), so these predicates classify Latin-1 code
   --  points only — code points > U+00FF are not representable here.

   function Char_Is_Alphanumeric (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Alphanumeric;

   function Char_Is_Control (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Control;

   function Char_Is_Digit (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Digit;

   function Char_Is_Graphic (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Graphic;

   function Char_Is_Hex_Digit (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Hexadecimal_Digit;

   function Char_Is_Letter (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Letter;

   function Char_Is_Line_Terminator (C : Character) return Boolean;

   --  ASCII only, as Char_To_Lower / Char_To_Upper: a byte >= 16#80# (one byte
   --  of UTF-8) is neither lower nor upper case. Only a-z and A-Z are.
   function Char_Is_Lower (C : Character) return Boolean;

   function Char_Is_Upper (C : Character) return Boolean;

   --  ASCII whitespace: SP, HT, LF, VT, FF, CR.
   function Char_Is_Whitespace (C : Character) return Boolean;

   --  ASCII only. On this backend a Character is one byte of UTF-8 storage, so
   --  a byte >= 16#80# is a lead or continuation byte, never a letter: it is
   --  returned unchanged (the Latin-1 mapping of Ada.Characters.Handling would
   --  turn the lead byte C3 of U+00C9 into E3). Only A-Z and a-z change.
   function Char_To_Lower (C : Character) return Character;

   function Char_To_Upper (C : Character) return Character;

end Standard_String_Operations;
