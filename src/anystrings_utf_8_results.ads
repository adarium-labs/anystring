-------------------------------------------------------------------------------
--  Anystrings_UTF_8_Results - Backend-parameterised decode-result type
--
--  Copyright (c) 2025
--  SPDX-License-Identifier: Apache-2.0
-------------------------------------------------------------------------------

--  @summary
--  Generic helper that produces a String_Type-aware UTF_8_Decode_Result.
--
--  @description
--  Instantiated once per backend (alongside Anystrings) so the discriminated
--  record body is written exactly once. The resulting record type and its
--  accessors are then passed as actuals to the Anystrings instantiation and
--  re-exported by string_types.ads.
--
--  Design: Strategy A' — shared enum + helper top-level generic + formal-type
--  passthrough. See docs/tech-specs/utf8-boundary-api.md §3 for rationale.
--  Top-level (not a child of Anystrings) to avoid the Ada rule that forbids
--  a parent package from naming its own children in a context clause.
--
--  Responsibilities:
--    * Declare the discriminated record UTF_8_Decode_Result parameterised
--      over an arbitrary String_Type.
--    * Provide SPARK-clean accessor expression functions with Pre contracts.
--    * Provide constructor helpers Make_Ok and Make_Error with Post contracts.
--
--  Requirements Coverage: FUNC-UTF8-002, NFR-UTF8-001, NFR-UTF8-002,
--                          NFR-UTF8-003, NFR-UTF8-009
--
--  External Effects: None
--  Thread Safety: N/A (no state)
--  SPARK Status: Compatible

--  @relation FUNC-UTF8-002, NFR-UTF8-001, NFR-UTF8-002, NFR-UTF8-003, NFR-UTF8-009

with Anystrings_UTF_8;

generic
   type String_Type is private;
   Null_String : String_Type;
package Anystrings_UTF_8_Results with SPARK_Mode is

   --  @summary Result of a UTF-8 decode operation; either Value or Reason.
   --
   --  @description
   --  Discriminated record with Boolean discriminant Is_Ok (default True).
   --  When Is_Ok = True, the Value component holds the decoded String_Type.
   --  When Is_Ok = False, the Reason component holds the error category.
   --  Access Value only when Is_Ok is True; access Reason only when Is_Ok
   --  is False. Use the accessor functions below (they carry Pre contracts).
   --
   --  @relation FUNC-UTF8-002
   type UTF_8_Decode_Result (Is_Ok : Boolean := True) is record
      case Is_Ok is
         when True =>
            Value : String_Type;

         when False =>
            Reason : Anystrings_UTF_8.UTF_8_Decode_Error;
      end case;
   end record;

   --  @summary True iff R carries a successfully decoded String_Type.
   --  @param R  The decode result to test.
   --  @return   True when the decode succeeded; False on error.
   --  @relation FUNC-UTF8-002, NFR-UTF8-002
   function Is_Ok (R : UTF_8_Decode_Result) return Boolean
   is (R.Is_Ok);

   --  @summary Extract the decoded value; requires Is_Ok (R).
   --
   --  @description
   --  Raises Constraint_Error at run time (or is verified statically by
   --  SPARK) if called when Is_Ok (R) = False.
   --
   --  @param R  A successful decode result.
   --  @return   The decoded String_Type value.
   --  @relation FUNC-UTF8-002, NFR-UTF8-002
   function Get_Value (R : UTF_8_Decode_Result) return String_Type
   is (R.Value)
   with Pre => Is_Ok (R);

   --  @summary Extract the failure category; requires not Is_Ok (R).
   --
   --  @description
   --  Raises Constraint_Error at run time (or is verified statically by
   --  SPARK) if called when Is_Ok (R) = True.
   --
   --  @param R  A failed decode result.
   --  @return   The UTF_8_Decode_Error variant describing the failure.
   --  @relation FUNC-UTF8-002, NFR-UTF8-002
   function Get_Error (R : UTF_8_Decode_Result) return Anystrings_UTF_8.UTF_8_Decode_Error
   is (R.Reason)
   with Pre => not Is_Ok (R);

   --  @summary Construct a successful Result carrying Value.
   --
   --  @param Value  The decoded String_Type to wrap.
   --  @return       A result with Is_Ok = True and Get_Value = Value.
   --  @relation FUNC-UTF8-002, NFR-UTF8-002
   function Make_Ok (Value : String_Type) return UTF_8_Decode_Result
   is ((Is_Ok => True, Value => Value))
   with Post => Is_Ok (Make_Ok'Result);

   --  @summary Construct a failure Result carrying Reason.
   --
   --  @param Reason  The error category to wrap.
   --  @return        A result with Is_Ok = False and Get_Error = Reason.
   --  @relation FUNC-UTF8-002, NFR-UTF8-002
   function Make_Error (Reason : Anystrings_UTF_8.UTF_8_Decode_Error) return UTF_8_Decode_Result
   is ((Is_Ok => False, Reason => Reason))
   with Post => not Is_Ok (Make_Error'Result);

end Anystrings_UTF_8_Results;
