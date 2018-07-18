# W_REDUCE
# Package deginition for 'w_reduce'

# Load necessary packages.

digiphot
apphot
stsdas
tables
ttools
imgtools
noao
proto
imred
crutil
xdimsum

package w_reduce

set    stdimage=imt1024
set    uparm	= "home$uparm_wirc/"
set    wfiles = "/home/bessel/khan/Databin/GC_Data/calibrations/"

#  Setup Scripts

task mk_crdlist           = wirc_pp$mk_crdlist.cl
task w_fid                = wirc_pp$w_fid.cl
task w_fid_a              = wirc_pp$w_fid_a.cl
task w_fid_c              = wirc_pp$w_fid_c.cl
task w_fid5               = wirc_pp$w_fid5.cl
task w_mfid               = wirc_pp$w_mfid.cl
task $w_load              = wirc_pp$w_load.cl
task $w_expunge           = wirc_pp$w_expunge.cl
task w_sh_mfid		  = wirc_pp$w_sh_mfid.cl
task w_show_fid	  	  = wirc_pp$w_show_fid.cl
task w_chk_headers        = wirc_pp$w_chk_headers.cl
task w_fix_headers        = wirc_pp$w_fix_headers.cl
task w_chk_dark           = wirc_pp$w_chk_dark.cl
task w_fx_asecs           = wirc_pp$w_fx_asecs.cl 

#   Pipeline scripts
# General scripts
task w_1go                = wirc_pp$w_1go.cl
task w_2go                = wirc_pp$w_2go.cl
task w_linearize2         = wirc_pp$w_linearize2.cl
task w_defaults           = wirc_pp$w_defaults.cl
task w_loops_combine      = wirc_pp$w_loops_combine.cl
task w_dark               = wirc_pp$w_dark.cl
task w_subdk              = wirc_pp$w_subdk.cl
task w_dflat              = wirc_pp$w_dflat.cl
task w_mask_comb          = wirc_pp$w_mask_comb.cl
task w_tflat              = wirc_pp$w_tflat.cl
task w_flatten            = wirc_pp$w_flatten.cl
task w_objmask            = wirc_pp$w_objmask.cl
task w_offset_level       = wirc_pp$w_offset_level.cl
task w_zero_edges         = wirc_pp$w_zero_edges.cl

#   Stacking scripts

task w_sky1               = wirc_pp$w_sky1.cl
task w_sky2               = wirc_pp$w_sky2.cl
task w_sky3               = wirc_pp$w_sky3.cl
task w_sky4               = wirc_pp$w_sky4.cl
task w_sky5               = wirc_pp$w_sky5.cl
task w_dither1            = wirc_pp$w_dither1.cl
task w_dither             = wirc_pp$w_dither.cl
task w_stk1               = wirc_pp$w_stk1.cl
task w_stk2               = wirc_pp$w_stk2.cl
task w_stk3               = wirc_pp$w_stk3.cl
task w_stk4               = wirc_pp$w_stk4.cl
task w_mask1              = wirc_pp$w_mask1.cl
task w_mask2              = wirc_pp$w_mask2.cl
task w_sksub              = wirc_pp$w_sksub.cl
task w_sksub1             = wirc_pp$w_sksub1.cl
task w_sksub2             = wirc_pp$w_sksub2.cl
task w_skysub              = wirc_pp$w_skysub.cl
task w_std                = wirc_pp$w_std.cl
task w_rmskstk            = wirc_pp$w_rmskstk.cl
task w_avecomb            = wirc_pp$w_avecomb.cl
task w_chip_comb            = wirc_pp$w_chip_comb.cl

#  Scripts called from pipeline 

task w_pre_list           = wirc_pp$w_pre_list.cl
task w_raw_list           = wirc_pp$w_raw_list.cl
task w_loop_expand        = wirc_pp$w_loop_expand.cl
task w_loopavg            = wirc_pp$w_loopavg.cl
task w_store              = wirc_pp$w_store.cl
task w_norm               = wirc_pp$w_norm.cl
task w_edges              = wirc_pp$w_edges.cl
task w_get_date           = wirc_pp$w_get_date.cl
task w_offreset           = wirc_pp$w_offreset.cl
task w_reset              = wirc_pp$w_reset.cl

#  Utility scripts

task wclear               = wirc_pp$wclear.cl
task wsorry               = wirc_pp$wsorry.cl
task w_mimdel             = wirc_pp$w_mimdel.cl
task padindex             = wirc_pp$padindex.cl
task w_clean_up           = wirc_pp$w_clean_up.cl

#  Auxiliary scripts

task overheads            = wirc_pp$overheads.cl
task addsnpos             = wirc_pp$addsnpos.cl
#task showsnpos            = wirc_pp$showsnpos.cl
task chk_sn_stks          = wirc_pp$chk_sn_stks.cl
task chk_std_stks         = wirc_pp$chk_std_stks.cl
task xsncorr              = wirc_pp$xsncorr.cl
task chk_frames           = wirc_pp$chk_frames.cl
task w_mkbkp              = wirc_pp$w_mkbkp.cl
task w_bptest             = wirc_pp$w_bptest.cl

#   Observing scripts

task disi                 = wirc_pp$disi.cl
task avgo                 = wirc_pp$avgo.cl
task w_quick              = wirc_pp$w_quick.cl

#   SPP programs

task ir_linearize         = "wirc_pp$x_w_reduce.e"

clbye()
	

