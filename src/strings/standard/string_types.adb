-------------------------------------------------------------------------------
--  String_Types - Standard String Configuration (bodies)
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

package body String_Types
  with SPARK_Mode
is

   function Simple_To_Lower (Source : String_Type) return String_Type
     with SPARK_Mode => Off
   is
   begin
      return Standard_String_Operations.Simple_To_Lower (Source);
   end Simple_To_Lower;

   procedure Append (Source : in out String_Type; New_Item : String_Type) is
   begin
      Source := Source & New_Item;
   end Append;

end String_Types;
