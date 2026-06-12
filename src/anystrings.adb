-------------------------------------------------------------------------------
--  Anystrings - Generic String Abstraction
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body Anystrings
  with SPARK_Mode => Off
is

   function Iterate_Env (Process : Env_Processor) return Boolean is
      procedure Process_Item (Name : String_Type; Value : String_Type) is
      begin
         Process.all (Name, Value);
      end Process_Item;
   begin
      return Environment_Iterate (Process_Item'Access);
   exception
      when others =>
         return False;
   end Iterate_Env;

   function Iterate_Env (Include : Env_Filter; Process : Env_Processor) return Boolean is
      procedure Process_Item (Name : String_Type; Value : String_Type) is
      begin
         if Include.all (Name, Value) then
            Process.all (Name, Value);
         end if;
      end Process_Item;
   begin
      return Environment_Iterate (Process_Item'Access);
   exception
      when others =>
         return False;
   end Iterate_Env;

   function Replace
     (Source  : String_Type;
      Pattern : String_Type;
      By      : String_Type) return String_Type
   is
      Src_Len : constant Natural := Length (Source);
      Pat_Len : constant Natural := Length (Pattern);
      Result  : String_Type := Null_String;
      Cursor  : Positive := 1;
      Found   : Natural;
   begin
      if Pat_Len = 0 or else Pat_Len > Src_Len then
         return Source;
      end if;

      loop
         Found := Index_From (Source, Pattern, Cursor);
         exit when Found = 0;

         if Found > Cursor then
            Result := Concat_Strings (Result, Slice (Source, Cursor, Found - 1));
         end if;
         Result := Concat_Strings (Result, By);

         Cursor := Found + Pat_Len;
         exit when Cursor > Src_Len;
      end loop;

      if Cursor <= Src_Len then
         Result := Concat_Strings (Result, Slice (Source, Cursor, Src_Len));
      end if;

      return Result;
   end Replace;

   function Head (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type is
      Src_Len : constant Natural := Length (Source);
   begin
      if Count = 0 then
         return Null_String;
      elsif Src_Len >= Count then
         return Slice (Source, 1, Count);
      else
         declare
            Result : String_Type := Source;
         begin
            for I in 1 .. Count - Src_Len loop
               Result := Concat_String_Character (Result, Pad);
            end loop;
            return Result;
         end;
      end if;
   end Head;

   function Tail (Source : String_Type; Count : Natural; Pad : Character_Type) return String_Type is
      Src_Len : constant Natural := Length (Source);
   begin
      if Count = 0 then
         return Null_String;
      elsif Src_Len >= Count then
         return Slice (Source, Src_Len - Count + 1, Src_Len);
      else
         declare
            Padding : String_Type := Null_String;
         begin
            for I in 1 .. Count - Src_Len loop
               Padding := Concat_String_Character (Padding, Pad);
            end loop;
            return Concat_Strings (Padding, Source);
         end;
      end if;
   end Tail;

end Anystrings;
