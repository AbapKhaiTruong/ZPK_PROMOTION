@EndUserText.label: 'Condition value'
@ObjectModel.query.implementedBy: 'ABAP:ZPRO_CL_VALUEHELP'
define custom entity ZPR_I_COND_VAL_VH
{
      @UI.hidden: true
  key protyp    : zde_protyp;
      @UI.hidden: true
  key cond_type : zde_cond_type;
      @UI.lineItem: [{ position: 1 }]
      @UI.identification: [{ position: 1 }]
  key cond_val  : zde_cond_val;
      @UI.lineItem: [{ position: 2 }]
      @UI.identification: [{ position: 2 }]
      cond_des  : abap.char(80);
}
