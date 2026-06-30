-------------------------------------------------------------------------------
--  anystrings_width_demo.adb — Display-Width / Grapheme-Cluster API demo
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
--
--  Demonstrates the String_Types.Width opt-in child package end-to-end.
--  Build: cd examples && ANYSTRING_WITH_WIDTH=true alr build
--  Run:   bin/<backend>/anystrings_width_demo
--
--  @relation FUNC-WIDTH-003, FUNC-WIDTH-004, FUNC-WIDTH-005, FUNC-WIDTH-006,
--            FUNC-WIDTH-010, FUNC-WIDTH-011, FUNC-WIDTH-012, FUNC-WIDTH-013,
--            FUNC-WIDTH-014, FUNC-WIDTH-015, FUNC-WIDTH-016, NFR-WIDTH-003
-------------------------------------------------------------------------------

with Ada.Text_IO;        use Ada.Text_IO;
with String_Types;       use String_Types;
with String_Types.Width; use String_Types.Width;

procedure Anystrings_Width_Demo is

   --  Print backend-native Length, Display_Width, Grapheme_Count, and each cluster.
   procedure Show
     (Label : String;
      S     : String_Type;
      Conf  : Width_Configuration := Default_Linux)
   is
      Idx : Positive := 1;
   begin
      Put_Line ("  [" & Label & "]");
      Put_Line ("    native-Length=" & Natural'Image (Length (S))
        & "  Display_Width=" & Natural'Image (Display_Width (S, Conf))
        & "  Grapheme_Count=" & Natural'Image (Grapheme_Count (S, Conf)));
      for G of Graphemes (S, Conf) loop
         Put_Line ("      cluster" & Natural'Image (Idx)
           & ": width=" & Natural'Image (G.Width)
           & "  code_points=" & Natural'Image (G.Code_Points)
           & "  text=" & To_Latin_1 (G.Slice));
         Idx := Idx + 1;
      end loop;
   end Show;

   --  Decode a raw UTF-8 byte string into String_Type (portable across all backends).
   function From_Bytes (Bytes : String) return String_Type is
   begin
      return Get_Value_Or (From_UTF_8 (Bytes), To_String_Type (String'("?")));
   end From_Bytes;

   ---------------------------------------------------------------------------
   --  Corpus — six strings of interest
   ---------------------------------------------------------------------------

   --  1. "héllo" — é = U+00E9 (UTF-8: C3 A9). Built via From_Bytes so the
   --     stored bytes are valid UTF-8 on every backend: uxstring's
   --     To_String_Type is From_UTF_8 (not Latin-1) and standard's is
   --     byte-identity, so a raw 0xE9 byte would crash strict UTF-8 walks.
   S_Hello : constant String_Type := From_Bytes
     ("h" & Character'Val (16#C3#) & Character'Val (16#A9#) & "llo");

   --  2. "café" — same rationale as S_Hello.
   S_Cafe : constant String_Type := From_Bytes
     ("caf" & Character'Val (16#C3#) & Character'Val (16#A9#));

   --  3. "日本語" — 3 CJK ideographs, each width 2 (UTF-8: E6 97 A5 E6 9C AC E8 AA 9E)
   S_Japanese : constant String_Type := From_Bytes
     (String'(Character'Val (16#E6#), Character'Val (16#97#), Character'Val (16#A5#),
              Character'Val (16#E6#), Character'Val (16#9C#), Character'Val (16#AC#),
              Character'Val (16#E8#), Character'Val (16#AA#), Character'Val (16#9E#)));

   --  4. "👨‍👩‍👧" — ZWJ family sequence (3 emoji + 2 ZWJ = 1 cluster, width 2)
   S_Family : constant String_Type := From_Bytes
     (String'(Character'Val (16#F0#), Character'Val (16#9F#),
              Character'Val (16#91#), Character'Val (16#A8#),   --  U+1F468 man
              Character'Val (16#E2#), Character'Val (16#80#), Character'Val (16#8D#),  --  ZWJ
              Character'Val (16#F0#), Character'Val (16#9F#),
              Character'Val (16#91#), Character'Val (16#A9#),   --  U+1F469 woman
              Character'Val (16#E2#), Character'Val (16#80#), Character'Val (16#8D#),  --  ZWJ
              Character'Val (16#F0#), Character'Val (16#9F#),
              Character'Val (16#91#), Character'Val (16#A7#)));  --  U+1F467 girl

   --  5. "👋🏿" — wave hand (U+1F44B) + dark skin-tone modifier (U+1F3FF)
   --     With Honor_Emoji_Modifiers=True (default): 1 cluster, width 2.
   --     With Honor_Emoji_Modifiers=False:          2 clusters, width 4.
   S_Wave : constant String_Type := From_Bytes
     (String'(Character'Val (16#F0#), Character'Val (16#9F#),
              Character'Val (16#91#), Character'Val (16#8B#),   --  U+1F44B wave
              Character'Val (16#F0#), Character'Val (16#9F#),
              Character'Val (16#8F#), Character'Val (16#BF#)));  --  U+1F3FF dark tone

   --  6. Decomposed "é": base e (U+0065) + combining acute accent (U+0301)
   --     UTF-8: 65 CC 81 — 2 code points, 1 grapheme cluster, width 1
   S_Combining : constant String_Type := From_Bytes
     (String'(Character'Val (16#65#),
              Character'Val (16#CC#), Character'Val (16#81#)));

begin

   Put_Line ("=== anystrings_width_demo ===");

   ---------------------------------------------------------------------------
   --  Section 1: per-string scalar queries + grapheme-cluster breakdown
   --  @relation FUNC-WIDTH-003, FUNC-WIDTH-004, FUNC-WIDTH-005, FUNC-WIDTH-010
   ---------------------------------------------------------------------------
   New_Line;
   Put_Line ("--- 1: per-string stats and grapheme breakdown (Default_Linux) ---");
   Show ("hello (h + e-acute + llo)",       S_Hello);
   Show ("cafe  (c-a-f + e-acute)",          S_Cafe);
   Show ("Nihongo (3 fullwidth CJK)",        S_Japanese);
   Show ("ZWJ family emoji (1 cluster)",     S_Family);
   Show ("wave+skin-tone (modifiers=True)",  S_Wave);
   Show ("decomposed e+U+0301 (1 cluster)",  S_Combining);

   ---------------------------------------------------------------------------
   --  Section 2: Cluster_Element and Cluster_Slice on S_Hello and S_Cafe
   --  @relation FUNC-WIDTH-011, FUNC-WIDTH-012
   ---------------------------------------------------------------------------
   New_Line;
   Put_Line ("--- 2: Cluster_Element / Cluster_Slice ---");
   declare
      G1H  : constant Grapheme    := Cluster_Element (S_Hello, 1);
      G1C  : constant Grapheme    := Cluster_Element (S_Cafe,  1);
      Sl_H : constant String_Type := Cluster_Slice (S_Hello, 1, 2);
      Sl_C : constant String_Type := Cluster_Slice (S_Cafe,  1, 2);
   begin
      Put_Line ("  Cluster_Element (hello, 1): w=" & Natural'Image (G1H.Width)
        & "  text=" & To_Latin_1 (G1H.Slice));
      Put_Line ("  Cluster_Element (cafe,  1): w=" & Natural'Image (G1C.Width)
        & "  text=" & To_Latin_1 (G1C.Slice));
      Put_Line ("  Cluster_Slice   (hello, 1..2): " & To_Latin_1 (Sl_H));
      Put_Line ("  Cluster_Slice   (cafe,  1..2): " & To_Latin_1 (Sl_C));
   end;

   ---------------------------------------------------------------------------
   --  Section 3: width-budget helpers — Head_By_Width, Truncate, Pad
   --  @relation FUNC-WIDTH-014, FUNC-WIDTH-015, FUNC-WIDTH-016
   ---------------------------------------------------------------------------
   New_Line;
   Put_Line ("--- 3: Head_By_Width / Truncate_With_Ellipsis / Pad_To_Width ---");
   declare
      RH  : constant Width_Slice_Result := Head_By_Width (S_Hello, 5);
      RC  : constant Width_Slice_Result := Head_By_Width (S_Cafe,  3);
      TrH : constant String_Type := Truncate_With_Ellipsis (S_Hello, 4);
      TrC : constant String_Type := Truncate_With_Ellipsis (S_Cafe,  4);
      PH  : constant String_Type := Pad_To_Width (S_Hello, 10, ' ', Right);
      PC  : constant String_Type := Pad_To_Width (S_Cafe,  10, ' ', Right);
   begin
      Put_Line ("  Head_By_Width (hello, 5):  [" & To_Latin_1 (RH.Result)
        & "]  w=" & Natural'Image (RH.Width) & "  trunc=" & Boolean'Image (RH.Truncated));
      Put_Line ("  Head_By_Width (cafe,  3):  [" & To_Latin_1 (RC.Result)
        & "]  w=" & Natural'Image (RC.Width) & "  trunc=" & Boolean'Image (RC.Truncated));
      Put_Line ("  Truncate_With_Ellipsis (hello, 4): ["
        & To_Latin_1 (TrH) & "]  w=" & Natural'Image (Display_Width (TrH)));
      Put_Line ("  Truncate_With_Ellipsis (cafe,  4): ["
        & To_Latin_1 (TrC) & "]  w=" & Natural'Image (Display_Width (TrC)));
      Put_Line ("  Pad_To_Width (hello, 10, Right): [" & To_Latin_1 (PH) & "]");
      Put_Line ("  Pad_To_Width (cafe,  10, Right): [" & To_Latin_1 (PC) & "]");
   end;

   ---------------------------------------------------------------------------
   --  Section 4: Honor_Emoji_Modifiers toggle on wave + dark skin-tone
   --  @relation FUNC-WIDTH-006, NFR-WIDTH-003
   ---------------------------------------------------------------------------
   New_Line;
   Put_Line ("--- 4: Honor_Emoji_Modifiers toggle (wave + dark skin-tone) ---");
   Show ("wave+skin  Honor_Emoji_Modifiers=True  (Default_Linux)",
         S_Wave,
         Default_Linux);
   Show ("wave+skin  Honor_Emoji_Modifiers=False (custom conf)",
         S_Wave,
         (Honor_Emoji_Modifiers => False, others => <>));

   ---------------------------------------------------------------------------
   --  Section 5: Width_Configuration comparison on "café"
   --  @relation FUNC-WIDTH-006, NFR-WIDTH-003
   ---------------------------------------------------------------------------
   New_Line;
   Put_Line ("--- 5: Width_Configuration comparison (cafe) ---");
   Put_Line ("  Default_Linux  (Context=Narrow, Reject_Illegal=False): Display_Width="
     & Natural'Image (Display_Width (S_Cafe, Default_Linux)));
   Put_Line ("  Default_Strict (Context=Narrow, all strict=True):      Display_Width="
     & Natural'Image (Display_Width (S_Cafe, Default_Strict)));
   Put_Line ("  (Context => Wide, others => <>):                       Display_Width="
     & Natural'Image (Display_Width (S_Cafe, (Context => Wide, others => <>))));

   New_Line;
   Put_Line ("anystrings_width_demo: ALL-OK");

end Anystrings_Width_Demo;
