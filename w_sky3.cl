procedure w_sky3( p1, p2, p3, p4, p5, p6,chip )

int    p1   {prompt = "First object frame"}
int    p2   {prompt = "Last object frame"}
int    p3   {prompt = "First sky frame of first sky sequence"}
int    p4   {prompt = "Last object frame of first sky sequence"}
int    p5   {prompt = "First object frame of second sky sequence"}
int    p6   {prompt = "Last object frame of second sky sequence"}
int    chip {prompt="Chip number"}

struct *list1

#  Used to sky-subtract crowded-field frames
#  using sky frames created by 'w_skysub' operating
#  on the off-source frames.
#     
#       This script should be equivalent of p_sky3 for PANIC/RetroCAM
#


begin
	int k
	string stsect, fname, isx_frame, root_name, sp1, sp2, sp3, sp4, sp5, sp6
	real sky3_lev, sky5_lev, obj_lev

	stsect = "[41:984,41:984]"

	padindex(p1); sp1 = padindex.output
	padindex(p2); sp2 = padindex.output
	padindex(p3); sp3 = padindex.output
	padindex(p4); sp4 = padindex.output
	padindex(p5); sp5 = padindex.output
	padindex(p6); sp6 = padindex.output

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

	if ( access ( "sky_"//sp3//"_"//sp4//"_c"//k//".fits") && access ( "sky_"//sp5//"_"//sp6//"_c"//k//".fits")) {

	  keypar("sky_"//sp3//"_"//sp4//"_c"//k,"EXPTIME",silent+)
	  sky3_lev = real(keypar.value)

	  keypar("sky_"//sp5//"_"//sp6//"_c"//k,"EXPTIME",silent+)
	  sky5_lev = real(keypar.value)
	
	  wclear("sky"); wclear("sky3"); wclear("sky5")

	  imarith ("sky_"//sp3//"_"//sp4//"_c"//k, "/", sky3_lev, "sky3", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

	  imarith ("sky_"//sp5//"_"//sp6//"_c"//k, "/", sky5_lev, "sky5", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

	  imarith ("sky3", "+", "sky5", "sky", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

	  imarith ("sky", "/", 2., "sky", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

#  Now go through list of 'idf' frames

	  w_pre_list ( "idf", p1, p2, k )

	  list1 = "" ; list1 = "idf_c"//k//"_list"
	  while ( fscan ( list1, fname ) != EOF ) 	{

            root_name = substr(fname,5,12)
	    isx_frame = "isx_"//root_name//".fits"
            wclear(isx_frame )

	    keypar(fname,"EXPTIME",silent+)
	    obj_lev = real(keypar.value)

	    wclear("dummy")
	  
	    imarith ("sky", "*", obj_lev, "dummy", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

	    imarith (fname, "-", "dummy", isx_frame, title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

	    w_store ( "dummy" )
	    keypar ( "dummy","FRMEDIAN",silent+ ) 
	    obj_lev = real(keypar.value)

#	Remove residual sky treated as a constant (the median) for now.

	    w_offset_level ( isx_frame, "median" )

#	Set frame edges to zero

	    w_zero_edges ( isx_frame )

#	Keep estimated sky level in headers.

	    parkey ( obj_lev, isx_frame, "SKYLEV", add+ )

	  }

	}  else { 
	  wsorry ("Off-source sky frame ") 
	}
	}
	  }
# Clean up

	wclear("dummy")
	wclear("sky"); wclear("sky3"); wclear("sky5")
	wclear("idf_c"//k//"_list")

end
