@EndUserText.label: 'Search help for Promotion'
@ObjectModel.query.implementedBy: 'ABAP:ZPRO_CL_PROMOTIONVH'
define custom entity ZPRO_I_PROMOTIONVH
{
  key pronr             : zde_pronr;
      @UI.hidden        : true
  key proit             : zde_proit;
      @UI.hidden        : true
  key stt               : zde_stt;
      @UI.hidden        : true
  key sub_stt           : zde_stt;
      @UI.hidden        : true
      product           : matnr;
      productgroup      : abap.char(9);
      @Consumption.filter.hidden: true
      prodes            : zde_prodes;
      @Consumption.filter.hidden: true
      minval            : zde_minval;
      @Consumption.filter.hidden: true
      cond_type         : zde_cond_type;
      @Consumption.filter.hidden: true
      cond_val          : zde_cond_val;
      @Consumption.filter.hidden: true
      freegood          : matnr;
      @Consumption.filter.hidden: true
      @Semantics.quantity.unitOfMeasure: 'orderunit'
      orderquantity     : menge_d;
      @Consumption.filter.hidden: true
      orderunit         : meins;
      @UI.hidden        : true
      salesorganization : zde_vkorg;
      @UI.hidden        : true
      salesoffice       : abap.char(4);
      @UI.hidden        : true
      pricingdate       : abap.dats;
      @UI.hidden        : true
      valid             : abap_boolean;
}
