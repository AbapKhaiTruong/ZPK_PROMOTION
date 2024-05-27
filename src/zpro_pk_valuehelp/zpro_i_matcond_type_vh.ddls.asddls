@EndUserText.label: 'Material Condition Type'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZPRO_I_MATCOND_TYPE_VH
  as select from zpro_tb_matconty
{
      @UI.hidden: true
  key protyp        as Protyp,
      @UI.hidden: true
  key cond_type     as CondType,
      @UI.hidden: true
      cond_type_txt as CondTypeTxt,
      fieldname     as Fieldname,
      @UI.hidden: true
      searchhelp    as Searchhelp

}
