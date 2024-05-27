@EndUserText.label: 'Item Sub Condition'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZPRO_I_PISUBCO
  as select from zpro_tb_pisubco

  association        to parent ZPRO_I_ITEM as _PromotionItem on  _PromotionItem.pronr = $projection.pronr
                                                             and _PromotionItem.proit = $projection.proit
  association [1..1] to ZPRO_I_HEADER      as _Promotion     on  $projection.pronr = _Promotion.pronr
{
  key zpro_tb_pisubco.pronr,
  key zpro_tb_pisubco.proit,
  key zpro_tb_pisubco.pisubcoid,
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZPRO_I_MATCOND_TYPE_VH' , element: 'CondType' },
                         additionalBinding: [{ localElement: '_Promotion.protyp', element: 'Protyp', usage: #FILTER },
                         { localElement: 'fieldname', element: 'Fieldname', usage: #RESULT } ] }]
      @ObjectModel.text.element: [ 'fieldname' ]
      zpro_tb_pisubco.cond,
      zpro_tb_pisubco.cond_val,
      zpro_tb_pisubco.fieldname,
      zpro_tb_pisubco.minval,
      zpro_tb_pisubco.unit,
      _PromotionItem,
      _Promotion
}
