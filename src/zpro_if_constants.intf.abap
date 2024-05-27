INTERFACE zpro_if_constants
  PUBLIC .
  CONSTANTS:
    BEGIN OF cond_type,
      customer_group TYPE zde_cond_type VALUE '10',
    END OF cond_type,

    BEGIN OF pro_type,
      thtructiep  TYPE zde_protyp VALUE 'Z1',
      thtichluy   TYPE zde_protyp VALUE 'Z2',
      purchrebate TYPE zde_protyp VALUE 'Z3',
      salesrebate TYPE zde_protyp VALUE 'Z4',
    END OF pro_type.


  TYPES:
    BEGIN OF suggest_proitem,
      pronr     TYPE zde_pronr,
      proit     TYPE zde_proit,
      pisubcoid TYPE zde_id,
      cond_type TYPE zde_cond_type,
      fieldname TYPE zde_fieldname,
      validto   TYPE datum,
      validfrom TYPE datum,
      cond_val  TYPE zde_cond_val,
      minval    TYPE zde_minval,
      unit      TYPE zde_unitfg,
      foreach   TYPE zde_foreach,
      stt1      TYPE zde_stt,
      addfg1    TYPE zde_addfg,
      unitfg1   TYPE zde_unitfg,
      matnr_fg1 TYPE matnr,
      matkl_fg1 TYPE zde_matkl,
      stt2      TYPE zde_stt,
      addfg2    TYPE zde_addfg,
      unitfg2   TYPE zde_unitfg,
      matnr_fg2 TYPE matnr,
      matkl_fg2 TYPE zde_matkl,
      stt3      TYPE zde_stt,
      addfg3    TYPE zde_addfg,
      unitfg3   TYPE zde_unitfg,
      matnr_fg3 TYPE matnr,
      matkl_fg3 TYPE zde_matkl,
      stt4      TYPE zde_stt,
      addfg4    TYPE zde_addfg,
      unitfg4   TYPE zde_unitfg,
      matnr_fg4 TYPE matnr,
      matkl_fg4 TYPE zde_matkl,
      stt5      TYPE zde_stt,
      addfg5    TYPE zde_addfg,
      unitfg5   TYPE zde_unitfg,
      matnr_fg5 TYPE matnr,
      matkl_fg5 TYPE zde_matkl,
    END OF suggest_proitem.

ENDINTERFACE.
