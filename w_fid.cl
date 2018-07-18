procedure w_fid ( p1, p2, chip, autman )

int p1		{prompt="First frame"} 
int p2		{prompt="Last frame"} 
int chip	{prompt="Chip number"}
string autman	{"aut",enum="aut|man",prompt="Automatic or manual star selection?"}
struct *list1

#  Used during the night to loop-combine 'irx'
#  frames, find median sky, subtract it, and 
#  display the first resulting frame for 
#  identifying the fiducial star. Will use 'idf'
#  frames if they exist.

begin
	string onumber, isx_frame, pre
	real xfid, yfid, frm_med, sky_med, ratio
	real mag, elli, fwhm, fhthr, ellithr, fhtmin
	int flag

	padindex(p1); onumber = padindex.output
	wclear ("i_list")

	fhtmin = 2.5
	fhthr = 10.0
	ellithr = 0.2

# Can call 'w_fid5' from within here if chip = 5

	if ( chip <= 4 )	{

	if ( access ("idf_"//onumber//"_c"//chip//".fits")) {
	  w_pre_list ( "idf", p1, p2, chip )
	  copy ( "idf_c"//chip//"_list", "i_list" )
	  pre = "idf_"
	} else {
	  w_loops_combine ( "irx", p1, p2, chip )
	  w_pre_list ( "icx", p1, p2, chip )
	  copy ( "icx_c"//chip//"_list", "i_list" )
	  pre = "icx_"
	}

#  Now have 'pre' frames p1 through p2, and a list 'i_list'.
#  'pre' is either 'icx_' or 'idf_'. 
#  This next section is from 'p_sky1', but only does first frame.

	wclear ("sky.fits")
        imcombine ("@"//"i_list","sky.fits", combine="median", scale="mode",masktyp="none")
	w_store ( "sky" )
	keypar("sky", "FRMEDIAN",silent+)
	sky_med = real(keypar.value)
	wclear ( "sky_"//onumber//"_c"//chip )
	imcopy ( "sky", "sky_"//onumber//"_c"//chip )

# Scale the sky frame to the median value of the first frame and subtract	
	w_store ( pre//onumber//"_c"//chip )
	keypar( pre//onumber//"_c"//chip, "FRMEDIAN",silent+)
	frm_med = real(keypar.value)
	ratio = frm_med / sky_med

	isx_frame = "isx_"//onumber//"_c"//chip
        wclear (isx_frame )

	wclear ( "dummy" )
	imarith ( "sky.fits", "*", ratio, "dummy", divz=1., pixtype="real", calctyp="real", verbose- )
	imarith ( pre//onumber//"_c"//chip, "-", "dummy", isx_frame, divz=1., pixtype="real", calctyp="real", verbose- )

	wclear ( "sex_frame" )
	imcopy (isx_frame, "sex_frame", ver-)

# If on automatic mode: Call sextractor.
# Make a list of objects, sort it by decreasing magnitude, select the first 
# object with 'flag = 0' and far enough from the borders:

	if (autman == "aut") {
	  wclear ("sex.cat"); wclear ("init.dat")

	  !sex sex_frame.fits -c default_fid.sex
	  !egrep -v '#' sex.cat | sort -g > init.dat

	  list1 = "" ; list1 = "init.dat"
	  while ( fscan ( list1, mag, xfid, yfid, elli, fwhm, flag ) != EOF ) { 

	    if (flag == 0 && xfid > 80 && xfid < 944 && yfid > 80 && yfid < 944 \
            && elli < ellithr && fwhm < fhthr && fwhm > fhtmin ) goto found
	  }
	}
# If no suitable FID star was found, or on manual mode, ask the user to mark one:

        wclear ("init.dat") ; wclear ("slist") 
	display (isx_frame, 1, erase-, bor+, fill+, zs+, xmag=0.5, ymag=0.5)
 
        print ( "")
        print ( "  >>>>> Identify a star  ( a  q )  " )
        print ( "")

        imexamine ( isx_frame,1,keeplog+,logfile='slist' )
        !egrep -v '#' slist | awk '{print $1, $2 }' > init.dat

        type ("init.dat") | scan ( xfid, yfid )

found:	
	wclear ("slist")
 	display (isx_frame, 1, erase-, bor+, fill+, zs+, xmag=0.5, ymag=0.5)
        print (xfid, yfid, > "slist")
	tvmark (1,"slist", mark="circle", radii=10, color=205, interac-)
	tvmark (1,"slist", mark="circle", radii=11, color=205, interac-)

	wclear ( isx_frame )

	if ( pre == "icx_" ) {
	  parkey ( xfid, "irx_"//onumber//"_c"//chip//"_001.fits", "XFID", add+)
	  parkey ( yfid, "irx_"//onumber//"_c"//chip//"_001.fits", "YFID", add+)
	} else {
          if ( access ("irx_"//onumber//"_c"//chip//"_001.fits"))  {
	    parkey ( xfid, "irx_"//onumber//"_c"//chip//"_001.fits", "XFID", add+) 
	    parkey ( yfid, "irx_"//onumber//"_c"//chip//"_001.fits", "YFID", add+)
	  }
 	  parkey ( xfid, "idf_"//onumber//"_c"//chip//".fits", "XFID", add+) 
	  parkey ( yfid, "idf_"//onumber//"_c"//chip//".fits", "YFID", add+)
	}
# Calling w_fid5
	} else if ( chip == 5 ) {
		w_fid5 (p1, p2)
	}
# Clean up:
	wclear ("i_list")
	wclear ("dummy"); wclear ("sky"); wclear ("init.dat")
	wclear ("slist"); wclear ("sex_frame"); wclear ("sex.cat")

end
