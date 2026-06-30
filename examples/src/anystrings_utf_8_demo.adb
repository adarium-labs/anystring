-------------------------------------------------------------------------------
--  anystrings_utf_8_demo.adb — UTF-8 Boundary API demonstration
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  End-to-end walkthrough of the UTF-8 boundary API added by feature
--  UTF8-BOUNDARY-API.
--
--  @description
--  Demonstrates every public surface of the UTF-8 interchange boundary
--  re-exported through String_Types:
--    - To_UTF_8    : String_Type -> String  (total encoder, FUNC-UTF8-003)
--    - From_UTF_8  : String -> UTF_8_Decode_Result (total decoder, FUNC-UTF8-008)
--    - Is_Ok       : UTF_8_Decode_Result -> Boolean
--    - Get_Value   : UTF_8_Decode_Result -> String_Type (Pre: Is_Ok)
--    - Get_Error   : UTF_8_Decode_Result -> UTF_8_Decode_Error (Pre: not Is_Ok)
--    - UTF_8_Decode_Error enumeration (FUNC-UTF8-001)
--
--  Requirement coverage:
--    FUNC-UTF8-001  UTF_8_Decode_Error enumeration
--    FUNC-UTF8-002  UTF_8_Decode_Result discriminated record
--    FUNC-UTF8-003  To_UTF_8 formal subprogram
--    FUNC-UTF8-004  To_UTF_8 on empty input
--    FUNC-UTF8-005  ASCII fast-path correctness
--    FUNC-UTF8-006  Output is always well-formed UTF-8
--    FUNC-UTF8-007  Surrogate substitution with U+FFFD (wide/wide_wide)
--    FUNC-UTF8-008  From_UTF_8 formal subprogram
--    FUNC-UTF8-009  From_UTF_8 on empty input
--    FUNC-UTF8-010  Error mapping for six canonical malformed inputs
--    FUNC-UTF8-011  Round-trip identity for surrogate-free values
--    NFR-UTF8-002   Wrapper expression functions with SPARK contracts
--    NFR-UTF8-005   To_UTF_8 is total (never raises)
--    NFR-UTF8-006   Identical UTF-8 surface from every backend's String_Types
--    NFR-UTF8-010   To_UTF_8 and To_Latin_1 are distinct for code points > U+007F
--    FUNC-UTF8-014  Get_Value_Or fallback accessor (no precondition, never raises)

with Ada.Text_IO;
with String_Types; use String_Types;

