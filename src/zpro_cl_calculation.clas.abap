*----------------------------------------------------------------------*
* Citek JSC.
* (C) Copyright Citek JSC.
* All Rights Reserved
*----------------------------------------------------------------------*
* Program Summary: Calculation for ZPRO
* Creation Date: 10.04.2024
* Created by: NganNM
*----------------------------------------------------------------------*

CLASS zpro_cl_calculation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      cid_freegood  TYPE c LENGTH 20 VALUE 'ZPRO_ADDFOC',
      state_message TYPE string VALUE 'ZPRO_SUGGEST',

      BEGIN OF calrule,
        unit_reference TYPE c LENGTH 1 VALUE '1',
        repeat         TYPE c LENGTH 1 VALUE '2',
        total          TYPE c LENGTH 1 VALUE '3',
      END OF calrule.

    TYPES:
      t_salesordetitem TYPE TABLE OF i_salesorderitemtp,
      t_promotion      TYPE TABLE OF zpro_i_header,
      BEGIN OF ty_eligible_pro,
        pronr   TYPE zde_pronr,
        prodes  TYPE zde_prodes,
        calrule TYPE zde_calrule,
        valid   TYPE abap_boolean,
      END OF ty_eligible_pro,
      BEGIN OF ty_add_foc,
        pronr          TYPE zde_pronr,
        salesorderitem TYPE n LENGTH 6,
        highersoitem   TYPE n LENGTH 6,
        product        TYPE matnr,
        orderquantity  TYPE menge_d,
        orderunit      TYPE meins,
      END OF ty_add_foc,
      t_add_foc TYPE TABLE OF ty_add_foc.

    CLASS-DATA:
      go_tabledescr TYPE REF TO cl_abap_tabledescr,
      gv_select     TYPE string.

    CLASS-METHODS : get_eligible_promotion IMPORTING is_salesorder     TYPE i_salesordertp
                                                     it_salesorderitem TYPE t_salesordetitem
                                                     iv_protyp         TYPE zde_protyp
                                                     iv_propt          TYPE zde_propt
                                                     iv_pronr          TYPE zde_pronr OPTIONAL
                                           EXPORTING et_promotion      TYPE t_promotion
                                                     et_add_foc        TYPE t_add_foc.
    CLASS-METHODS:
      get_dynamic IMPORTING iv_protyp         TYPE zde_protyp.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZPRO_CL_CALCULATION IMPLEMENTATION.


  METHOD get_dynamic.

*--> For query

*--> For structure
    DATA: lo_type        TYPE REF TO cl_abap_typedescr,
          lt_components  TYPE abap_component_tab,
          ls_component   TYPE abap_componentdescr,
          lo_structdescr TYPE REF TO cl_abap_structdescr.

    SELECT
        protyp,
        cond_type,
        fieldname
    FROM zpro_tb_matconty
    WHERE protyp = @iv_protyp
    INTO TABLE @DATA(lt_matconty).

    LOOP AT lt_matconty REFERENCE INTO DATA(ls_matconty).

*---> create structure
      ls_component-name = ls_matconty->fieldname.
      cl_abap_elemdescr=>describe_by_name(
        EXPORTING
            p_name = |ZPRO_A_CHOOSEPROMOTIONIT-{ ls_matconty->fieldname }|
        RECEIVING
            p_descr_ref = lo_type
        EXCEPTIONS
            type_not_found = 1
            OTHERS         = 2  ).
      IF sy-subrc =  1.
        CONTINUE.
      ENDIF.
      ls_component-type ?= lo_type .
      APPEND ls_component TO lt_components.
*------------------------------------------------------
      ls_component-name = |total{ ls_matconty->fieldname }| .
      cl_abap_elemdescr=>describe_by_name(
        EXPORTING
            p_name = |ZPRO_I_PROMOTIONVH-minval|
        RECEIVING
            p_descr_ref = lo_type
        EXCEPTIONS
            type_not_found = 1
            OTHERS         = 2  ).
      IF sy-subrc =  1.
        CONTINUE.
      ENDIF.
      ls_component-type ?= lo_type .
      APPEND ls_component TO lt_components.
*------------------------------------------------------

