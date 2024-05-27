*----------------------------------------------------------------------*
* Citek JSC.
* (C) Copyright Citek JSC.
* All Rights Reserved
*----------------------------------------------------------------------*
* Program Summary: Handle Manage Promotopn App
* Creation Date: 10.04.2024
* Created by: NganNM
*----------------------------------------------------------------------*

CLASS lhc_materialcondition DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS onmodifymaterialconditon FOR DETERMINE ON MODIFY
      IMPORTING keys FOR materialcondition~onmodifymaterialconditon.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR materialcondition RESULT result.
    METHODS earlynumbering_cba_materialsub FOR NUMBERING
      IMPORTING entities FOR CREATE materialcondition\_materialsubcondition.

ENDCLASS.

CLASS lhc_materialcondition IMPLEMENTATION.

  METHOD onmodifymaterialconditon.
    DATA:
         lt_matcond_upd TYPE TABLE FOR UPDATE zpro_i_matcond.

    READ ENTITIES OF zpro_i_header IN LOCAL MODE
    ENTITY materialcondition
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_matcond).

    LOOP AT lt_matcond REFERENCE INTO DATA(ls_matcond).

      CLEAR lt_matcond_upd.

      IF ls_matcond->cond <> '10'.
        lt_matcond_upd = VALUE #( (
            hiddensubcondition = abap_true
            %tky = ls_matcond->%tky
            %control = VALUE #( hiddensubcondition = if_abap_behv=>mk-on ) ) ).
      ELSE.
        lt_matcond_upd = VALUE #( (
              hiddensubcondition = abap_false
              %tky = ls_matcond->%tky
              %control = VALUE #( hiddensubcondition = if_abap_behv=>mk-off ) ) ).
      ENDIF.
      MODIFY ENTITIES OF zpro_i_header IN LOCAL MODE
              ENTITY materialcondition
              UPDATE FIELDS ( hiddensubcondition ) WITH lt_matcond_upd.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zpro_i_header IN LOCAL MODE
    ENTITY materialcondition
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_matcond).

    LOOP AT lt_matcond REFERENCE INTO DATA(ls_matcond).
      IF ls_matcond->cond = '10'.
        APPEND VALUE #( %tky            = ls_matcond->%tky
                        %field-opti     = if_abap_behv=>fc-f-read_only
                        %field-cond_val = if_abap_behv=>fc-f-read_only ) TO result.
      ELSE.
        APPEND VALUE #( %tky            = ls_matcond->%tky
                        %field-opti     = if_abap_behv=>fc-f-unrestricted
                        %field-cond_val = if_abap_behv=>fc-f-unrestricted ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_materialsub.
    DATA: lv_matsubconid TYPE zde_id.
    SELECT
        zpro_tb_msubco~pronr,
        zpro_tb_msubco~matconid,
        MAX( zpro_tb_msubco~msubcoid ) AS msubco
    FROM zpro_tb_msubco
    INNER JOIN @entities AS data ON data~pronr =  zpro_tb_msubco~pronr
                                AND data~matconid = zpro_tb_msubco~matconid
    GROUP BY zpro_tb_msubco~pronr, zpro_tb_msubco~matconid
    INTO TABLE @DATA(lt_msubco).


    SELECT
        zpro_tb_msubco_d~pronr,
        zpro_tb_msubco_d~matconid,
        MAX( zpro_tb_msubco_d~msubcoid ) AS msubco
    FROM zpro_tb_msubco_d
    INNER JOIN @entities AS data ON data~pronr =  zpro_tb_msubco_d~pronr
                                AND data~matconid = zpro_tb_msubco_d~matconid
    GROUP BY zpro_tb_msubco_d~pronr, zpro_tb_msubco_d~matconid
    INTO TABLE @DATA(lt_msubco_d).


    LOOP AT entities REFERENCE INTO DATA(entity).
      LOOP AT entity->%target REFERENCE INTO DATA(ls_target).
        lv_matsubconid = 0.

        IF ls_target->%is_draft = if_abap_behv=>mk-on.
          READ TABLE lt_msubco REFERENCE INTO DATA(ls_msubco)
          WITH KEY pronr = ls_target->pronr matconid = ls_target->matconid.
          IF ls_msubco IS BOUND AND lv_matsubconid < ls_msubco->msubco.
            lv_matsubconid = ls_msubco->msubco.
            ls_msubco->matconid += 1.

          ENDIF.

          READ TABLE lt_msubco_d REFERENCE INTO DATA(ls_msubco_d)
          WITH KEY pronr = ls_target->pronr matconid = ls_target->matconid.
          IF ls_msubco_d IS BOUND AND lv_matsubconid < ls_msubco_d->msubco.
            lv_matsubconid = ls_msubco_d->msubco.
            ls_msubco_d->matconid += 1.
          ENDIF.
          lv_matsubconid += 1.
        ELSE.
          lv_matsubconid = ls_target->msubcoid.
        ENDIF.
        INSERT VALUE #(
            %cid      = ls_target->%cid
            %is_draft = ls_target->%is_draft
            pronr     = ls_target->pronr
            matconid = ls_target->matconid
            msubcoid = lv_matsubconid ) INTO TABLE mapped-materialsubcondition.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zpro_i_header DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zpro_i_header IMPLEMENTATION.

  METHOD adjust_numbers.
    DATA:
      lv_pronr TYPE zde_pronr,
      lv_matid TYPE zde_id.

    IF mapped-generalcondition IS NOT INITIAL.
      lv_pronr = mapped-generalcondition[ 1 ]-%tmp-pronr.
      SELECT SINGLE
        MAX( genconid )
      FROM zpro_tb_gencond
      WHERE pronr = @lv_pronr
      INTO @DATA(lv_gencond_max).
      LOOP AT mapped-generalcondition REFERENCE INTO DATA(ls_gencon).
        lv_gencond_max += 1.
        ls_gencon->pronr = ls_gencon->%tmp-pronr.
        ls_gencon->genconid = lv_gencond_max.
      ENDLOOP.
    ENDIF.

    IF mapped-materialsubcondition IS NOT INITIAL.
      lv_pronr = mapped-materialsubcondition[ 1 ]-%tmp-pronr.
      SELECT SINGLE
        MAX( msubcoid )
      FROM zpro_tb_msubco
      WHERE pronr = @lv_pronr AND matconid = @lv_matid
      INTO @DATA(lv_msubco_max).
      LOOP AT mapped-materialsubcondition REFERENCE INTO DATA(ls_matsubcond).
        lv_msubco_max += 1.
        ls_matsubcond->pronr = ls_matsubcond->%tmp-pronr.
        ls_matsubcond->matconid = ls_matsubcond->%tmp-matconid.
        ls_matsubcond->msubcoid = lv_msubco_max.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_promotion DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR promotion RESULT result.
    METHODS validatepromotionvaliddates FOR VALIDATE ON SAVE
      IMPORTING keys FOR promotion~validatepromotionvaliddates.
    METHODS earlynumbering_cba_materialcon FOR NUMBERING
      IMPORTING entities FOR CREATE promotion\_materialcondition.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE promotion.

