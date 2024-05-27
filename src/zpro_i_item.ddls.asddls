@EndUserText.label: 'Promotion Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZPRO_I_ITEM
  as select from zpro_tb_item
  association to parent ZPRO_I_HEADER as _Promotion on _Promotion.pronr = $projection.pronr
  composition [0..*] of ZPRO_I_PISUBCO as _ItemSubCondition
{
  key pronr,
  key proit,
      @ObjectModel.text.element: [ 'fieldname' ]
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZPRO_I_MATCOND_TYPE_VH' , element: 'CondType' },
                     additionalBinding: [{ localElement: '_Promotion.protyp', element: 'Protyp', usage: #FILTER },
                     { localElement: 'fieldname', element: 'Fieldname', usage: #RESULT } ] }]
      cond_type,
      fieldname,
      validto,
      validfrom,
      cond_val,
      minval,
      @Consumption.valueHelpDefinition: [{ entity: { name : 'I_UnitOfMeasureStdVH', element: 'UnitOfMeasure' } }]
      unit,
      foreach,
      stt1,
      @Semantics.quantity.unitOfMeasure: 'unitfg1'
      addfg1,
      @Consumption.valueHelpDefinition: [{ entity: {name: 'I_ProductUnitsOfMeasure' , element: 'AlternativeUnit' },
                     additionalBinding: [{ localElement: 'matnr_fg1', element: 'Product', usage: #FILTER }] }]
      unitfg1,
      @Consumption.valueHelpDefinition: [{ entity: { name : 'I_ProductStdVH', element: 'Product' } }]
      matnr_fg1,
      matkl_fg1,
      stt2,
      @Semantics.quantity.unitOfMeasure: 'unitfg2'
      addfg2,
      @Consumption.valueHelpDefinition: [{ entity: {name: 'I_ProductUnitsOfMeasure' , element: 'AlternativeUnit' },
                   additionalBinding: [{ localElement: 'matnr_fg2', element: 'Product', usage: #FILTER }] }]
      unitfg2,
      @Consumption.valueHelpDefinition: [{ entity: { name : 'I_ProductStdVH', element: 'Product' } }]
      matnr_fg2,
      matkl_fg2,
      stt3,
      @Semantics.quantity.unitOfMeasure: 'unitfg3'
      addfg3,
      @Consumption.valueHelpDefinition: [{ entity: {name: 'I_ProductUnitsOfMeasure' , element: 'AlternativeUnit' },
                   additionalBinding: [{ localElement: 'matnr_fg3', element: 'Product', usage: #FILTER }] }]
      unitfg3,
      @Consumption.valueHelpDefinition: [{ entity: { name : 'I_ProductStdVH', element: 'Product' } }]
      matnr_fg3,
      matkl_fg3,
      stt4,
      @Semantics.quantity.unitOfMeasure: 'unitfg4'
      addfg4,
      @Consumption.valueHelpDefinition: [{ entity: {name: 'I_ProductUnitsOfMeasure' , element: 'AlternativeUnit' },
                   additionalBinding: [{ localElement: 'matnr_fg4', element: 'Product', usage: #FILTER }] }]
      unitfg4,
      @Consumption.valueHelpDefinition: [{ entity: { name : 'I_ProductStdVH', element: 'Product' } }]
      matnr_fg4,
      matkl_fg4,
      stt5,
      @Semantics.quantity.unitOfMeasure: 'unitfg5'
      addfg5,
      @Consumption.valueHelpDefinition: [{ entity: {name: 'I_ProductUnitsOfMeasure' , element: 'AlternativeUnit' },
                   additionalBinding: [{ localElement: 'matnr_fg5', element: 'Product', usage: #FILTER }] }]
      unitfg5,
      @Consumption.valueHelpDefinition: [{ entity: { name : 'I_ProductStdVH', element: 'Product' } }]
      matnr_fg5,
      matkl_fg5,
      cast( case when $projection.cond_type <> '10' then 'X' else '' end  as abap_boolean ) as hiddenSubCondition,
      _Promotion,
      _ItemSubCondition
}
