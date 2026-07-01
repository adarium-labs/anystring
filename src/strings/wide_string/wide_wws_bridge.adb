--  Wide_WWS_Bridge - body
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

with Anystrings_Invalid_Policy;
with Wide_String_Operations;

package body Wide_WWS_Bridge is

   function From_Wide_Wide_String_Wide_Checked
     (Source : Wide_Wide_String) return Wide_WWS_Decode_Results.WWS_Decode_Result
   is
   begin
      for I in Source'Range loop
         declare
            CP : constant Natural := Wide_Wide_Character'Pos (Source (I));
         begin
            if CP in 16#D800# .. 16#DFFF# then
               return Wide_WWS_Decode_Results.Make_Error
                 (Anystrings_Invalid_Policy.WWS_Failure'
                    (Kind  => Anystrings_Invalid_Policy.Surrogate_Codepoint,
                     Index => I - Source'First + 1,
                     Value => Source (I)));
            elsif CP > 16#10_FFFF# then
               return Wide_WWS_Decode_Results.Make_Error
                 (Anystrings_Invalid_Policy.WWS_Failure'
                    (Kind  => Anystrings_Invalid_Policy.Out_Of_Range_Codepoint,
                     Index => I - Source'First + 1,
                     Value => Source (I)));
            end if;
         end;
      end loop;
      return Wide_WWS_Decode_Results.Make_Ok
        (Wide_String_Operations.From_Wide_Wide_String_Skip_Invalid (Source));
   end From_Wide_Wide_String_Wide_Checked;

end Wide_WWS_Bridge;
