CLASS zpro_cl_promotionvh DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
    METHODS : get_parameters IMPORTING io_request TYPE REF TO if_rap_query_request.

    DATA:
      BEGIN OF gs_request,
        salesoffice       TYPE zde_vkorg,
        product           TYPE matnr,
        salesorganization TYPE c LENGTH 4,
        productgroup      TYPE c LENGTH 9,
        pricingdate       TYPE sy-datum,
      END OF gs_request.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZPRO_CL_PROMOTIONVH IMPLEMENTATION.


  METHOD get_parameters.
    TRY.
        DATA(lt_filter_cond)        = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
    LOOP AT lt_filter_cond REFERENCE INTO DATA(ls_filter_cond).
      CASE ls_filter_cond->name.
        WHEN 'SALESOFFICE'.
          gs_request-salesoffice = ls_filter_cond->range[ 1 ]-low.
        WHEN 'SALESORGANIZATION'.
          gs_request-salesorganization = ls_filter_cond->range[ 1 ]-low.
        WHEN 'PRICINGDATE'.
          gs_request-pricingdate = ls_filter_cond->range[ 1 ]-low.
        WHEN 'PRODUCT'.
          gs_request-product = ls_filter_cond->range[ 1 ]-low.
        WHEN 'PRODUCTGROUP'.
          gs_request-productgroup = ls_filter_cond->range[ 1 ]-low.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                ELSE lv_top ).
    IF lv_max_rows = -1 .
      lv_max_rows = 1.
    ENDIF.

    DATA(lt_req_elements) = io_request->get_requested_elements( ).
    DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = `, ` ).
    DATA(lv_entity) = io_request->get_entity_id(  ).

    DATA(lt_sort)          = io_request->get_sort_elements( ).
    DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN lt_sort
                                                     ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true
                                                                                            THEN ` descending`
                                                                                            ELSE ` ascending` ) ) ).
    DATA(lv_sort_string)  = COND #( WHEN lt_sort_criteria IS INITIAL THEN `Product` ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).

    get_parameters( io_request ).

    DATA:
      lt_request     TYPE TABLE OF zpro_i_promotionvh,
      lt_pro         TYPE TABLE OF zpro_i_promotionvh,
      et_pro         TYPE TABLE OF zpro_i_promotionvh,
      lt_pro_temp    TYPE TABLE OF zpro_i_promotionvh,
      ls_epro        TYPE zpro_i_promotionvh,
      lt_gencond     TYPE TABLE OF zpro_tb_gencond,
      lt_proitem     TYPE TABLE OF zpro_if_constants=>suggest_proitem,
      lv_where       TYPE string,
      lv_final_where TYPE string.
    DATA(lr_request) = REF #( gs_request ).

    lt_request = VALUE #( ( salesoffice       = gs_request-salesoffice
                            salesorganization = gs_request-salesorganization
                            product           = gs_request-product
                            productgroup      = gs_request-productgroup ) ).

    SELECT
        zpro_tb_header~*
    FROM zpro_tb_header
    WHERE protyp = 'Z1'
      AND propt = '1'
      AND validfrom <= @gs_request-pricingdate
      AND validto >= @gs_request-pricingdate
    ORDER BY zpro_tb_header~pronr
    INTO CORRESPONDING FIELDS OF TABLE @lt_pro.
    IF sy-subrc = 0.
      SELECT
        zpro_tb_gencond~*
      FROM zpro_tb_gencond
      INNER JOIN @lt_pro AS data ON data~pronr = zpro_tb_gencond~pronr
      ORDER BY zpro_tb_gencond~pronr, zpro_tb_gencond~stt
      INTO CORRESPONDING FIELDS OF TABLE @lt_gencond.

      SELECT
          zpro_tb_item~pronr,
          zpro_tb_item~proit,
          zpro_tb_pisubco~pisubcoid,
          CASE WHEN zpro_tb_item~cond_type = @zpro_if_constants=>cond_type-customer_group
               THEN zpro_tb_pisubco~cond
          ELSE zpro_tb_item~cond_type END  AS cond_type,
          CASE WHEN zpro_tb_item~cond_type = @zpro_if_constants=>cond_type-customer_group
               THEN zpro_tb_pisubco~fieldname
          ELSE zpro_tb_item~fieldname END  AS fieldname,
          zpro_tb_item~validto,
          zpro_tb_item~validfrom,
          CASE WHEN zpro_tb_item~cond_type = @zpro_if_constants=>cond_type-customer_group
               THEN zpro_tb_pisubco~cond_val
          ELSE zpro_tb_item~cond_val END  AS cond_val,
          CASE WHEN zpro_tb_item~cond_type = @zpro_if_constants=>cond_type-customer_group
               THEN zpro_tb_pisubco~minval
          ELSE zpro_tb_item~minval END  AS minval,
          CASE WHEN zpro_tb_item~cond_type = @zpro_if_constants=>cond_type-customer_group
               THEN zpro_tb_pisubco~unit
          ELSE zpro_tb_item~unit END  AS unit,
          zpro_tb_item~foreach,
          zpro_tb_item~stt1,
          zpro_tb_item~addfg1,
          zpro_tb_item~unitfg1,
          zpro_tb_item~matnr_fg1,
          zpro_tb_item~matkl_fg1,
          zpro_tb_item~stt2,
          zpro_tb_item~addfg2,
          zpro_tb_item~unitfg2,
          zpro_tb_item~matnr_fg2,
          zpro_tb_item~matkl_fg2,
          zpro_tb_item~stt3,
          zpro_tb_item~addfg3,
          zpro_tb_item~unitfg3,
          zpro_tb_item~matnr_fg3,
          zpro_tb_item~matkl_fg3,
          zpro_tb_item~stt4,
          zpro_tb_item~addfg4,
          zpro_tb_item~unitfg4,
          zpro_tb_item~matnr_fg4,
          zpro_tb_item~matkl_fg4,
          zpro_tb_item~stt5,
          zpro_tb_item~addfg5,
          zpro_tb_item~unitfg5,
          zpro_tb_item~matnr_fg5,
          zpro_tb_item~matkl_fg5
      FROM zpro_tb_item
      INNER JOIN @lt_pro AS data ON data~pronr = zpro_tb_item~pronr
      LEFT JOIN zpro_tb_pisubco ON zpro_tb_pisubco~pronr = zpro_tb_item~pronr
                               AND zpro_tb_pisubco~proit = zpro_tb_item~proit
      ORDER BY zpro_tb_item~pronr
      INTO CORRESPONDING FIELDS OF TABLE @lt_proitem.
      LOOP AT lt_pro REFERENCE INTO DATA(ls_pro).
        ls_pro->valid = abap_true.
        CLEAR : lv_where, lv_final_where.

        READ TABLE lt_gencond TRANSPORTING NO FIELDS
        WITH KEY pronr = ls_pro->pronr BINARY SEARCH.
        IF sy-subrc = 0.
