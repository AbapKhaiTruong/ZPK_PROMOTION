@EndUserText.label: 'Material Condition'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZPRO_I_MATCOND
  as select from zpro_tb_matcon
  association to parent ZPRO_I_HEADER as _Promotion on _Promotion.pronr = $projection.pronr
  composition [0..*] of ZPRO_I_MSUBCO as _MaterialSubCondition
{
  key pronr,
  key matconid,
      stt,
      @ObjectModel.text.element: [ 'fieldname' ]
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZPRO_I_MATCOND_TYPE_VH' , element: 'CondType' },
                     additionalBinding: [{ localElement: '_Promotion.protyp', element: 'Protyp', usage: #FILTER },
                     { localElement: 'fieldname', element: 'Fieldname', usage: #RESULT } ] }]
      cond,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZPRO_I_OPTION_SIMP', element: 'opti' } }]
      opti,
      cond_val,
      fieldname,
      cast( case when $projection.cond <> '10' then 'X' else '' end  as abap_boolean ) as hiddenSubCondition,
      _Promotion,
      _MaterialSubCondition
}