*---> create query
      IF gv_select IS INITIAL.
        gv_select = |{ ls_matconty->fieldname },|
                 && |sum( requestedquantity ) over( partition by { ls_matconty->fieldname } ) as total{ ls_matconty->fieldname }|.
      ELSE.
        gv_select = |{ gv_select }, { ls_matconty->fieldname },|
                 && |sum( requestedquantity ) over( partition by { ls_matconty->fieldname } ) as total{ ls_matconty->fieldname }|.
      ENDIF.

    ENDLOOP.
    lo_structdescr ?= cl_abap_structdescr=>create( lt_components ).
    go_tabledescr ?= cl_abap_tabledescr=>create( lo_structdescr ).


  ENDMETHOD.


  METHOD get_eligible_promotion.

    DATA:
      lt_so      TYPE TABLE OF i_salesordertp,
      lt_vbap    TYPE t_salesordetitem,
      lt_pro     TYPE TABLE OF ty_eligible_pro,
      lt_gencond TYPE TABLE OF zpro_tb_gencond,
      lt_proitem TYPE TABLE OF zpro_tb_item,
      lt_pisubco TYPE TABLE OF zpro_tb_pisubco,
      lr_pronr   TYPE RANGE OF zde_pronr.

    DATA:
        lt_ref_data    TYPE REF TO data.


    DATA(lr_salesorder) = REF #( is_salesorder ).

    IF iv_pronr IS SUPPLIED .
      lr_pronr =  VALUE #( ( sign = 'I' option = 'EQ' low = iv_pronr ) ).
    ENDIF.

    lt_vbap = CORRESPONDING #( it_salesorderitem ).
    get_dynamic( 'Z1' ).
    CREATE DATA lt_ref_data TYPE HANDLE go_tabledescr.

    SELECT
     (gv_select)
    FROM @it_salesorderitem AS vbap
    INTO  CORRESPONDING FIELDS OF TABLE @lt_ref_data->*.

    SELECT
        zpro_tb_header~*
    FROM zpro_tb_header
    WHERE protyp = @iv_protyp
      AND propt = @iv_propt
      AND validfrom <= @is_salesorder-pricingdate
      AND validto >= @is_salesorder-pricingdate
      AND pronr IN @lr_pronr
    ORDER BY zpro_tb_header~pronr
    INTO CORRESPONDING FIELDS OF TABLE @lt_pro .
    IF sy-subrc = 0.
      SELECT
          zpro_tb_gencond~*
      FROM zpro_tb_gencond
      INNER JOIN @lt_pro AS data ON data~pronr = zpro_tb_gencond~pronr
      ORDER BY zpro_tb_gencond~pronr, zpro_tb_gencond~stt
      INTO CORRESPONDING FIELDS OF TABLE @lt_gencond.

      SELECT
          zpro_tb_item~*
      FROM zpro_tb_item
      INNER JOIN @lt_pro AS data ON data~pronr = zpro_tb_item~pronr
      ORDER BY zpro_tb_item~pronr
      INTO CORRESPONDING FIELDS OF TABLE @lt_proitem.

      SELECT
          zpro_tb_pisubco~*
      FROM zpro_tb_pisubco
      INNER JOIN @lt_pro AS data ON data~pronr = zpro_tb_pisubco~pronr
      ORDER BY zpro_tb_pisubco~pronr, zpro_tb_pisubco~proit
      INTO CORRESPONDING FIELDS OF TABLE @lt_pisubco.

      DATA:
        lv_where       TYPE string,
        lv_final_where TYPE string.

      LOOP AT lt_pro REFERENCE INTO DATA(ls_pro).
        ls_pro->valid = abap_true.

*------> Check thoả điều kiện general condition
        READ TABLE lt_gencond TRANSPORTING NO FIELDS
        WITH KEY pronr = ls_pro->pronr BINARY SEARCH.
        IF sy-subrc = 0.
          CLEAR : lv_where, lv_final_where.
          LOOP AT lt_gencond REFERENCE INTO DATA(ls_gencond) FROM sy-tabix.
            IF ls_gencond->pronr <> ls_pro->pronr.
              EXIT.
            ENDIF.
            IF lv_where IS INITIAL.
              lv_where = |{ ls_gencond->fieldname } { ls_gencond->opti } { ls_gencond->cond_val }|.
            ELSE.
              lv_where = |{ lv_where } AND { ls_gencond->fieldname } { ls_gencond->opti } { ls_gencond->cond_val }|.
            ENDIF.

            AT END OF stt.
              IF lv_final_where IS INITIAL.
                lv_final_where = |( { lv_where } )|.
              ELSE.
                lv_final_where = |{ lv_final_where } OR ( { lv_where } )|.
              ENDIF.
              CLEAR lv_where.
            ENDAT.
          ENDLOOP.
          APPEND is_salesorder TO lt_so.
          LOOP AT lt_so REFERENCE INTO DATA(ls_salesoderitem) WHERE (lv_final_where).
            EXIT.
          ENDLOOP.
          IF sy-subrc <> 0. "Thoả điều kiện general condition
            ls_pro->valid = abap_false.
            CONTINUE.
          ENDIF.
        ENDIF.