*         Xử lý format điều kiện cho General Condition
          LOOP AT lt_gencond REFERENCE INTO DATA(ls_gencond) FROM sy-tabix.
            IF ls_gencond->pronr <> ls_pro->pronr.
              EXIT.
            ENDIF.

            IF lv_where IS INITIAL.
              lv_where = |{ ls_gencond->fieldname } { ls_gencond->opti } { ls_gencond->cond_val }|.
            ELSE.
              lv_where = |{ lv_where } AND { ls_gencond->fieldname } { ls_gencond->opti } { ls_gencond->cond_val }|.
            ENDIF.

*---> Gom điều kiện theo field STT
            AT END OF stt.
              IF lv_final_where IS INITIAL.
                lv_final_where = |( { lv_where } )|.
              ELSE.
                lv_final_where = |{ lv_final_where } OR ( { lv_where } )|.
              ENDIF.
              CLEAR lv_where.
            ENDAT.

          ENDLOOP.
        ENDIF.

        READ TABLE lt_proitem TRANSPORTING NO FIELDS
            WITH KEY pronr = ls_pro->pronr BINARY SEARCH.
        IF sy-subrc = 0.

          LOOP AT lt_proitem REFERENCE INTO DATA(ls_proitem) FROM sy-tabix.
            IF ls_proitem->pronr <> ls_pro->pronr.
              EXIT.
            ENDIF.
            CHECK lr_request->(ls_proitem->fieldname) = ls_proitem->cond_val.
            IF lv_where IS INITIAL.
              lv_where = |{ ls_proitem->fieldname } EQ '{ ls_proitem->cond_val }'|.
            ELSE.
              lv_where = |{ lv_where } OR { ls_proitem->fieldname } EQ '{ ls_proitem->cond_val }'|.
            ENDIF.

            ls_epro-pronr = ls_proitem->pronr.
            ls_epro-prodes = ls_pro->prodes.
            ls_epro-proit = ls_proitem->proit.
            ls_epro-stt = ls_proitem->stt1.
            ls_epro-cond_val = ls_proitem->cond_val.
            ls_epro-cond_type = ls_proitem->cond_type.

            IF ls_proitem->matnr_fg1 IS NOT INITIAL.
              ls_epro-sub_stt = '1'.
              ls_epro-freegood =  ls_proitem->matnr_fg1.
              ls_epro-orderquantity = ls_proitem->addfg1.
              ls_epro-orderunit = ls_proitem->unitfg1.
              APPEND ls_epro TO lt_pro_temp.
            ENDIF.

            IF ls_proitem->matnr_fg2 IS NOT INITIAL.
              ls_epro-sub_stt = '2'.
              ls_epro-freegood =  ls_proitem->matnr_fg2.
              ls_epro-orderquantity = ls_proitem->addfg2.
              ls_epro-orderunit = ls_proitem->unitfg2.
              APPEND ls_epro TO lt_pro_temp.
            ENDIF.

            IF ls_proitem->matnr_fg3 IS NOT INITIAL.
              ls_epro-sub_stt = '3'.
              ls_epro-freegood =  ls_proitem->matnr_fg3.
              ls_epro-orderquantity = ls_proitem->addfg3.
              ls_epro-orderunit = ls_proitem->unitfg3.
              APPEND ls_epro TO lt_pro_temp.
            ENDIF.

            IF ls_proitem->matnr_fg4 IS NOT INITIAL.
              ls_epro-sub_stt = '4'.
              ls_epro-freegood =  ls_proitem->matnr_fg4.
              ls_epro-orderquantity = ls_proitem->addfg4.
              ls_epro-orderunit = ls_proitem->unitfg4.
              APPEND ls_epro TO lt_pro_temp.
            ENDIF.

          ENDLOOP.
        ENDIF.

        IF lv_where IS NOT INITIAL.
          lv_final_where =  |( { lv_final_where } ) AND ( { lv_where } )|.
        ENDIF.

        LOOP AT lt_request REFERENCE INTO DATA(ls_salesoderitem) WHERE (lv_final_where).
          EXIT.
        ENDLOOP.
        IF sy-subrc <> 0.
          ls_pro->valid = abap_false.
        ELSE.
          APPEND LINES OF lt_pro_temp TO et_pro.
        ENDIF.

      ENDLOOP.
    ENDIF.

    io_response->set_total_number_of_records( lines( et_pro ) ).
    DATA:
        lt_out LIKE et_pro.
    SELECT DISTINCT
            *
       FROM @et_pro AS data
       ORDER BY (lv_sort_string)
       INTO CORRESPONDING FIELDS OF TABLE @lt_out
       OFFSET @lv_skip UP TO @lv_max_rows ROWS.
    io_response->set_data( lt_out ).
  ENDMETHOD.
ENDCLASS.
