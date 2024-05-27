@EndUserText.label: 'Option'
@ObjectModel.resultSet.sizeCategory: #XS
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZPRO_I_PROPT
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_PROPT' )
{
      @ObjectModel.text.element:[ 'text' ]
      @EndUserText.label: 'Option'
  key cast( value_low as zde_propt )  as propt,
      @Semantics.text: true
      text
}
