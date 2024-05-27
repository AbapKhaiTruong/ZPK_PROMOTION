*----------------------------------------------------------------------*
* Citek JSC.
* (C) Copyright Citek JSC.
* All Rights Reserved
*----------------------------------------------------------------------*
* Program Summary: Extend Sales Order Behavior
* Creation Date: 10.04.2024
* Created by: NganNM
*----------------------------------------------------------------------*
CLASS lhc_salesorderitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR salesorderitem RESULT result.

    METHODS zzchoosepromotionitem FOR MODIFY
      IMPORTING keys FOR ACTION salesorderitem~zzchoosepromotionitem RESULT result.

    METHODS precheck_zzchoosepromotionitem FOR PRECHECK
      IMPORTING keys FOR ACTION salesorderitem~zzchoosepromotionitem.

ENDCLASS.

CLASS lhc_salesorderitem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD zzchoosepromotionitem.

    LOOP AT keys REFERENCE INTO DATA(key).
      READ ENTITIES OF i_salesordertp IN LOCAL MODE
      ENTITY salesorderitem BY \_salesorder ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_so).

      READ ENTITIES OF i_salesordertp IN LOCAL MODE
      ENTITY salesorder BY \_item ALL FIELDS WITH CORRESPONDING #(  keys  ) RESULT DATA(lt_item).

      LOOP AT lt_so REFERENCE INTO DATA(ls_so).

*       Xử lý lấy promotion thoả điều kiện
        zpro_cl_calculation=>get_eligible_promotion(
        EXPORTING
            is_salesorder =  CORRESPONDING i_salesordertp( ls_so->* )
            it_salesorderitem = CORRESPONDING zpro_cl_calculation=>t_salesordetitem( lt_item )
            iv_protyp = 'Z1' "Chiết khấu trực tiếp
            iv_propt = '1' "Manual
            iv_pronr = key->%param-zz_pronr_sdh
        IMPORTING
            et_promotion = DATA(lt_promotion)
            et_add_foc = DATA(lt_add_foc) ) .

        LOOP AT lt_add_foc REFERENCE INTO DATA(ls_add_foc).
          MODIFY ENTITIES OF i_salesordertp IN LOCAL MODE
          ENTITY salesorder
          CREATE BY \_item SET FIELDS WITH VALUE #(
          ( %tky      = key->%tky
            %target   = VALUE #( (
              %cid    = |{ zpro_cl_calculation=>cid_freegood }{ ls_add_foc->salesorderitem }|
              product = ls_add_foc->product
              zz_pronr_sdi = ls_add_foc->pronr
              zz_profoc_ind_sdi = abap_true
              zz_pro_higherlvl_sdi = ls_add_foc->highersoitem
              requestedquantity = ls_add_foc->orderquantity
              requestedquantityunit = ls_add_foc->orderunit  ) ) ) )
          FAILED   DATA(ls_modify_failed)
          REPORTED DATA(ls_modify_reported).
        ENDLOOP.
      ENDLOOP.


*      LOOP AT lt_so REFERENCE INTO DATA(ls_so).
*        READ ENTITIES OF i_salesordertp IN LOCAL MODE
*        ENTITY salesorder BY \_item ALL FIELDS  WITH VALUE #( ( %tky = ls_so->%tky ) ) RESULT DATA(lt_item).
*
**       Xử lý lấy promotion thoả điều kiện
*        zpro_cl_calculation=>get_eligible_promotion(
*        EXPORTING
*            is_salesorder =  CORRESPONDING i_salesordertp( ls_so->* )
*            it_salesorderitem = CORRESPONDING zpro_cl_calculation=>t_salesordetitem( lt_item )
*            iv_protyp = 'Z1' "Chiết khấu trực tiếp
*            iv_propt = '1' "Manual
*            iv_pronr = key->%param-zz_pronr_sdh
*        IMPORTING
*            et_promotion = DATA(lt_promotion)
*            et_add_foc = DATA(lt_add_foc) ) .
*
*        LOOP AT lt_add_foc REFERENCE INTO DATA(ls_add_foc).
*          MODIFY ENTITIES OF i_salesordertp IN LOCAL MODE
*          ENTITY salesorder
*          CREATE BY \_item SET FIELDS WITH VALUE #(
*          ( %tky      = key->%tky
*            %target   = VALUE #( (
*              %cid    = |{ zpro_cl_calculation=>cid_freegood }{ ls_add_foc->salesorderitem }|
*              product = ls_add_foc->product
*              zz_pro_higherlvl_sdi = ls_add_foc->highersoitem
*              requestedquantity = ls_add_foc->orderquantity
*              requestedquantityunit = ls_add_foc->orderunit  ) ) ) )
*          FAILED   DATA(ls_modify_failed)
*          REPORTED DATA(ls_modify_reported).
*        ENDLOOP.
*      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.

  METHOD precheck_zzchoosepromotionitem.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_salesorder DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR salesorder RESULT result.
    METHODS zzfindavailabepromotion FOR MODIFY
      IMPORTING keys FOR ACTION salesorder~zzfindavailabepromotion.
    METHODS zzchoosepromotion FOR MODIFY
      IMPORTING keys FOR ACTION salesorder~zzchoosepromotion RESULT result.
    METHODS precheck_zzchoosepromotion FOR PRECHECK
      IMPORTING keys FOR ACTION salesorder~zzchoosepromotion.

