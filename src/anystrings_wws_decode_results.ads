--  Anystrings_WWS_Decode_Results - Backend-parameterised WWS decode result
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0

--  @summary
--  Generic helper that produces a String_Type-aware WWS_Decode_Result.
--
--  @description
--  Mirrors the Anystrings_UTF_8_Results pattern: instantiated once per
--  backend so the discriminated record body is written exactly once.
--  The resulting record type and its accessors are then supplied as
--  actuals to the Anystrings instantiation and re-exported by
--  string_types.ads.
--
--  Responsibilities:
--    * Declare the discriminated record WWS_Decode_Result parameterised
--      over an arbitrary String_Type.
--    * Provide SPARK-clean accessor expression functions with Pre / Post.
--    * Provide constructor helpers Make_Ok / Make_Error.
--
--  External Effects: None
--  Thread Safety: N/A (no state)
--  SPARK Status: Compatible

with Anystrings_Invalid_Policy;

generic
   type String_Type is private;
   Null_String : String_Type;
package Anystrings_WWS_Decode_Results
  with SPARK_Mode
is

   --  @summary Result of a Wide_Wide_String -> String_Type decode with
   --  policy Report_As_Error. Either the decoded String_Type or the first
   --  encountered failure.
   --
   --  @description
   --  Discriminated record with Boolean discriminant Is_Ok (default True).
   --  When Is_Ok = True, the Value component holds the decoded String_Type.
   --  When Is_Ok = False, the Error component holds the failure descriptor.
   --  Access Value only when Is_Ok is True; access Error only when Is_Ok
   --  is False. Use the accessor functions below (they carry Pre contracts).
   type WWS_Decode_Result (Is_Ok : Boolean := True) is record
      case Is_Ok is
         when True =>
            Value : String_Type;

         when False =>
            Error : Anystrings_Invalid_Policy.WWS_Failure;
      end case;
   end record;

   --  @summary True iff R carries a successfully decoded String_Type.
   function Is_Ok (R : WWS_Decode_Result) return Boolean
   is (R.Is_Ok);

   --  @summary Extract the decoded value; requires Is_Ok (R).
   function Get_Value (R : WWS_Decode_Result) return String_Type
   is (R.Value)
   with Pre => Is_Ok (R);

   --  @summary Extract the failure descriptor; requires not Is_Ok (R).
   function Get_Error (R : WWS_Decode_Result) return Anystrings_Invalid_Policy.WWS_Failure
   is (R.Error)
   with Pre => not Is_Ok (R);

   --  @summary Extract the decoded value, or return Fallback on failure.
   --
   --  @description
   --  Unconditional accessor: no precondition, never raises. Mirrors
   --  UTF_8_Decode_Result.Get_Value_Or for API symmetry.
   function Get_Value_Or
     (R        : WWS_Decode_Result;
      Fallback : String_Type) return String_Type
   is (if R.Is_Ok then R.Value else Fallback)
   with Post =>
     (if Is_Ok (R) then Get_Value_Or'Result = Get_Value (R)
      else Get_Value_Or'Result = Fallback);

   --  @summary Construct a successful Result carrying Value.
   function Make_Ok (Value : String_Type) return WWS_Decode_Result
   is ((Is_Ok => True, Value => Value))
   with Post => Is_Ok (Make_Ok'Result);

   --  @summary Construct a failure Result carrying Error.
   function Make_Error (Error : Anystrings_Invalid_Policy.WWS_Failure) return WWS_Decode_Result
   is ((Is_Ok => False, Error => Error))
   with Post => not Is_Ok (Make_Error'Result);

end Anystrings_WWS_Decode_Results;