ENDCLASS.

CLASS lhc_promotion IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lo_doc_handler) = zpro_cl_manage_handler=>get_instance( ).

    LOOP AT entities REFERENCE INTO DATA(entity) .
      APPEND VALUE #( %cid  = entity->%cid
                      %is_draft = entity->%is_draft
                      pronr  = lo_doc_handler->get_next_pronr( is_draft = entity->%is_draft ) ) TO mapped-promotion.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatepromotionvaliddates.
    LOOP AT keys REFERENCE INTO DATA(key).
      READ ENTITIES OF zpro_i_header  IN LOCAL MODE
      ENTITY promotion
      FIELDS ( validfrom validto )
       WITH VALUE #( ( %tky = key->%tky ) )
      RESULT DATA(lt_promotion).

      LOOP AT lt_promotion REFERENCE INTO DATA(ls_promotion).
        APPEND VALUE #( %tky = ls_promotion->%tky
                        %state_area = zpro_cl_manage_handler=>state-valid_date_prohead
                        ) TO reported-promotion.
        IF ls_promotion->validto < ls_promotion->validfrom.
          APPEND VALUE #( %is_draft = key->%is_draft
                          pronr = key->pronr
                          %state_area = zpro_cl_manage_handler=>state-valid_date_prohead
                          %msg = new_message(
                                   id = zpro_cl_manage_handler=>gc_message_class
                                   number = 001
                                   severity = if_abap_behv_message=>severity-error )
                          %element-validto = if_abap_behv=>mk-on
                          %element-validfrom = if_abap_behv=>mk-on )
             TO reported-promotion.
          APPEND VALUE #( %is_draft = key->%is_draft
                          pronr = key->pronr ) TO failed-promotion.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_materialcon.
    DATA: lv_matconid TYPE zde_id.
    SELECT
        zpro_tb_matcon~pronr,
        MAX( zpro_tb_matcon~matconid ) AS matconid
    FROM zpro_tb_matcon
    INNER JOIN @entities AS data ON data~pronr =  zpro_tb_matcon~pronr
    GROUP BY zpro_tb_matcon~pronr
    INTO TABLE @DATA(lt_matcon).

    SELECT
        zpro_tb_matcon_d~pronr,
        MAX( zpro_tb_matcon_d~matconid ) AS matconid
    FROM zpro_tb_matcon_d
    INNER JOIN @entities AS data ON data~pronr = zpro_tb_matcon_d~pronr
    GROUP BY zpro_tb_matcon_d~pronr
    INTO TABLE @DATA(lt_matcon_d).

    LOOP AT entities REFERENCE INTO DATA(entity).
      LOOP AT entity->%target REFERENCE INTO DATA(ls_target).
        lv_matconid = 0.

        IF ls_target->%is_draft = if_abap_behv=>mk-on.
          READ TABLE lt_matcon REFERENCE INTO DATA(ls_matcon)
          WITH KEY pronr = ls_target->pronr .
          IF ls_matcon IS BOUND AND lv_matconid <= ls_matcon->matconid.
            ls_matcon->matconid += 1.
            lv_matconid = ls_matcon->matconid.
          ENDIF.

          READ TABLE lt_matcon_d REFERENCE INTO DATA(ls_matcon_d)
                  WITH KEY pronr = ls_target->pronr .
          IF ls_matcon_d IS BOUND AND lv_matconid <= ls_matcon_d->matconid.
            ls_matcon_d->matconid += 1.
            lv_matconid = ls_matcon_d->matconid.
          ENDIF.
        ELSE.
          lv_matconid = ls_target->matconid.
        ENDIF.
        INSERT VALUE #(
            %cid      = ls_target->%cid
            %is_draft = ls_target->%is_draft
            pronr = ls_target->pronr
            matconid = lv_matconid  ) INTO TABLE mapped-materialcondition.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_promotionitem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    DATA: gv_promotionitem TYPE int4.
    METHODS earlynumbering_promotionitem FOR NUMBERING
      IMPORTING entities FOR CREATE promotion\_promotionitem.
    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR promotionitem~validatedates.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR promotionitem RESULT result.

    METHODS earlynumbering_cba_itemsubcond FOR NUMBERING
      IMPORTING entities FOR CREATE promotionitem\_itemsubcondition.

    METHODS onmodifyitemconditon FOR DETERMINE ON MODIFY
      IMPORTING keys FOR promotionitem~onmodifyitemconditon.

