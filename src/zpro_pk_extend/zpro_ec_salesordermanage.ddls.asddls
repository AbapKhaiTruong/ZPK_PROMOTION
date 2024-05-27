extend view C_SalesOrderManage with ZPRO_EC_SALESORDERMANAGE
{
  @UI.identification: [
    { position: 999, importance: #HIGH, type: #FOR_ACTION, dataAction: 'ZZFindAvailabePromotion', label: 'Suggest Promotion' }
    ]
  @UI: {
  fieldGroup:[{qualifier: 'OrderData', importance: #HIGH, type: #FOR_ACTION, dataAction: 'ZZChoosePromotion', label: 'Apply Promotion' }]}
  SalesOrder.zz_pronr_sdh
}
