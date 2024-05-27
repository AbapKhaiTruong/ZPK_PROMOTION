@EndUserText.label: 'Promotion Type'
@ObjectModel.resultSet.sizeCategory: #XS
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZPRO_I_PROTYP
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_PROTYP' )
{
      @ObjectModel.text.element:[ 'text' ]
      @EndUserText.label: 'Promotion Type'
  key value_low as protyp,
      @Semantics.text: true
      text
}
