@EndUserText.label: 'Promotion'
@ObjectModel.supportedCapabilities: [#DATA_STRUCTURE]
define root abstract entity ZPRO_D_PROMOTIONSUGGEST
{
  key DummyKey              : abap.char(1);
      _RecommendedPromotion : composition [0..*] of ZPRO_I_RECPRO;
}