procedure Anystrings_UTF_8_Demo is

   ---------------------------------------------------------------------------
   --  Local helper: print a String as hexadecimal bytes, space-separated.
   ---------------------------------------------------------------------------
   procedure Put_Hex (Label : String; Bytes : String) is
   begin
      Ada.Text_IO.Put ("  " & Label & ": [");
      for Index in Bytes'Range loop
         declare
            Byte_Value : constant Natural := Character'Pos (Bytes (Index));
            Hex_Chars  : constant String := "0123456789ABCDEF";
            High_Nibble : constant Character := Hex_Chars (Hex_Chars'First + Byte_Value / 16);
            Low_Nibble  : constant Character := Hex_Chars (Hex_Chars'First + Byte_Value mod 16);
         begin
            Ada.Text_IO.Put ("16#" & High_Nibble & Low_Nibble & "#");
            if Index < Bytes'Last then
               Ada.Text_IO.Put (" ");
            end if;
         end;
      end loop;
      Ada.Text_IO.Put_Line ("]  (" & Natural'Image (Bytes'Length) & " byte(s))");
   end Put_Hex;

   ---------------------------------------------------------------------------
   --  Local helper: decode and report result or error.
   ---------------------------------------------------------------------------
   procedure Decode_And_Report (Label : String; Utf8_Bytes : String) is
      Result : constant UTF_8_Decode_Result := From_UTF_8 (Utf8_Bytes);
   begin
      Put_Hex (Label & " input", Utf8_Bytes);
      if Is_Ok (Result) then
         declare
            Decoded_Bytes : constant String := To_Latin_1 (Get_Value (Result));
         begin
            Put_Hex (Label & " value (Latin-1)", Decoded_Bytes);
         end;
      else
         Ada.Text_IO.Put_Line
           ("  " & Label & " error: " & UTF_8_Decode_Error'Image (Get_Error (Result)));
      end if;
   end Decode_And_Report;

begin

   Ada.Text_IO.Put_Line ("=== anystrings UTF-8 Boundary API Demo ===");
   Ada.Text_IO.New_Line;

   ---------------------------------------------------------------------------
   --  Section 1: Encoding (To_UTF_8)
   --  @relation FUNC-UTF8-003, FUNC-UTF8-004, FUNC-UTF8-005, FUNC-UTF8-006
   --  @relation NFR-UTF8-005, NFR-UTF8-006, NFR-UTF8-010
   ---------------------------------------------------------------------------
   Ada.Text_IO.Put_Line ("---- Section: Encoding (To_UTF_8) ----");
   Ada.Text_IO.New_Line;

   --  Empty string (FUNC-UTF8-004)
   declare
      Empty       : constant String_Type := Empty_String;
      Utf8_Result : constant String := To_UTF_8 (Empty);
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-004] Empty string encoding:");
      Ada.Text_IO.Put_Line
        ("  To_UTF_8 (Empty_String) length =" & Natural'Image (Utf8_Result'Length)
         & "  (expected 0)");
      Ada.Text_IO.New_Line;
   end;

   --  ASCII fast-path (FUNC-UTF8-005): code points U+0000-U+007F
   declare
      Ascii_Input : constant String_Type := To_String_Type (String'("Hello, world!"));
      Utf8_Result : constant String := To_UTF_8 (Ascii_Input);
      Latin1_Out  : constant String := To_Latin_1 (Ascii_Input);
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-005] ASCII fast-path:");
      Put_Hex ("To_UTF_8", Utf8_Result);
      Ada.Text_IO.Put_Line
        ("  UTF-8 = Latin-1 for pure ASCII: "
         & Boolean'Image (Utf8_Result = Latin1_Out));
      Ada.Text_IO.New_Line;
   end;

   --  Latin-1 supplement: é (U+00E9) and ñ (U+00F1)
   --  In UTF-8: é -> 16#C3# 16#A9#, ñ -> 16#C3# 16#B1#
   --  In Latin-1: é -> 16#E9#, ñ -> 16#F1# (single bytes)
   --  This also demonstrates NFR-UTF8-010: To_UTF_8 /= To_Latin_1 above U+007F
   declare
      Latin1_Supplement : constant String_Type :=
        To_String_Type ("caf" & Character'Val (16#E9#));  --  "café"
      Utf8_Result       : constant String := To_UTF_8 (Latin1_Supplement);
      Latin1_Result     : constant String := To_Latin_1 (Latin1_Supplement);
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-003, NFR-UTF8-010] Latin-1 supplement (café):");
      Put_Hex ("To_UTF_8  ", Utf8_Result);
      Put_Hex ("To_Latin_1", Latin1_Result);
      Ada.Text_IO.Put_Line
        ("  To_UTF_8 /= To_Latin_1 for non-ASCII: "
         & Boolean'Image (Utf8_Result /= Latin1_Result));
      Ada.Text_IO.New_Line;
   end;

   --  A string with both ASCII and Latin-1 content: "ñoño"
   declare
      Mixed_String : constant String_Type :=
        To_String_Type
          (Character'Val (16#F1#) & "o"  --  ñ + o
           & Character'Val (16#F1#) & "o");  --  ñ + o
      Utf8_Result  : constant String := To_UTF_8 (Mixed_String);
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-006] Mixed ASCII + Latin-1 supplement (ñoño):");
      Put_Hex ("To_UTF_8", Utf8_Result);
      Ada.Text_IO.New_Line;
   end;

   ---------------------------------------------------------------------------
   --  Section 2: Decoding success (From_UTF_8)
   --  @relation FUNC-UTF8-008, FUNC-UTF8-009, FUNC-UTF8-011
   ---------------------------------------------------------------------------
   Ada.Text_IO.Put_Line ("---- Section: Decoding Success (From_UTF_8) ----");
   Ada.Text_IO.New_Line;

   --  Empty string decode (FUNC-UTF8-009)
   declare
      Empty_Result : constant UTF_8_Decode_Result := From_UTF_8 ("");
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-009] Empty UTF-8 input:");
      Ada.Text_IO.Put_Line
        ("  Is_Ok = " & Boolean'Image (Is_Ok (Empty_Result)) & "  (expected TRUE)");
      Ada.Text_IO.Put_Line
        ("  Get_Value length = "
         & Natural'Image (Length (Get_Value (Empty_Result))) & "  (expected 0)");
      Ada.Text_IO.New_Line;
   end;

   --  ASCII round-trip (FUNC-UTF8-011)
   declare
      Source_Str   : constant String_Type := To_String_Type (String'("Hello, world!"));
      Encoded      : constant String := To_UTF_8 (Source_Str);
      Round_Result : constant UTF_8_Decode_Result := From_UTF_8 (Encoded);
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-011] ASCII round-trip identity:");
      Ada.Text_IO.Put_Line ("  Is_Ok = " & Boolean'Image (Is_Ok (Round_Result)));
      Ada.Text_IO.Put_Line
        ("  Round-trip value = original: "
         & Boolean'Image (Get_Value (Round_Result) = Source_Str));
      Ada.Text_IO.New_Line;
   end;

   --  Latin-1 supplement round-trip (FUNC-UTF8-011)
   declare
      Source_Str   : constant String_Type :=
        To_String_Type ("caf" & Character'Val (16#E9#));  --  "café"
      Encoded      : constant String := To_UTF_8 (Source_Str);
      Round_Result : constant UTF_8_Decode_Result := From_UTF_8 (Encoded);
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-011] Latin-1 supplement round-trip (café):");
      Put_Hex ("Encoded (UTF-8)", Encoded);
      Ada.Text_IO.Put_Line ("  Is_Ok = " & Boolean'Image (Is_Ok (Round_Result)));
      Ada.Text_IO.Put_Line
        ("  Round-trip value = original: "
         & Boolean'Image (Get_Value (Round_Result) = Source_Str));
      Ada.Text_IO.New_Line;
   end;

   --  Well-formed multi-byte UTF-8 decode: U+00E9 (é) in UTF-8
   declare
      E_Acute_Utf8 : constant String :=
        String'(Character'Val (16#C3#), Character'Val (16#A9#));  --  é in UTF-8
      Decode_Ok    : constant UTF_8_Decode_Result := From_UTF_8 (E_Acute_Utf8);
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-008] Decode well-formed UTF-8 (U+00E9 é):");
      Put_Hex ("UTF-8 bytes", E_Acute_Utf8);
      Ada.Text_IO.Put_Line ("  Is_Ok = " & Boolean'Image (Is_Ok (Decode_Ok)));
      if Is_Ok (Decode_Ok) then
         declare
            Decoded_Latin1 : constant String := To_Latin_1 (Get_Value (Decode_Ok));
         begin
            Put_Hex ("Decoded (Latin-1)", Decoded_Latin1);
         end;
      end if;
      Ada.Text_IO.New_Line;
   end;

   ---------------------------------------------------------------------------
   --  Section 3: Decoding failure — six canonical malformed sequences
   --  @relation FUNC-UTF8-001, FUNC-UTF8-010
   ---------------------------------------------------------------------------
   Ada.Text_IO.Put_Line ("---- Section: Decoding Failure (Six Canonical Errors) ----");
   Ada.Text_IO.New_Line;

   --  1. Invalid_Lead_Byte: bare continuation byte 16#80#
   declare
      Bad_Lead : constant String := String'(1 => Character'Val (16#80#));
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-010] Invalid_Lead_Byte:");
      Decode_And_Report ("16#80#", Bad_Lead);
      Ada.Text_IO.New_Line;
   end;

   --  2. Truncated_Sequence: lone 2-byte lead 16#C3# without continuation
   declare
      Truncated : constant String := String'(1 => Character'Val (16#C3#));
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-010] Truncated_Sequence:");
      Decode_And_Report ("16#C3#", Truncated);
      Ada.Text_IO.New_Line;
   end;

   --  3. Invalid_Continuation: 2-byte lead followed by an ASCII byte
   declare
      Bad_Cont : constant String :=
        String'(Character'Val (16#C3#), Character'Val (16#28#));  --  lead + '('
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-010] Invalid_Continuation:");
      Decode_And_Report ("16#C3# 16#28#", Bad_Cont);
      Ada.Text_IO.New_Line;
   end;

   --  4. Overlong_Encoding: overlong '/' — U+002F encoded as 16#C0# 16#AF#
   declare
      Overlong : constant String :=
        String'(Character'Val (16#C0#), Character'Val (16#AF#));
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-010] Overlong_Encoding:");
      Decode_And_Report ("16#C0# 16#AF#", Overlong);
      Ada.Text_IO.New_Line;
   end;

   --  5. Surrogate_Code_Point: U+D800 encoded in UTF-8: 16#ED# 16#A0# 16#80#
   declare
      Surrogate_Bytes : constant String :=
        String'(Character'Val (16#ED#), Character'Val (16#A0#), Character'Val (16#80#));
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-010] Surrogate_Code_Point (U+D800):");
      Decode_And_Report ("16#ED# 16#A0# 16#80#", Surrogate_Bytes);
      Ada.Text_IO.New_Line;
   end;

   --  6. Code_Point_Out_Of_Range: U+110000 encoded as 16#F4# 16#90# 16#80# 16#80#
   declare
      Out_Of_Range : constant String :=
        String'
          (Character'Val (16#F4#), Character'Val (16#90#),
           Character'Val (16#80#), Character'Val (16#80#));
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-010] Code_Point_Out_Of_Range (U+110000):");
      Decode_And_Report ("16#F4# 16#90# 16#80# 16#80#", Out_Of_Range);
      Ada.Text_IO.New_Line;
   end;

   ---------------------------------------------------------------------------
   --  Section 4: Validity predicate (UTF_8_Is_Valid idiom)
   --  Using Is_Ok (From_UTF_8 (...)) — the canonical idiom (NFR-UTF8-002).
   --  @relation FUNC-UTF8-008, FUNC-UTF8-010, NFR-UTF8-002
   ---------------------------------------------------------------------------
   Ada.Text_IO.Put_Line ("---- Section: Validity Predicate (Is_Ok . From_UTF_8) ----");
   Ada.Text_IO.New_Line;

   declare
      Valid_Utf8   : constant String :=
        String'(Character'Val (16#C3#), Character'Val (16#A9#));  --  é
      Invalid_Utf8 : constant String :=
        String'(1 => Character'Val (16#80#));  --  bare continuation byte
   begin
      Ada.Text_IO.Put_Line ("  [NFR-UTF8-002] UTF_8_Is_Valid idiom:");
      Put_Hex ("Valid input  ", Valid_Utf8);
      Ada.Text_IO.Put_Line
        ("  Is_Ok (From_UTF_8 (valid))   = "
         & Boolean'Image (Is_Ok (From_UTF_8 (Valid_Utf8))));
      Put_Hex ("Invalid input", Invalid_Utf8);
      Ada.Text_IO.Put_Line
        ("  Is_Ok (From_UTF_8 (invalid)) = "
         & Boolean'Image (Is_Ok (From_UTF_8 (Invalid_Utf8))));
      Ada.Text_IO.New_Line;
   end;

   ---------------------------------------------------------------------------
   --  Section 5: Surrogate substitution (wide / wide_wide backends)
   --  @relation FUNC-UTF8-007, NFR-UTF8-005
   --
   --  The standard backend's Character type is 0..255 and cannot hold
   --  surrogate code points (U+D800..U+DFFF), so FUNC-UTF8-007 is satisfied
   --  vacuously for the standard backend.
   --
   --  For wide / wide_wide backends, a String_Type can be constructed whose
   --  underlying Wide_Character or Wide_Wide_Character holds a surrogate code
   --  unit.  To_UTF_8 on such a string must substitute U+FFFD (16#EF# 16#BF#
   --  16#BD#) in place of each surrogate code unit (FUNC-UTF8-007).
   --
   --  A runtime probe of Character_Type'Last detects which backend is active
   --  without any #if directives, keeping a single source file for all four
   --  backends (hard constraint: no backend-specific imports).
   --
   --  The Character_Type'Pos probe works as follows:
   --    - standard:    Character_Type'Pos (Character_Type'Last) =  255
   --    - wide_string: Character_Type'Pos (Character_Type'Last) = 65535
   --    - wide_wide:   Character_Type'Pos (Character_Type'Last) > 65535
   --    - uxstring:    Character_Type uses Unicode_Character; 'Last is > 65535
   --  Any backend whose character type can hold values >= 16#D800# *may* hold
   --  surrogates; the demo prints a diagnostic for the standard backend.
   ---------------------------------------------------------------------------
   Ada.Text_IO.Put_Line ("---- Section: Surrogate Substitution (FUNC-UTF8-007) ----");
   Ada.Text_IO.New_Line;

   declare
      --  Probe: can the active Character_Type hold a high-surrogate code point?
      --  This is a runtime check so the surrogate construction below is guarded.
      Max_Char_Pos  : constant Natural := Character_Type'Pos (Character_Type'Last);
      Can_Hold_Surr : constant Boolean := Max_Char_Pos >= 16#D800#;

      --  U+FFFD bytes: the expected substitution in UTF-8 output (16#EF# 16#BF# 16#BD#)
      FFFD_Utf8 : constant String :=
        String'(Character'Val (16#EF#), Character'Val (16#BF#), Character'Val (16#BD#));

      --  The surrogate code point (U+D800) expressed as a Natural so that
      --  Character_Type'Val is NOT a static expression and thus does not
      --  trigger a compile-time range constraint check on the standard backend.
      --  On the standard backend (Character, 0..255) this code is never
      --  reached at run time because Can_Hold_Surr is False.
      Surrogate_Pos : Natural := 16#D800#;
      pragma Volatile (Surrogate_Pos);  --  prevents static evaluation
      pragma Warnings (Off, Surrogate_Pos);  --  suppress "not modified" advisory

   begin
      if Can_Hold_Surr then
         --  Construct a one-character String_Type holding U+D800 (high surrogate).
         --  Surrogate_Pos is Volatile so Character_Type'Val is a runtime call.
         declare
            Surrogate_Char : constant Character_Type :=
              Character_Type'Val (Surrogate_Pos);
            Surrogate_Str  : constant String_Type :=
              From_Character (Surrogate_Char);
            Encoded        : constant String := To_UTF_8 (Surrogate_Str);
         begin
            Ada.Text_IO.Put_Line
              ("  [FUNC-UTF8-007] Backend can hold surrogates (U+D800):");
            Put_Hex ("To_UTF_8 output", Encoded);
            Ada.Text_IO.Put_Line
              ("  Contains U+FFFD substitution (16#EF# 16#BF# 16#BD#): "
               & Boolean'Image (Encoded = FFFD_Utf8));
         end;
      else
         Ada.Text_IO.Put_Line
           ("  [FUNC-UTF8-007] Standard backend: Character'Last pos ="
            & Natural'Image (Max_Char_Pos)
            & " < 16#D800# -- surrogate substitution satisfied vacuously.");
         Ada.Text_IO.Put_Line
           ("  (Wide / Wide_Wide backends would exercise this path at runtime.)");
      end if;
      Ada.Text_IO.New_Line;
   end;

   ---------------------------------------------------------------------------
   --  Section 6: Get_Value_Or — unconditional fallback accessor
   --  @relation FUNC-UTF8-014, NFR-UTF8-002
   --
   --  Get_Value_Or (R, Fallback) returns Get_Value (R) on success, or
   --  Fallback unchanged on failure.  No precondition — never raises.
   --  Useful in initialisation expressions and non-SPARK call-sites where
   --  an Is_Ok guard is impractical.
   ---------------------------------------------------------------------------
   Ada.Text_IO.Put_Line ("---- Section: Get_Value_Or (FUNC-UTF8-014) ----");
   Ada.Text_IO.New_Line;

   --  6a. Success path: Get_Value_Or returns the decoded value, ignoring Fallback
   declare
      --  Well-formed UTF-8 sequence for é (U+00E9)
      E_Acute_Utf8 : constant String :=
        String'(Character'Val (16#C3#), Character'Val (16#A9#));
      Fallback     : constant String_Type := To_String_Type (String'("<unknown>"));
      Result       : constant UTF_8_Decode_Result := From_UTF_8 (E_Acute_Utf8);
      Value        : constant String_Type := Get_Value_Or (Result, Fallback);
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-014] Success path (well-formed é):");
      Ada.Text_IO.Put_Line
        ("  Is_Ok = " & Boolean'Image (Is_Ok (Result)) & "  (expected TRUE)");
      Put_Hex ("Get_Value_Or result (Latin-1)", To_Latin_1 (Value));
      Ada.Text_IO.Put_Line
        ("  Result equals Get_Value: "
         & Boolean'Image (Value = Get_Value (Result)));
      Ada.Text_IO.New_Line;
   end;

   --  6b. Failure path: Get_Value_Or returns Fallback unchanged
   declare
      Bad_Bytes : constant String := String'(1 => Character'Val (16#80#));
      Fallback  : constant String_Type := To_String_Type (String'("<decode-error>"));
      Result    : constant UTF_8_Decode_Result := From_UTF_8 (Bad_Bytes);
      Value     : constant String_Type := Get_Value_Or (Result, Fallback);
   begin
      Ada.Text_IO.Put_Line ("  [FUNC-UTF8-014] Failure path (bare continuation byte):");
      Ada.Text_IO.Put_Line
        ("  Is_Ok = " & Boolean'Image (Is_Ok (Result)) & "  (expected FALSE)");
      Ada.Text_IO.Put_Line
        ("  Get_Error = " & UTF_8_Decode_Error'Image (Get_Error (Result)));
      Ada.Text_IO.Put_Line
        ("  Get_Value_Or result = fallback: "
         & Boolean'Image (Value = Fallback));
      Ada.Text_IO.New_Line;
   end;

   --  6c. Initialisation expression idiom — usable in declarations
   --  (demonstrates NFR-UTF8-002: expression function usable without a guard)
   declare
      Raw_Input : constant String :=
        String'(Character'Val (16#C3#), Character'Val (16#A9#));  --  é in UTF-8
      Decoded   : constant String_Type :=
        Get_Value_Or (From_UTF_8 (Raw_Input), Empty_String);
   begin
      Ada.Text_IO.Put_Line
        ("  [NFR-UTF8-002] Inline initialisation (Get_Value_Or in declaration):");
      Ada.Text_IO.Put_Line
        ("  Decoded length ="
         & Natural'Image (Length (Decoded)) & "  (expected 1 byte for standard backend)");
      Ada.Text_IO.New_Line;
   end;

   Ada.Text_IO.Put_Line ("=== Demo complete ===");

end Anystrings_UTF_8_Demo;
