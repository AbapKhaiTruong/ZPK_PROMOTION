@EndUserText.label: 'Condition Type'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZPRO_I_MATCONTY
  as select from ZPRO_TB_MATCONTY
  association to parent ZPRO_I_MATCONTY_S as _ConditionTypeAll on $projection.SingletonID = _ConditionTypeAll.SingletonID
{
  key PROTYP as Protyp,
  key COND_TYPE as CondType,
  COND_TYPE_TXT as CondTypeTxt,
  FIELDNAME as Fieldname,
  SEARCHHELP as Searchhelp,
  @Consumption.hidden: true
  1 as SingletonID,
  _ConditionTypeAll
  
}
