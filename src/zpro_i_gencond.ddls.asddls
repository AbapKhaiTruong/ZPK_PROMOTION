@EndUserText.label: 'General Condition'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZPRO_I_GENCOND
  as select from zpro_tb_gencond
  association to parent ZPRO_I_HEADER as _Promotion on _Promotion.pronr = $projection.pronr
{
  key pronr,
  key genconid,
      stt,
      @ObjectModel.text.element: [ 'fieldname' ]
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZPRO_I_COND_TYPE_VH' , element: 'CondType' },
                     additionalBinding: [{ localElement: '_Promotion.protyp', element: 'Protyp', usage: #FILTER },
                     { localElement: 'fieldname', element: 'Fieldname', usage: #RESULT } ] }]
      cond,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZPRO_I_OPTION_SIMP', element: 'opti' } }]
      opti,
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZPR_I_COND_VAL_VH' , element: 'cond_val' },
                   additionalBinding: [{ localElement: 'cond', element: 'cond_type', usage: #FILTER } ,
                   { localElement: '_Promotion.protyp', element: 'protyp', usage: #FILTER }  ] }]
      @ObjectModel.foreignKey.association: '_Promotion'
      cond_val,
//      _Promotion.protyp as protyp,
      fieldname,
      _Promotion
}
