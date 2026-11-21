-------------------------------------------------------------------------------
--  UCD_Generator - generates src/anystrings_ucd_case.ads/.adb from the
--  Unicode Character Database files vendored under tools/ucd/data/<version>.
--
--  Usage (see tools/ucd/regenerate.sh):
--    ucd_generator [DATA_DIR [OUTPUT_DIR]]
--  Defaults: tools/ucd/data/15.1.0 and src.
--
--  Input files:
--    UnicodeData.txt        fields 12 (simple upper) and 13 (simple lower)
--    SpecialCasing.txt      unconditional lower/upper mappings (multi-code-point
--                           results included); the Final_Sigma entry; other
--                           conditions are language-specific and are skipped
--    DerivedCoreProperties  Cased and Case_Ignorable ranges
--
--  The output is deterministic: entries are emitted in input order, and the
--  generator checks that every table is strictly ascending.
-------------------------------------------------------------------------------

with Ada.Command_Line;
with Ada.Containers.Vectors;
with Ada.Directories;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Text_IO;

procedure Ucd_Generator is

   use Ada.Strings.Fixed;

   type Pair is record
      Source : Natural;
      Target : Natural;
   end record;

   type Triple is array (1 .. 3) of Natural;

   type Special is record
      Source : Natural;
      Count  : Positive range 1 .. 3;
      Target : Triple;
   end record;

   type Span is record
      First : Natural;
      Last  : Natural;
   end record;

   package Pair_Vectors    is new Ada.Containers.Vectors (Positive, Pair);
   package Special_Vectors is new Ada.Containers.Vectors (Positive, Special);
   package Span_Vectors    is new Ada.Containers.Vectors (Positive, Span);

   function "<" (L, R : Special) return Boolean is (L.Source < R.Source);

   --  SpecialCasing.txt is grouped by script, not sorted by code point.
   package Special_Sorting is new Special_Vectors.Generic_Sorting ("<");

   Simple_Lower_List  : Pair_Vectors.Vector;
   Simple_Upper_List  : Pair_Vectors.Vector;
   Special_Lower_List : Special_Vectors.Vector;
   Special_Upper_List : Special_Vectors.Vector;
   Cased_List         : Span_Vectors.Vector;
   Ignorable_List     : Span_Vectors.Vector;

   Final_Found  : Natural := 0;
   Final_Source : Natural := 0;
   Final_Target : Natural := 0;

   Data_Dir : constant String :=
     (if Ada.Command_Line.Argument_Count >= 1
      then Ada.Command_Line.Argument (1)
      else "tools/ucd/data/15.1.0");

   Output_Dir : constant String :=
     (if Ada.Command_Line.Argument_Count >= 2
      then Ada.Command_Line.Argument (2)
      else "src");

   --  The version is the name of the data directory (data/<version>).
   Ucd_Version : constant String := Ada.Directories.Simple_Name (Data_Dir);

   Digits_Set : constant String := "0123456789ABCDEF";

   ---------------------------------------------------------------------------
   --  Text helpers
   ---------------------------------------------------------------------------

   --  Hexadecimal digits of N, at least four, as an Ada based literal.
   function Hex_Literal (N : Natural) return String is
      Buf : String (1 .. 8) := (others => '0');
      Pos : Positive := 8;
      V   : Natural := N;
   begin
      --  Digits are written from the right; code points have at most 6.
      loop
         Buf (Pos) := Digits_Set (V mod 16 + 1);
         V := V / 16;
         exit when V = 0;
         Pos := Pos - 1;
      end loop;
      declare
         Count : constant Positive := 9 - Pos;
         Total : constant Positive := Positive'Max (4, Count);
         R     : String (1 .. Total) := (others => '0');
      begin
         R (Total - Count + 1 .. Total) := Buf (Pos .. 8);
         return "16#" & R & "#";
      end;
   end Hex_Literal;

   function Hex_Value (S : String) return Natural is
   begin
      return Natural'Value ("16#" & S & "#");
   end Hex_Value;

   --  Field N (0 based) of a semicolon separated line, trimmed; "" if absent.
   function Field (Line : String; N : Natural) return String is
      Start : Natural := Line'First;
      Stop  : Natural;
      Count : Natural := 0;
   begin
      loop
         Stop := Index (Line (Start .. Line'Last), ";");
         if Count = N then
            if Stop = 0 then
               return Trim (Line (Start .. Line'Last), Ada.Strings.Both);
            end if;
            return Trim (Line (Start .. Stop - 1), Ada.Strings.Both);
         end if;
         exit when Stop = 0;
         Start := Stop + 1;
         Count := Count + 1;
      end loop;
      return "";
   end Field;

   --  Space separated hexadecimal code points of S.
   procedure Parse_Sequence (S : String; Target : out Triple; Count : out Natural) is
      Start : Natural := S'First;
      Stop  : Natural;
      Tok   : Natural;
   begin
      Target := (others => 0);
      Count := 0;
      loop
         Stop := Index (S (Start .. S'Last), " ");
         declare
            Token : constant String :=
              (if Stop = 0 then Trim (S (Start .. S'Last), Ada.Strings.Both)
               else Trim (S (Start .. Stop - 1), Ada.Strings.Both));
         begin
            if Token'Length > 0 then
               Count := Count + 1;
               if Count > Triple'Last then
                  raise Program_Error with "mapping longer than 3 code points: " & S;
               end if;
               Tok := Hex_Value (Token);
               Target (Count) := Tok;
            end if;
         end;
         exit when Stop = 0;
         Start := Stop + 1;
      end loop;
   end Parse_Sequence;

   ---------------------------------------------------------------------------
   --  Input
   ---------------------------------------------------------------------------

   procedure Check_Ascending (Last, Next : Natural; Table : String) is
   begin
      if Next <= Last then
         raise Program_Error with Table & ": not strictly ascending at " & Hex_Literal (Next);
      end if;
   end Check_Ascending;

   procedure Read_Unicode_Data is
      File : Ada.Text_IO.File_Type;
   begin
      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Data_Dir & "/UnicodeData.txt");
      while not Ada.Text_IO.End_Of_File (File) loop
         declare
            Line  : constant String := Ada.Text_IO.Get_Line (File);
            Code  : constant Natural := Hex_Value (Field (Line, 0));
            Upper : constant String := Field (Line, 12);
            Lower : constant String := Field (Line, 13);
         begin
            if Lower /= "" then
               if not Simple_Lower_List.Is_Empty then
                  Check_Ascending (Simple_Lower_List.Last_Element.Source, Code, "simple lower");
               end if;
               Simple_Lower_List.Append ((Source => Code, Target => Hex_Value (Lower)));
            end if;
            if Upper /= "" then
               if not Simple_Upper_List.Is_Empty then
                  Check_Ascending (Simple_Upper_List.Last_Element.Source, Code, "simple upper");
               end if;
               Simple_Upper_List.Append ((Source => Code, Target => Hex_Value (Upper)));
            end if;
         end;
      end loop;
      Ada.Text_IO.Close (File);
   end Read_Unicode_Data;

   procedure Read_Special_Casing is
      File : Ada.Text_IO.File_Type;
   begin
      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Data_Dir & "/SpecialCasing.txt");
      while not Ada.Text_IO.End_Of_File (File) loop
         declare
            Raw  : constant String := Ada.Text_IO.Get_Line (File);
            Hash : constant Natural := Index (Raw, "#");
            Line : constant String :=
              (if Hash = 0 then Raw else Raw (Raw'First .. Hash - 1));
         begin
            if Trim (Line, Ada.Strings.Both) /= "" then
               declare
                  Code      : constant Natural := Hex_Value (Field (Line, 0));
                  Lower_Txt : constant String := Field (Line, 1);
                  Upper_Txt : constant String := Field (Line, 3);
                  Condition : constant String := Field (Line, 4);
                  Lower_Seq : Triple;
                  Upper_Seq : Triple;
                  Lower_N   : Natural;
                  Upper_N   : Natural;
               begin
                  if Condition = "" then
                     Parse_Sequence (Lower_Txt, Lower_Seq, Lower_N);
                     Parse_Sequence (Upper_Txt, Upper_Seq, Upper_N);
                     Special_Lower_List.Append
                       ((Source => Code, Count => Lower_N, Target => Lower_Seq));
                     Special_Upper_List.Append
                       ((Source => Code, Count => Upper_N, Target => Upper_Seq));
                  elsif Condition = "Final_Sigma" then
                     Final_Found := Final_Found + 1;
                     Final_Source := Code;
                     Parse_Sequence (Lower_Txt, Lower_Seq, Lower_N);
                     if Lower_N /= 1 then
                        raise Program_Error with "Final_Sigma target is not one code point";
                     end if;
                     Final_Target := Lower_Seq (1);
                  end if;
                  --  Other conditions (lt, tr, az, ...) are language-specific.
                  --  The tables use the root locale, as VSS does by default.
               end;
            end if;
         end;
      end loop;
      Ada.Text_IO.Close (File);
      if Final_Found /= 1 then
         raise Program_Error with "expected exactly one Final_Sigma entry";
      end if;

      Special_Sorting.Sort (Special_Lower_List);
      Special_Sorting.Sort (Special_Upper_List);
      for I in 2 .. Natural (Special_Lower_List.Length) loop
         Check_Ascending
           (Special_Lower_List (I - 1).Source, Special_Lower_List (I).Source, "special lower");
      end loop;
      for I in 2 .. Natural (Special_Upper_List.Length) loop
         Check_Ascending
           (Special_Upper_List (I - 1).Source, Special_Upper_List (I).Source, "special upper");
      end loop;
   end Read_Special_Casing;

   procedure Read_Derived_Core_Properties is
      File : Ada.Text_IO.File_Type;
   begin
      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Data_Dir & "/DerivedCoreProperties.txt");
      while not Ada.Text_IO.End_Of_File (File) loop
         declare
            Raw  : constant String := Ada.Text_IO.Get_Line (File);
            Hash : constant Natural := Index (Raw, "#");
            Line : constant String :=
              (if Hash = 0 then Raw else Raw (Raw'First .. Hash - 1));
         begin
            if Trim (Line, Ada.Strings.Both) /= "" then
               declare
                  Range_Txt : constant String := Field (Line, 0);
                  Prop      : constant String := Field (Line, 1);
                  Dots      : constant Natural := Index (Range_Txt, "..");
                  Span_Value : Span;
               begin
                  if Prop = "Cased" or else Prop = "Case_Ignorable" then
                     if Dots = 0 then
                        Span_Value := (First => Hex_Value (Range_Txt), Last => Hex_Value (Range_Txt));
                     else
                        Span_Value :=
                          (First => Hex_Value (Range_Txt (Range_Txt'First .. Dots - 1)),
                           Last  => Hex_Value (Range_Txt (Dots + 2 .. Range_Txt'Last)));
                     end if;
                     if Prop = "Cased" then
                        if not Cased_List.Is_Empty then
                           Check_Ascending (Cased_List.Last_Element.Last, Span_Value.First, "Cased");
                        end if;
                        Cased_List.Append (Span_Value);
                     else
                        if not Ignorable_List.Is_Empty then
                           Check_Ascending
                             (Ignorable_List.Last_Element.Last, Span_Value.First, "Case_Ignorable");
                        end if;
                        Ignorable_List.Append (Span_Value);
                     end if;
                  end if;
               end;
            end if;
         end;
      end loop;
      Ada.Text_IO.Close (File);
   end Read_Derived_Core_Properties;

   ---------------------------------------------------------------------------
   --  Output
   ---------------------------------------------------------------------------

   Out_Spec : Ada.Text_IO.File_Type;
   Out_Body : Ada.Text_IO.File_Type;

   procedure Spec_Line (Text : String := "") is
   begin
      Ada.Text_IO.Put_Line (Out_Spec, Text);
   end Spec_Line;

   procedure Body_Line (Text : String := "") is
   begin
      Ada.Text_IO.Put_Line (Out_Body, Text);
   end Body_Line;

   function Trim_Image (N : Natural) return String is
   begin
      return Trim (Natural'Image (N), Ada.Strings.Both);
   end Trim_Image;

   procedure Emit_Pair_Table (Name : String; List : Pair_Vectors.Vector) is
      Count : constant Natural := Natural (List.Length);
   begin
      Body_Line ("   " & Name & " : constant Pair_Table :=");
      Body_Line ("     (");
      for I in 1 .. Count loop
         declare
            E : constant Pair := List (I);
         begin
            Body_Line
              ("      (" & Hex_Literal (E.Source) & ", " & Hex_Literal (E.Target) & ")"
               & (if I < Count then "," else ""));
         end;
      end loop;
      Body_Line ("     );");
      Body_Line;
   end Emit_Pair_Table;

   procedure Emit_Special_Table (Name : String; List : Special_Vectors.Vector) is
      Count : constant Natural := Natural (List.Length);
   begin
      Body_Line ("   " & Name & " : constant Special_Table :=");
      Body_Line ("     (");
      for I in 1 .. Count loop
         declare
            E : constant Special := List (I);
         begin
            Body_Line
              ("      (Source => " & Hex_Literal (E.Source)
               & ", Count => " & Trim_Image (E.Count)
               & ", Target => (" & Hex_Literal (E.Target (1)) & ", "
               & Hex_Literal (E.Target (2)) & ", " & Hex_Literal (E.Target (3)) & "))"
               & (if I < Count then "," else ""));
         end;
      end loop;
      Body_Line ("     );");
      Body_Line;
   end Emit_Special_Table;

   procedure Emit_Span_Table (Name : String; List : Span_Vectors.Vector) is
      Count : constant Natural := Natural (List.Length);
   begin
      Body_Line ("   " & Name & " : constant Span_Table :=");
      Body_Line ("     (");
      for I in 1 .. Count loop
         declare
            E : constant Span := List (I);
         begin
            Body_Line
              ("      (First => " & Hex_Literal (E.First)
               & ", Last => " & Hex_Literal (E.Last) & ")"
               & (if I < Count then "," else ""));
         end;
      end loop;
      Body_Line ("     );");
      Body_Line;
   end Emit_Span_Table;

   procedure Write_Spec is
   begin
      Spec_Line ("-------------------------------------------------------------------------------");
      Spec_Line ("--  Anystrings_UCD_Case - Unicode case data (GENERATED, do not edit)");
      Spec_Line ("--");
      Spec_Line ("--  Generated by tools/ucd (ucd_generator) from the Unicode Character");
      Spec_Line ("--  Database " & Ucd_Version & " files in tools/ucd/data/" & Ucd_Version & ".");
      Spec_Line ("--  Regenerate with tools/ucd/regenerate.sh; do not edit by hand.");
      Spec_Line ("--");
      Spec_Line ("--  SPDX-License-Identifier: Apache-2.0");
      Spec_Line ("-------------------------------------------------------------------------------");
      Spec_Line;
      Spec_Line ("--  @summary");
      Spec_Line ("--  Simple and full case mappings and the Cased / Case_Ignorable properties");
      Spec_Line ("--  needed for the Final_Sigma rule, as lookups in constant tables.");
      Spec_Line ("--");
      Spec_Line ("--  @description");
      Spec_Line ("--  Root locale only: the language-specific SpecialCasing conditions are not");
      Spec_Line ("--  included. Lookups are total and never raise; a code point without a");
      Spec_Line ("--  mapping maps to itself.");
      Spec_Line ("package Anystrings_UCD_Case");
      Spec_Line ("  with SPARK_Mode");
      Spec_Line ("is");
      Spec_Line;
      Spec_Line ("   UCD_Version : constant String := """ & Ucd_Version & """;");
      Spec_Line;
      Spec_Line ("   subtype Code_Point is Natural range 0 .. 16#10_FFFF#;");
      Spec_Line;
      Spec_Line ("   subtype Mapping_Length is Positive range 1 .. 3;");
      Spec_Line;
      Spec_Line ("   type Mapped_Text is array (Mapping_Length) of Code_Point;");
      Spec_Line;
      Spec_Line ("   --  SpecialCasing.txt: 03A3; 03C2; 03A3; 03A3; Final_Sigma;");
      Spec_Line ("   Final_Sigma_Source : constant Code_Point := " & Hex_Literal (Final_Source) & ";");
      Spec_Line ("   Final_Sigma_Target : constant Code_Point := " & Hex_Literal (Final_Target) & ";");
      Spec_Line;
      Spec_Line ("   function Simple_Lower (C : Code_Point) return Code_Point");
      Spec_Line ("   with Global => null;");
      Spec_Line;
      Spec_Line ("   function Simple_Upper (C : Code_Point) return Code_Point");
      Spec_Line ("   with Global => null;");
      Spec_Line;
      Spec_Line ("   --  Full lower-case mapping: Text (1 .. Count) (no Final_Sigma context).");
      Spec_Line ("   procedure Full_Lower (C : Code_Point; Text : out Mapped_Text; Count : out Mapping_Length)");
      Spec_Line ("   with Global => null;");
      Spec_Line;
      Spec_Line ("   --  Full upper-case mapping: Text (1 .. Count).");
      Spec_Line ("   procedure Full_Upper (C : Code_Point; Text : out Mapped_Text; Count : out Mapping_Length)");
      Spec_Line ("   with Global => null;");
      Spec_Line;
      Spec_Line ("   function Is_Cased (C : Code_Point) return Boolean");
      Spec_Line ("   with Global => null;");
      Spec_Line;
      Spec_Line ("   function Is_Case_Ignorable (C : Code_Point) return Boolean");
      Spec_Line ("   with Global => null;");
      Spec_Line;
      Spec_Line ("end Anystrings_UCD_Case;");
   end Write_Spec;

   procedure Write_Body is
   begin
      Body_Line ("-------------------------------------------------------------------------------");
      Body_Line ("--  Anystrings_UCD_Case - Unicode case data (GENERATED, do not edit)");
      Body_Line ("--");
      Body_Line ("--  Generated by tools/ucd (ucd_generator) from UCD " & Ucd_Version & ". Do not edit.");
      Body_Line ("--  SPDX-License-Identifier: Apache-2.0");
      Body_Line ("-------------------------------------------------------------------------------");
      Body_Line;
      Body_Line ("package body Anystrings_UCD_Case");
      Body_Line ("  with SPARK_Mode");
      Body_Line ("is");
      Body_Line;
      Body_Line ("   type Pair is record");
      Body_Line ("      Source : Code_Point;");
      Body_Line ("      Target : Code_Point;");
      Body_Line ("   end record;");
      Body_Line;
      Body_Line ("   type Pair_Table is array (Positive range <>) of Pair;");
      Body_Line;
      Body_Line ("   type Special_Entry is record");
      Body_Line ("      Source : Code_Point;");
      Body_Line ("      Count  : Mapping_Length;");
      Body_Line ("      Target : Mapped_Text;");
      Body_Line ("   end record;");
      Body_Line;
      Body_Line ("   type Special_Table is array (Positive range <>) of Special_Entry;");
      Body_Line;
      Body_Line ("   type Span is record");
      Body_Line ("      First : Code_Point;");
      Body_Line ("      Last  : Code_Point;");
      Body_Line ("   end record;");
      Body_Line;
      Body_Line ("   type Span_Table is array (Positive range <>) of Span;");
      Body_Line;
      Body_Line ("   --  Tables, sorted by code point (checked by the generator).");
      Body_Line;
      Emit_Pair_Table ("Simple_Lower_Table", Simple_Lower_List);
      Emit_Pair_Table ("Simple_Upper_Table", Simple_Upper_List);
      Emit_Special_Table ("Special_Lower_Table", Special_Lower_List);
      Emit_Special_Table ("Special_Upper_Table", Special_Upper_List);
      Emit_Span_Table ("Cased_Table", Cased_List);
      Emit_Span_Table ("Case_Ignorable_Table", Ignorable_List);

      Body_Line
        ("   --  Index of the entry for C in T (binary search), or 0 when absent.");
      Body_Line
        ("   function Find_Pair (T : Pair_Table; C : Code_Point) return Natural");
      Body_Line
        ("   with Global => null,");
      Body_Line
        ("        Pre  => T'First = 1 and then T'Length >= 1 and then T'Last < Natural'Last,");
      Body_Line
        ("        Post => Find_Pair'Result = 0");
      Body_Line
        ("                or else (Find_Pair'Result in T'Range and then T (Find_Pair'Result).Source = C)");
      Body_Line
        ("   is");
      Body_Line
        ("      Low  : Natural := T'First;");
      Body_Line
        ("      High : Natural := T'Last + 1;");
      Body_Line
        ("      Mid  : Natural;");
      Body_Line
        ("   begin");
      Body_Line
        ("      while Low < High loop");
      Body_Line
        ("         pragma Loop_Invariant (Low in T'First .. T'Last + 1 and then High in Low .. T'Last + 1);");
      Body_Line
        ("         pragma Loop_Variant (Decreases => High - Low);");
      Body_Line
        ("         Mid := Low + (High - Low) / 2;");
      Body_Line
        ("         if T (Mid).Source = C then");
      Body_Line
        ("            return Mid;");
      Body_Line
        ("         elsif T (Mid).Source < C then");
      Body_Line
        ("            Low := Mid + 1;");
      Body_Line
        ("         else");
      Body_Line
        ("            High := Mid;");
      Body_Line
        ("         end if;");
      Body_Line
        ("      end loop;");
      Body_Line
        ("      return 0;");
      Body_Line
        ("   end Find_Pair;");
      Body_Line;
      Body_Line
        ("   function Find_Special (T : Special_Table; C : Code_Point) return Natural");
      Body_Line
        ("   with Global => null,");
      Body_Line
        ("        Pre  => T'First = 1 and then T'Length >= 1 and then T'Last < Natural'Last,");
      Body_Line
        ("        Post => Find_Special'Result = 0");
      Body_Line
        ("                or else (Find_Special'Result in T'Range and then T (Find_Special'Result).Source = C)");
      Body_Line
        ("   is");
      Body_Line
        ("      Low  : Natural := T'First;");
      Body_Line
        ("      High : Natural := T'Last + 1;");
      Body_Line
        ("      Mid  : Natural;");
      Body_Line
        ("   begin");
      Body_Line
        ("      while Low < High loop");
      Body_Line
        ("         pragma Loop_Invariant (Low in T'First .. T'Last + 1 and then High in Low .. T'Last + 1);");
      Body_Line
        ("         pragma Loop_Variant (Decreases => High - Low);");
      Body_Line
        ("         Mid := Low + (High - Low) / 2;");
      Body_Line
        ("         if T (Mid).Source = C then");
      Body_Line
        ("            return Mid;");
      Body_Line
        ("         elsif T (Mid).Source < C then");
      Body_Line
        ("            Low := Mid + 1;");
      Body_Line
        ("         else");
      Body_Line
        ("            High := Mid;");
      Body_Line
        ("         end if;");
      Body_Line
        ("      end loop;");
      Body_Line
        ("      return 0;");
      Body_Line
        ("   end Find_Special;");
      Body_Line;
      Body_Line
        ("   --  True when C lies in one of the ranges of T (binary search on First).");
      Body_Line
        ("   function In_Spans (T : Span_Table; C : Code_Point) return Boolean");
      Body_Line
        ("   with Global => null,");
      Body_Line
        ("        Pre => T'First = 1 and then T'Length >= 1 and then T'Last < Natural'Last");
      Body_Line
        ("   is");
      Body_Line
        ("      Low  : Natural := T'First;");
      Body_Line
        ("      High : Natural := T'Last + 1;");
      Body_Line
        ("      Mid  : Natural;");
      Body_Line
        ("   begin");
      Body_Line
        ("      --  Low ends as the first index whose First is above C.");
      Body_Line
        ("      while Low < High loop");
      Body_Line
        ("         pragma Loop_Invariant (Low in T'First .. T'Last + 1 and then High in Low .. T'Last + 1);");
      Body_Line
        ("         pragma Loop_Variant (Decreases => High - Low);");
      Body_Line
        ("         Mid := Low + (High - Low) / 2;");
      Body_Line
        ("         if T (Mid).First <= C then");
      Body_Line
        ("            Low := Mid + 1;");
      Body_Line
        ("         else");
      Body_Line
        ("            High := Mid;");
      Body_Line
        ("         end if;");
      Body_Line
        ("      end loop;");
      Body_Line
        ("      if Low = T'First then");
      Body_Line
        ("         return False;");
      Body_Line
        ("      end if;");
      Body_Line
        ("      return C <= T (Low - 1).Last;");
      Body_Line
        ("   end In_Spans;");
      Body_Line;
      Body_Line
        ("   function Simple_Lower (C : Code_Point) return Code_Point is");
      Body_Line
        ("      Index : constant Natural := Find_Pair (Simple_Lower_Table, C);");
      Body_Line
        ("   begin");
      Body_Line
        ("      if Index = 0 then");
      Body_Line
        ("         return C;");
      Body_Line
        ("      end if;");
      Body_Line
        ("      return Simple_Lower_Table (Index).Target;");
      Body_Line
        ("   end Simple_Lower;");
      Body_Line;
      Body_Line
        ("   function Simple_Upper (C : Code_Point) return Code_Point is");
      Body_Line
        ("      Index : constant Natural := Find_Pair (Simple_Upper_Table, C);");
      Body_Line
        ("   begin");
      Body_Line
        ("      if Index = 0 then");
      Body_Line
        ("         return C;");
      Body_Line
        ("      end if;");
      Body_Line
        ("      return Simple_Upper_Table (Index).Target;");
      Body_Line
        ("   end Simple_Upper;");
      Body_Line;
      Body_Line
        ("   procedure Full_Lower (C : Code_Point; Text : out Mapped_Text; Count : out Mapping_Length) is");
      Body_Line
        ("      Index : constant Natural := Find_Special (Special_Lower_Table, C);");
      Body_Line
        ("   begin");
      Body_Line
        ("      if Index = 0 then");
      Body_Line
        ("         Text := (1 => Simple_Lower (C), others => 0);");
      Body_Line
        ("         Count := 1;");
      Body_Line
        ("      else");
      Body_Line
        ("         Text := Special_Lower_Table (Index).Target;");
      Body_Line
        ("         Count := Special_Lower_Table (Index).Count;");
      Body_Line
        ("      end if;");
      Body_Line
        ("   end Full_Lower;");
      Body_Line;
      Body_Line
        ("   procedure Full_Upper (C : Code_Point; Text : out Mapped_Text; Count : out Mapping_Length) is");
      Body_Line
        ("      Index : constant Natural := Find_Special (Special_Upper_Table, C);");
      Body_Line
        ("   begin");
      Body_Line
        ("      if Index = 0 then");
      Body_Line
        ("         Text := (1 => Simple_Upper (C), others => 0);");
      Body_Line
        ("         Count := 1;");
      Body_Line
        ("      else");
      Body_Line
        ("         Text := Special_Upper_Table (Index).Target;");
      Body_Line
        ("         Count := Special_Upper_Table (Index).Count;");
      Body_Line
        ("      end if;");
      Body_Line
        ("   end Full_Upper;");
      Body_Line;
      Body_Line
        ("   function Is_Cased (C : Code_Point) return Boolean is");
      Body_Line
        ("     (In_Spans (Cased_Table, C));");
      Body_Line;
      Body_Line
        ("   function Is_Case_Ignorable (C : Code_Point) return Boolean is");
      Body_Line
        ("     (In_Spans (Case_Ignorable_Table, C));");
      Body_Line;
      Body_Line ("end Anystrings_UCD_Case;");
   end Write_Body;

begin
   Read_Unicode_Data;
   Read_Special_Casing;
   Read_Derived_Core_Properties;

   Ada.Text_IO.Create (Out_Spec, Ada.Text_IO.Out_File, Output_Dir & "/anystrings_ucd_case.ads");
   Write_Spec;
   Ada.Text_IO.Close (Out_Spec);

   Ada.Text_IO.Create (Out_Body, Ada.Text_IO.Out_File, Output_Dir & "/anystrings_ucd_case.adb");
   Write_Body;
   Ada.Text_IO.Close (Out_Body);

   Ada.Text_IO.Put_Line
     ("ucd_generator: UCD " & Ucd_Version & ": simple lower"
      & Natural'Image (Natural (Simple_Lower_List.Length))
      & ", simple upper" & Natural'Image (Natural (Simple_Upper_List.Length))
      & ", special lower" & Natural'Image (Natural (Special_Lower_List.Length))
      & ", special upper" & Natural'Image (Natural (Special_Upper_List.Length))
      & ", cased" & Natural'Image (Natural (Cased_List.Length))
      & ", case-ignorable" & Natural'Image (Natural (Ignorable_List.Length)));
end Ucd_Generator;
