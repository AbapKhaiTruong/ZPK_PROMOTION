@EndUserText.label: 'Trạng thái đăng ký'
@ObjectModel.resultSet.sizeCategory: #XS
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZPRO_I_REGSTA
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_REGSTA' )
{
      @ObjectModel.text.element:[ 'text' ]
      @EndUserText.label: 'Trạng thái đăng ký'
  key cast( value_low as zde_regsta ) as regsta,
      @Semantics.text: true
      text
}
