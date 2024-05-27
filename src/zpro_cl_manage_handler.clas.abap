CLASS zpro_cl_manage_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    CONSTANTS: BEGIN OF state,
                 valid_date_proitem TYPE string VALUE 'valid_date_proitem',
                 valid_date_prohead TYPE string VALUE 'valid_date_prohead',
               END OF state.
    CONSTANTS: gc_message_class TYPE symsgid VALUE 'ZPRO'.

    CLASS-METHODS:
      get_instance
        RETURNING VALUE(ro_handler) TYPE REF TO zpro_cl_manage_handler,
      refresh.


    METHODS set_header_for_create
      IMPORTING
        is_header TYPE zpro_tb_header_d.

    METHODS set_item_for_create
      IMPORTING
        is_item TYPE zpro_tb_item_d.

    METHODS delete_item_on_draft
      IMPORTING !iv_pronr TYPE zde_pronr
                !iv_proit TYPE zde_proit.

    METHODS post
      RETURNING VALUE(rv_success) TYPE abap_bool.

    METHODS get_next_pronr
      IMPORTING is_draft         TYPE abp_behv_flag
      RETURNING VALUE(rv_number) TYPE zde_pronr.

    METHODS get_next_proit
      IMPORTING
                !iv_pronr       TYPE zde_pronr
      RETURNING VALUE(rv_proit) TYPE zde_proit.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA:
          mo_handler TYPE REF TO zpro_cl_manage_handler.

    DATA:
      mt_header TYPE SORTED TABLE OF zpro_tb_header_d WITH UNIQUE KEY pronr,
      mt_item   TYPE SORTED TABLE OF zpro_tb_item_d WITH UNIQUE KEY pronr proit.
ENDCLASS.



CLASS ZPRO_CL_MANAGE_HANDLER IMPLEMENTATION.


  METHOD delete_item_on_draft.
*    DELETE TABLE mt_item WITH TABLE KEY proit = iv_proit
*                                        pronr = iv_pronr.
*    DELETE FROM zpro_tb_item_d  WHERE proit = @iv_proit AND pronr = @iv_pronr.
  ENDMETHOD.


  METHOD get_instance.
    IF mo_handler IS NOT BOUND.
      mo_handler = NEW #( ).
    ENDIF.

    ro_handler = mo_handler.
  ENDMETHOD.


  METHOD get_next_proit.
    DATA(lt_doc_items) = FILTER #( mt_item WHERE pronr = iv_pronr ).

    IF lt_doc_items IS NOT INITIAL.
      rv_proit = lt_doc_items[ lines( lt_doc_items ) ]-proit.
    ELSE.
      SELECT MAX( proit ) FROM zpro_tb_item_d WHERE pronr = @iv_pronr INTO @rv_proit.
    ENDIF.

    rv_proit += 1.
    INSERT VALUE #( pronr  = iv_pronr
                    proit = rv_proit ) INTO TABLE mt_item.
  ENDMETHOD.


  METHOD get_next_pronr.
    IF is_draft = if_abap_behv=>mk-on.
      IF mt_header IS INITIAL.
        "-- no unsaved documents
        SELECT MAX( pronr ) FROM zpro_tb_header_d INTO @rv_number.
      ELSE.
        "-- unsaved new documents
        rv_number = mt_header[ lines( mt_header ) ]-pronr.
      ENDIF.

      rv_number += 1.
      INSERT VALUE #( pronr = rv_number ) INTO TABLE mt_header.
    ELSE.
      CALL METHOD cl_numberrange_runtime=>number_get
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZPRO_NR'
          quantity    = 1
        IMPORTING
          number      = DATA(lv_number).
      rv_number = lv_number.
    ENDIF.
  ENDMETHOD.


  METHOD post.
    rv_success = abap_false.

    INSERT zpro_tb_header_d FROM TABLE @mt_header.

    CHECK sy-subrc = 0.
    INSERT zpro_tb_item_d FROM TABLE @mt_item.


    rv_success = abap_true.
    refresh( ).
  ENDMETHOD.


  METHOD refresh.
    CLEAR mo_handler.
  ENDMETHOD.


  METHOD set_header_for_create.
    INSERT is_header INTO TABLE mt_header.
  ENDMETHOD.


  METHOD set_item_for_create.
    INSERT is_item INTO TABLE mt_item.
  ENDMETHOD.
ENDCLASS.
