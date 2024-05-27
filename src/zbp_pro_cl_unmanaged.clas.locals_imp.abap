CLASS lhc_promotion DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR promotion RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE promotion.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE promotion.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE promotion.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE promotion.

    METHODS read FOR READ
      IMPORTING keys FOR READ promotion RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK promotion.

    METHODS rba_generalcondition FOR READ
      IMPORTING keys_rba FOR READ promotion\_generalcondition FULL result_requested RESULT result LINK association_links.

    METHODS rba_materialcondition FOR READ
      IMPORTING keys_rba FOR READ promotion\_materialcondition FULL result_requested RESULT result LINK association_links.

    METHODS rba_promotionitem FOR READ
      IMPORTING keys_rba FOR READ promotion\_promotionitem FULL result_requested RESULT result LINK association_links.

    METHODS cba_generalcondition FOR MODIFY
      IMPORTING entities_cba FOR CREATE promotion\_generalcondition.

    METHODS cba_materialcondition FOR MODIFY
      IMPORTING entities_cba FOR CREATE promotion\_materialcondition.

    METHODS cba_promotionitem FOR MODIFY
      IMPORTING entities_cba FOR CREATE promotion\_promotionitem.

    METHODS earlynumbering_cba_promotionit FOR NUMBERING
      IMPORTING entities FOR CREATE promotion\_promotionitem.

    METHODS detactpromotionvaliddates FOR MODIFY
      IMPORTING keys FOR ACTION promotion~detactpromotionvaliddates.

    METHODS detactvaliddates FOR MODIFY
      IMPORTING keys FOR ACTION promotion~detactvaliddates.

    METHODS validatepromotionvaliddates FOR VALIDATE ON SAVE
      IMPORTING keys FOR promotion~validatepromotionvaliddates.
    METHODS defaultforcreate FOR READ
      IMPORTING keys FOR FUNCTION promotion~defaultforcreate RESULT result.
ENDCLASS.

CLASS lhc_promotion IMPLEMENTATION.
  METHOD defaultforcreate.
    result = VALUE #(
                      ( %cid = keys[ 1 ]-%cid
                        %param = VALUE #( protyp = 'Z1' ) )  ) .
  ENDMETHOD.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lo_doc_handler) = zpro_cl_manage_handler=>get_instance( ).

    LOOP AT entities REFERENCE INTO DATA(entity) .
      APPEND VALUE #( %cid  = entity->%cid
                      %is_draft = entity->%is_draft
                      pronr  = lo_doc_handler->get_next_pronr( is_draft = entity->%is_draft ) ) TO mapped-promotion.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_generalcondition.
  ENDMETHOD.

  METHOD rba_materialcondition.
  ENDMETHOD.

  METHOD rba_promotionitem.
  ENDMETHOD.

  METHOD cba_generalcondition.
*    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<cba>) GROUP BY <cba>-pronr.
*    ENDLOOP.
  ENDMETHOD.

  METHOD cba_materialcondition.
  ENDMETHOD.

  METHOD cba_promotionitem.
  ENDMETHOD.

  METHOD earlynumbering_cba_promotionit.
  ENDMETHOD.

  METHOD detactpromotionvaliddates.
  ENDMETHOD.

  METHOD detactvaliddates.
  ENDMETHOD.

  METHOD validatepromotionvaliddates.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_promotionitem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE promotionitem.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE promotionitem.

    METHODS read FOR READ
      IMPORTING keys FOR READ promotionitem RESULT result.

    METHODS rba_promotion FOR READ
      IMPORTING keys_rba FOR READ promotionitem\_promotion FULL result_requested RESULT result LINK association_links.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR promotionitem~validatedates.

ENDCLASS.

CLASS lhc_promotionitem IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_promotion.
  ENDMETHOD.

  METHOD validatedates.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_generalcondition DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE generalcondition.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE generalcondition.

    METHODS read FOR READ
      IMPORTING keys FOR READ generalcondition RESULT result.

    METHODS rba_promotion FOR READ
      IMPORTING keys_rba FOR READ generalcondition\_promotion FULL result_requested RESULT result LINK association_links.


ENDCLASS.

CLASS lhc_generalcondition IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_promotion.
  ENDMETHOD.




ENDCLASS.

CLASS lhc_materialcondition DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE materialcondition.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE materialcondition.

    METHODS read FOR READ
      IMPORTING keys FOR READ materialcondition RESULT result.

    METHODS rba_promotion FOR READ
      IMPORTING keys_rba FOR READ materialcondition\_promotion FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_materialcondition IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_promotion.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zpro_i_header DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zpro_i_header IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
