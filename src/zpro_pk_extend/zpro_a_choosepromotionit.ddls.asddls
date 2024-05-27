@EndUserText.label: 'Choose Promotion'
define root abstract entity ZPRO_A_CHOOSEPROMOTIONIT
{
      @Consumption.valueHelpDefinition: [{entity.name: 'ZPRO_I_PROMOTIONVH', entity.element: 'pronr',
                                           additionalBinding: [{ localElement: 'salesorganization' , element: 'salesorganization', usage: #FILTER },
                                                               { localElement: 'salesoffice' , element: 'salesoffice', usage: #FILTER },
                                                               { localElement: 'pricingdate' , element: 'pricingdate', usage: #FILTER },
                                                               { localElement: 'product' , element: 'product', usage: #FILTER },
                                                               { localElement: 'productgroup' , element: 'productgroup', usage: #FILTER },
                                                               { localElement: 'proit' , element: 'proit', usage: #RESULT },
                                                               { localElement: 'stt' , element: 'stt', usage: #RESULT } ] }]
  key zz_pronr_sdh      : zde_pronr;
      @UI.hidden        : true
  key proit             : zde_proit;
      @UI.defaultValue  : #( 'ELEMENT_OF_REFERENCED_ENTITY: _SalesOrder.SalesOrganization')
      @UI.hidden        : true
      salesorganization : zde_vkorg;
      @UI.defaultValue  : #( 'ELEMENT_OF_REFERENCED_ENTITY: _SalesOrder.SalesOffice')
      @UI.hidden        : true
      salesoffice       : abap.char(4);
      @UI.hidden        : true
      @UI.defaultValue  : #( 'ELEMENT_OF_REFERENCED_ENTITY: _SalesOrder.PricingDate')
      pricingdate       : abap.dats;
      @UI.hidden        : true
      @UI.defaultValue  : #( 'ELEMENT_OF_REFERENCED_ENTITY: Product')
      product           : matnr;
      @UI.hidden        : true
      @UI.defaultValue  : #( 'ELEMENT_OF_REFERENCED_ENTITY: ProductGroup')
      productgroup      : abap.char(9);
      @UI.hidden        : true
      stt               : zde_stt;

}
