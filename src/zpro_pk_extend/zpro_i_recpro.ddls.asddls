@EndUserText.label: 'Promotion'
define abstract entity ZPRO_I_RECPRO
{
  pronr        : zde_pronr;
  _RecommentSO : association to parent zpro_d_promotionsuggest;
}
