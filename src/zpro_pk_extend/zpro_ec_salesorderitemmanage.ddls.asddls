extend view entity C_SalesOrderItemManage with
{
  SalesOrderItem.zz_pro_higherlvl_sdi,
  SalesOrderItem.zz_profoc_ind_sdi,

  @UI.lineItem: [

   {position: 999, importance: #HIGH, type: #FOR_ACTION, invocationGrouping: #CHANGE_SET ,dataAction: 'ZZChoosePromotionItem', label: 'Choose Promotion'}
  ]
  SalesOrderItem.zz_pronr_sdi
}