*------> check item condition
* Check từng pro item
* -> xét pro item là custom group hay single type
* --> nếu là custom group : ->
        DATA:
          lv_addfoccount TYPE n LENGTH 6,
          is_eligible    TYPE abap_boolean.

        READ TABLE lt_proitem TRANSPORTING NO FIELDS
        WITH KEY pronr = ls_pro->pronr BINARY SEARCH.
        IF sy-subrc = 0.
          DATA(lv_tabix) = sy-tabix.

          LOOP AT lt_vbap REFERENCE INTO DATA(ls_vbap).

            LOOP AT lt_proitem REFERENCE INTO DATA(ls_proitem) FROM lv_tabix.
              is_eligible = abap_true.
              IF ls_proitem->pronr <> ls_pro->pronr.
                EXIT.
              ENDIF.

              CASE ls_proitem->cond_type.
                WHEN zpro_if_constants=>cond_type-customer_group.
                  is_eligible = abap_true.
                  READ TABLE lt_pisubco TRANSPORTING NO FIELDS
                  WITH KEY pronr = ls_pro->pronr proit = ls_proitem->proit .
                  IF sy-subrc = 0.
                    LOOP AT lt_pisubco REFERENCE INTO DATA(ls_pisubcp) FROM sy-tabix.
                      IF ls_pisubcp->pronr <> ls_pro->pronr
                      OR ls_pisubcp->proit <> ls_proitem->proit.
                        EXIT.
                      ENDIF.
                      IF NOT ( ls_vbap->(ls_pisubcp->fieldname) IS BOUND AND ls_vbap->(ls_pisubcp->fieldname) =  ls_pisubcp->cond_val )
                      AND ls_vbap->requestedquantity < ls_pisubcp->minval .
                        is_eligible = abap_false.
                        EXIT.
                      ENDIF.
                    ENDLOOP.
                  ENDIF.
                WHEN OTHERS.
                  IF NOT ( ls_vbap->(ls_proitem->fieldname) IS BOUND AND ls_vbap->(ls_proitem->fieldname) =  ls_proitem->cond_val )
                  AND ls_vbap->requestedquantity <  ls_proitem->minval .
                    is_eligible = abap_false.
                  ENDIF.
              ENDCASE.

              IF is_eligible = abap_true.

              ENDIF.

            ENDLOOP.
          ENDLOOP.
*          LOOP AT lt_vbap REFERENCE INTO DATA(ls_vbap).
*            CLEAR: lv_addfoccount.
*            LOOP AT lt_proitem REFERENCE INTO DATA(ls_proitem) FROM lv_tabix.
*              IF ls_proitem->pronr <> ls_pro->pronr.
*                EXIT.
*              ENDIF.
*              is_eligible =  abap_false.
*              IF  ls_vbap->requestedquantity >= ls_proitem->minval AND ls_vbap->(ls_proitem->fieldname) = ls_proitem->cond_val.
*                lv_addfoccount += 1.
*                APPEND INITIAL LINE TO et_add_foc REFERENCE INTO DATA(ls_add_foc).
*                ls_add_foc->pronr = ls_pro->pronr.
*                ls_add_foc->highersoitem = ls_vbap->salesorderitem.
*                ls_add_foc->product = ls_proitem->matnr_fg1.
*                ls_add_foc->salesorderitem = lv_addfoccount + ls_vbap->salesorderitem.
*                ls_add_foc->orderquantity = ( ls_proitem->foreach * ls_proitem->addfg1 ) * ( ls_vbap->requestedquantity / ls_proitem->minval ).
*                ls_add_foc->orderunit = ls_proitem->unitfg1.
*                is_eligible = abap_true.
*              ENDIF.
*
*              IF is_eligible = abap_true.
*                CASE ls_pro->calrule.
*                  WHEN calrule-unit_reference.
*                    EXIT.
*                  WHEN calrule-repeat.
*                    ls_vbap->requestedquantity = ls_vbap->requestedquantity - ls_add_foc->orderquantity.
*                  WHEN calrule-total.
*                    "do nothing
*                ENDCASE.
*              ENDIF.
*            ENDLOOP.
*          ENDLOOP.
        ENDIF.
      ENDLOOP.

      DELETE lt_pro WHERE valid = abap_false.
      et_promotion = CORRESPONDING #( lt_pro ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
