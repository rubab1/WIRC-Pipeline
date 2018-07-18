procedure w_show_fid ( p1, p2, chip )

int p1, p2, chip

begin

	string pre, onumber, stsect, isx_frame
	real xfid, yfid, frm_med, sky_med, ratio

# Define variables

	padindex(p1); onumber = padindex.output
	wclear ("i_list")

	if ( access ("idf_"//onumber//"_c"//chip//".fits")) {
	  w_pre_list ( "idf", p1, p2, chip )
	  copy ( "idf_c"//chip//"_list", "i_list" )
	  pre = "idf_"
	} else {
	  pre = "icx_"
	  w_loops_combine ( "irx", p1, p2, chip )
	  w_pre_list ( "icx", p1, p2, chip )
	  copy ( "icx_c"//chip//"_list", "i_list" )
	}

#  Now have 'pre' frames p1 through p2, and a list 'i_list'.
#  'pre' is either 'icx_', or 'idf_'. 
#  This next section is from 'w_sky1', but only does first frame.
#  The sky is saved in case it is need for crowded frame IDs. 

	wclear ("sky.fits") ; wclear ( "sky_"//onumber//"_c"//chip)
        imcombine ("@"//"i_list","sky.fits", combine="median", scale="mode",masktyp="none")
	w_store ( "sky" )
	keypar("sky", "FRMEDIAN",silent+)
	sky_med = real(keypar.value)
	imcopy ( "sky", "sky_"//onumber//"_c"//chip)

# Scale the sky frame to the median value of the first frame and subtract.

	padindex (p1) ; onumber=padindex.output
	w_store ( pre//"_"//onumber//"_c"//chip )
	keypar( pre//"_"//onumber//"_c"//chip, "FRMEDIAN",silent+)
	frm_med = real(keypar.value)
	ratio = frm_med / sky_med

	isx_frame = "isx_"//onumber//"_c"//chip
	wclear (isx_frame)
	wclear ( "dummy" )
	imar ( "sky.fits", "*", ratio, "dummy" )
	imar ( pre//"_"//onumber//"_c"//chip, "-", "dummy", isx_frame )

	keypar( isx_frame, "XFID", silent+)
	xfid = real(keypar.value)
	keypar( isx_frame, "YFID", silent+)
	yfid = real(keypar.value)

	wclear ("slist")
	display (isx_frame, 1, erase-, bor+, fill+, zs+, xmag=0.5, ymag=0.5)
        print (xfid, yfid, > "slist")
	tvmark (1,"slist", mark="circle", radii=10, color=205, interac-)
	tvmark (1,"slist", mark="circle", radii=11, color=205, interac-)

# Final clean-up

	wclear ( isx_frame )
	wclear ("dummy"); wclear ("sky") 
	wclear ("slist")
	wclear ("i_list"); wclear (pre//"_c"//chip//"list")

end
