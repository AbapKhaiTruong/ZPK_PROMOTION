extend view entity I_SalesOrderTP with
{
  @Consumption.valueHelpDefinition: [{ entity: {name: 'ZPRO_I_PROSASGEN_VH' , element: 'CondType' },
                     additionalBinding: [{ localElement: 'SalesOrganization', element: 'salesorg', usage: #FILTER } ] }]
  SalesOrder.zz_pronr_sdh
}
