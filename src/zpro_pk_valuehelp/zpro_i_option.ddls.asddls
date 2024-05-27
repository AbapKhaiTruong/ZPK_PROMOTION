@EndUserText.label: 'Option'
@ObjectModel.resultSet.sizeCategory: #XS
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZPRO_I_OPTION
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_OPTION' )
{
      @ObjectModel.text.element:[ 'text' ]
      @EndUserText.label: 'Calculation rule'
  key value_low as opti,
      @Semantics.text: true
      text
}