ENDCLASS.

CLASS lhc_promotionitem IMPLEMENTATION.

  METHOD earlynumbering_promotionitem.
    DATA(lo_doc_handler) = zpro_cl_manage_handler=>get_instance( ).

    LOOP AT entities REFERENCE INTO DATA(entity) .
      LOOP AT entity->%target REFERENCE INTO DATA(ls_item_create).
        APPEND VALUE #( %cid  = ls_item_create->%cid
                        %is_draft = ls_item_create->%is_draft
                        pronr  = ls_item_create->pronr
                        proit  = lo_doc_handler->get_next_proit( iv_pronr = ls_item_create->pronr ) ) TO mapped-promotionitem.
      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD validatedates.
    LOOP AT keys REFERENCE INTO DATA(key).
      READ ENTITIES OF zpro_i_header  IN LOCAL MODE
      ENTITY promotionitem
      FIELDS ( validfrom validto )
       WITH VALUE #( ( %tky = key->%tky ) )
      RESULT DATA(lt_promotionitem)
      ENTITY promotionitem BY \_promotion
        FROM CORRESPONDING #( keys )
      LINK DATA(links).

      LOOP AT lt_promotionitem REFERENCE INTO DATA(ls_item).
        APPEND VALUE #( %tky = ls_item->%tky
                        %state_area = zpro_cl_manage_handler=>state-valid_date_proitem
                        ) TO reported-promotionitem.
        IF ls_item->validto < ls_item->validfrom.
          APPEND VALUE #( %is_draft = key->%is_draft
                          pronr = key->pronr
                          proit = key->proit
                          %state_area = zpro_cl_manage_handler=>state-valid_date_proitem
                          %msg = new_message(
                                   id = zpro_cl_manage_handler=>gc_message_class
                                   number = 001
                                   severity = if_abap_behv_message=>severity-error )
                          %path       = VALUE #( promotion-%tky = links[ 1 ]-target-%tky )
                          %element-validto = if_abap_behv=>mk-on
                          %element-validfrom = if_abap_behv=>mk-on )
             TO reported-promotionitem.
          APPEND VALUE #( %is_draft = key->%is_draft
                          proit = key->proit
                          pronr = key->pronr ) TO failed-promotionitem.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zpro_i_header IN LOCAL MODE
      ENTITY promotionitem
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_item).

    LOOP AT lt_item REFERENCE INTO DATA(ls_item).
      IF ls_item->cond_type = '10'.
        APPEND VALUE #( %tky            = ls_item->%tky
                        %field-minval   = if_abap_behv=>fc-f-read_only
                        %field-unit     = if_abap_behv=>fc-f-read_only
                        %field-cond_val = if_abap_behv=>fc-f-read_only
                       ) TO result.
      ELSE.
        APPEND VALUE #( %tky            = ls_item->%tky
                        %field-minval   = if_abap_behv=>fc-f-unrestricted
                        %field-unit     = if_abap_behv=>fc-f-unrestricted
                        %field-cond_val = if_abap_behv=>fc-f-unrestricted
                      ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_itemsubcond.
    DATA: lv_pisubcoid TYPE zde_id.

    SELECT
        zpro_tb_pisubco~pronr,
        zpro_tb_pisubco~proit,
        MAX( zpro_tb_pisubco~pisubcoid ) AS pisubcoid
    FROM zpro_tb_pisubco
    INNER JOIN @entities AS data ON data~pronr = zpro_tb_pisubco~pronr
                                AND data~proit = zpro_tb_pisubco~proit
    GROUP BY zpro_tb_pisubco~pronr, zpro_tb_pisubco~proit
    INTO TABLE @DATA(lt_pisubcoid).

    SELECT
        zpro_tb_pisubc_d~pronr,
        zpro_tb_pisubc_d~proit,
        MAX( zpro_tb_pisubc_d~pisubcoid ) AS pisubcoid
    FROM zpro_tb_pisubc_d
    INNER JOIN @entities AS data ON data~pronr = zpro_tb_pisubc_d~pronr
                                AND data~proit = zpro_tb_pisubc_d~proit
    GROUP BY  zpro_tb_pisubc_d~pronr, zpro_tb_pisubc_d~proit
    INTO TABLE @DATA(lt_pisubcoid_d).

    LOOP AT entities REFERENCE INTO DATA(entity).
      LOOP AT entity->%target REFERENCE INTO DATA(ls_target).
        lv_pisubcoid = 0.

        IF ls_target->%is_draft = if_abap_behv=>mk-on.
          READ TABLE lt_pisubcoid REFERENCE INTO DATA(ls_pisubco)
          WITH KEY pronr = ls_target->pronr proit = ls_target->proit.
          IF ls_pisubco IS BOUND AND lv_pisubcoid < ls_pisubco->pisubcoid.
            lv_pisubcoid = ls_pisubco->proit.
            ls_pisubco->pisubcoid += 1.
          ENDIF.

          READ TABLE lt_pisubcoid_d REFERENCE INTO DATA(ls_pisubco_d)
          WITH KEY pronr = ls_target->pronr proit = ls_target->proit.
          IF ls_pisubco_d IS BOUND AND lv_pisubcoid < ls_pisubco_d->pisubcoid.
            lv_pisubcoid = ls_pisubco_d->pisubcoid.
            ls_pisubco_d->pisubcoid += 1.
          ENDIF.

          lv_pisubcoid += 1.
        ELSE.
          lv_pisubcoid = ls_target->pisubcoid.
        ENDIF.
        INSERT VALUE #(
            %cid      = ls_target->%cid
            %is_draft = ls_target->%is_draft
            pronr     = ls_target->pronr
            proit     = ls_target->proit
            pisubcoid = lv_pisubcoid ) INTO TABLE mapped-itemsubcondition.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD onmodifyitemconditon.
    DATA:
           lt_item_upd TYPE TABLE FOR UPDATE zpro_i_item.

    READ ENTITIES OF zpro_i_header IN LOCAL MODE
    ENTITY promotionitem
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_item).

    LOOP AT lt_item REFERENCE INTO DATA(ls_item).

      CLEAR lt_item_upd.

      IF ls_item->cond_type <> '10'.
        lt_item_upd = VALUE #( (
            hiddensubcondition = abap_true
            %tky = ls_item->%tky
            %control = VALUE #( hiddensubcondition = if_abap_behv=>mk-on ) ) ).
      ELSE.
        lt_item_upd = VALUE #( (
              hiddensubcondition = abap_false
              %tky = ls_item->%tky
              %control = VALUE #( hiddensubcondition = if_abap_behv=>mk-off ) ) ).
      ENDIF.
      MODIFY ENTITIES OF zpro_i_header IN LOCAL MODE
              ENTITY promotionitem
              UPDATE FIELDS ( hiddensubcondition ) WITH lt_item_upd.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
