@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Promotion'
@Metadata.allowExtensions: true
define root view entity ZPRO_I_HEADER
  as select from zpro_tb_header
  association [0..1] to ZPRO_I_PROTYP  as _PromotionType   on _PromotionType.protyp = $projection.protyp
  association [0..1] to ZPRO_I_CALRULE as _CalculationRule on _CalculationRule.calrule = $projection.calrule
  association [0..1] to ZPRO_I_REGSTA as _RegistationStatus on _RegistationStatus.regsta = $projection.regsta
  association [0..1] to ZPRO_I_PROPT as _PromotionOption on _PromotionOption.propt = $projection.propt
  composition [0..*] of ZPRO_I_ITEM    as _PromotionItem
  composition [0..*] of ZPRO_I_GENCOND as _GeneralCondition
  composition [0..*] of ZPRO_I_MATCOND as _MaterialCondition
{
  key pronr,
      @Consumption.valueHelpDefinition: [{ entity: { element: 'protyp', name: 'ZPRO_I_PROTYP' } }]
      @ObjectModel.text.element: [ 'protyp_txt' ]
      protyp,
      _PromotionType.text as protyp_txt,
      prodes,
      validfrom,
      validto,
      @Consumption.valueHelpDefinition: [{ entity: { element: 'calrule', name: 'ZPRO_I_CALRULE' } }]
      @ObjectModel.text.element: [ 'calrule_txt' ]
      calrule,
      _CalculationRule.text as calrule_txt,
      @Consumption.valueHelpDefinition: [{ entity: { element: 'regsta', name: 'ZPRO_I_REGSTA' } }]
      @ObjectModel.text.element: [ 'regsta_txt' ]
      regsta,
      _RegistationStatus.text as regsta_txt,
      @Consumption.valueHelpDefinition: [{ entity: { element: 'propt', name: 'ZPRO_I_PROPT' } }]
      @ObjectModel.text.element: [ 'propt_txt' ]                                                                                                  
      propt,
      _PromotionOption.text as propt_txt,
      locallastchanged,
      lastchanged,
      _PromotionItem,
      _PromotionType,
      _CalculationRule,
      _RegistationStatus,
      _PromotionOption,
      _GeneralCondition,
      _MaterialCondition
}
