@EndUserText.label: 'Material Condition'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZPRO_I_MSUBCO
  as select from zpro_tb_msubco

  association        to parent ZPRO_I_MATCOND as _MaterialCondition on  _MaterialCondition.pronr    = $projection.pronr
                                                                    and _MaterialCondition.matconid = $projection.matconid
  association [1..1] to ZPRO_I_HEADER         as _Promotion         on  $projection.pronr = _Promotion.pronr
{
  key zpro_tb_msubco.pronr,
  key zpro_tb_msubco.matconid,
  key zpro_tb_msubco.msubcoid,
      zpro_tb_msubco.cond,
      zpro_tb_msubco.opti,
      zpro_tb_msubco.cond_val,
      zpro_tb_msubco.fieldname,
      _MaterialCondition,
      _Promotion
}
