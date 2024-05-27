@EndUserText.label: 'Condition Type'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZPRO_I_COND_TYPE
  as select from zpro_tb_condtyp
  association to parent ZPRO_I_COND_TYPE_S as _ConditionTypeAll on $projection.SingletonID = _ConditionTypeAll.SingletonID
{
    @Consumption.valueHelpDefinition: [{ entity: { element: 'protyp', name: 'ZPRO_I_PROTYP' } }]
  key protyp        as Protyp,
  key cond_type     as CondType,
      cond_type_txt as CondTypeTxt,
      fieldname     as Fieldname,
      searchhelp    as Searchhelp,
      @Consumption.hidden: true
      1             as SingletonID,
      _ConditionTypeAll

}
