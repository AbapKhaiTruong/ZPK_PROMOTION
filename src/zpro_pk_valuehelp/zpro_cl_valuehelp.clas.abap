CLASS zpro_cl_valuehelp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
    METHODS : get_parameters IMPORTING io_request TYPE REF TO if_rap_query_request.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: gv_cond_type TYPE zde_cond_type,
          gv_protyp    TYPE zde_protyp.
ENDCLASS.



CLASS ZPRO_CL_VALUEHELP IMPLEMENTATION.


  METHOD get_parameters.
    TRY.
        DATA(lt_filter_cond)        = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
    LOOP AT lt_filter_cond REFERENCE INTO DATA(ls_filter_cond).
      CASE ls_filter_cond->name.
        WHEN 'COND_TYPE'.
          gv_cond_type = ls_filter_cond->range[ 1 ]-low.
        WHEN 'PROTYP'.
          gv_protyp = ls_filter_cond->range[ 1 ]-low.
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

    SELECT SINGLE
        fieldname
    FROM zpro_tb_condtyp
    WHERE protyp = 'Z1'
      AND cond_type = @gv_cond_type
    INTO @DATA(lv_fieldname).

    DATA: gt_response TYPE TABLE OF zpr_i_cond_val_vh.
    CASE lv_fieldname.
      WHEN 'PRODUCT'.
        SELECT COUNT( product ) FROM i_product INTO @DATA(lv_count).
        SELECT DISTINCT
            product AS cond_val,
            productname AS cond_des
       FROM i_producttext
       WHERE language = @sy-langu
       ORDER BY (lv_sort_string)
       INTO CORRESPONDING FIELDS OF TABLE @gt_response
       OFFSET @lv_skip UP TO @lv_max_rows ROWS.
        io_response->set_total_number_of_records( lv_count ).
        io_response->set_data( gt_response ).

      WHEN 'SALEOFFICE'.
        SELECT COUNT( salesoffice ) FROM i_salesoffice INTO @lv_count.
        SELECT DISTINCT
            salesoffice AS cond_val,
            salesofficename AS cond_des
       FROM i_salesofficetext
       WHERE language = @sy-langu
       ORDER BY (lv_sort_string)
       INTO CORRESPONDING FIELDS OF TABLE @gt_response
       OFFSET @lv_skip UP TO @lv_max_rows ROWS.
        io_response->set_total_number_of_records( lv_count ).
        io_response->set_data( gt_response ).


      WHEN 'SALESORGANIZATION'.
        SELECT COUNT( salesorganization ) FROM i_salesorganization INTO @lv_count.
        SELECT DISTINCT
            salesorganization AS cond_val,
            salesorganizationname AS cond_des
       FROM i_salesorganizationtext
       WHERE language = @sy-langu
       ORDER BY (lv_sort_string)
       INTO CORRESPONDING FIELDS OF TABLE @gt_response
       OFFSET @lv_skip UP TO @lv_max_rows ROWS.
        io_response->set_total_number_of_records( lv_count ).
        io_response->set_data( gt_response ).
    ENDCASE.


  ENDMETHOD.
ENDCLASS.