ENDCLASS.

CLASS lhc_salesorder IMPLEMENTATION.
  METHOD get_instance_features.
  ENDMETHOD.

  METHOD zzfindavailabepromotion.
    LOOP AT keys REFERENCE INTO DATA(key).
      READ ENTITIES OF i_salesordertp IN LOCAL MODE
      ENTITY salesorder ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_so).

      LOOP AT lt_so REFERENCE INTO DATA(ls_so).
        READ ENTITIES OF i_salesordertp IN LOCAL MODE
        ENTITY salesorder BY \_item ALL FIELDS  WITH VALUE #( ( %tky = ls_so->%tky ) ) RESULT DATA(lt_item).

*       Xử lý lấy promotion thoả điều kiện
        zpro_cl_calculation=>get_eligible_promotion(
        EXPORTING
            is_salesorder =  CORRESPONDING i_salesordertp( ls_so->* )
            it_salesorderitem = CORRESPONDING zpro_cl_calculation=>t_salesordetitem( lt_item )
            iv_protyp = 'Z1' "Chiết khấu trực tiếp
            iv_propt = '1' "Manual
        IMPORTING
            et_promotion = DATA(lt_promotion)
            et_add_foc = DATA(lt_add_foc) ) .
        LOOP AT lt_promotion REFERENCE INTO DATA(ls_pro).
          APPEND VALUE #( %key = key->%key %state_area = zpro_cl_calculation=>state_message
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-information
                                                        text = |Đủ điều kiện cho { ls_pro->prodes }| ) ) TO reported-salesorder.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD zzchoosepromotion.
    LOOP AT keys REFERENCE INTO DATA(key).
      READ ENTITIES OF i_salesordertp IN LOCAL MODE
      ENTITY salesorder ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_so).

      LOOP AT lt_so REFERENCE INTO DATA(ls_so).
        READ ENTITIES OF i_salesordertp IN LOCAL MODE
        ENTITY salesorder BY \_item ALL FIELDS  WITH VALUE #( ( %tky = ls_so->%tky ) ) RESULT DATA(lt_item).

*       Xử lý lấy promotion thoả điều kiện
        zpro_cl_calculation=>get_eligible_promotion(
        EXPORTING
            is_salesorder =  CORRESPONDING i_salesordertp( ls_so->* )
            it_salesorderitem = CORRESPONDING zpro_cl_calculation=>t_salesordetitem( lt_item )
            iv_protyp = 'Z1' "Chiết khấu trực tiếp
            iv_propt = '1' "Manual
            iv_pronr = key->%param-zz_pronr_sdh
        IMPORTING
            et_promotion = DATA(lt_promotion)
            et_add_foc = DATA(lt_add_foc) ) .

        LOOP AT lt_add_foc REFERENCE INTO DATA(ls_add_foc).
          MODIFY ENTITIES OF i_salesordertp IN LOCAL MODE
          ENTITY salesorder
          CREATE BY \_item SET FIELDS WITH VALUE #(
          ( %tky      = key->%tky
            %target   = VALUE #( (
              %cid    = |{ zpro_cl_calculation=>cid_freegood }{ ls_add_foc->salesorderitem }|
              product = ls_add_foc->product
              zz_pro_higherlvl_sdi = ls_add_foc->highersoitem
              requestedquantity = ls_add_foc->orderquantity
              requestedquantityunit = ls_add_foc->orderunit  ) ) ) )
          FAILED   DATA(ls_modify_failed)
          REPORTED DATA(ls_modify_reported).
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_zzchoosepromotion.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_r_salesordertp DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS cleanup_finalize REDEFINITION.

    METHODS map_messages REDEFINITION.

ENDCLASS.

CLASS lsc_r_salesordertp IMPLEMENTATION.

  METHOD cleanup_finalize.
  ENDMETHOD.

  METHOD map_messages.
  ENDMETHOD.

ENDCLASS.
