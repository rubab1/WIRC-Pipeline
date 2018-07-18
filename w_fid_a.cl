procedure w_fid_a ( p1, p2, p3, p4, chip, autman )

int p1 		{prompt="First object frame"}
int p2  	{prompt="Last object frame"}
int p3 		{prompt="First sky frame"}
int p4 		{prompt="Last sky frame"}
int chip 	{prompt="Chip number"}
string autman	{"aut",enum="aut|man",prompt="Automatic or manual star selection?"}
struct *list1

#  Used during the night to loop-combine 'irx'
#  frames, find median sky, subtract it, and 
#  display the first resulting frame for 
#  identifying the fiducial star. Will use 'idf'
#  frames if they exist. This variant uses the 
#  sky frames created for the off-source positions

begin
	string pre, sp1, sp3, sp5, isx_frame, idf_frame, pre_frame
	real xfid, yfid, frm_med, sky_med, ratio
	real mag, elli, fwhm, fhthr, ellithr, fhtmin
	int flag

	padindex(p1); sp1 = padindex.output
	padindex(p3); sp3 = padindex.output

	fhtmin = 2.5
	fhthr = 10.0
	ellithr = 0.2

	isx_frame = "isx_"//sp1//"_c"//chip
        wclear (isx_frame )

	wclear ("sky") 
	if ( access ( "sky_"//sp3//"_c"//chip//".fits") ) {
	  imcopy ( "sky_"//sp3//"_c"//chip//".fits", "sky")
	}  else { 
	  wsorry ("Off-source sky frame ")
	}
	keypar("sky", "FRMEDIAN",silent+)
	sky_med = real(keypar.value)

	idf_frame = "idf_"//sp1//"_c"//chip
	if ( access ( idf_frame//".fits")) {
	  pre_frame = idf_frame 
	  pre="idf_"
	} else {
	  w_loops_combine ( "irx", p1, p1, chip )     #  only do the first one
	  pre_frame = "icx_"//sp1//"_c"//chip
	  pre = "icx_"
	}

	w_store ( pre_frame )
	keypar( pre_frame, "FRMEDIAN", silent+)
	frm_med = real(keypar.value)

# Scale the sky frame to the median value of the first frame and subtract.

	ratio = frm_med / sky_med

	wclear ( "dummy" )
	imar ( "sky.fits", "*", ratio, "dummy", divz=1., pixtype="real", calctyp="real", verbose-  )
	imar ( pre_frame, "-", "dummy", isx_frame, divz=1., pixtype="real", calctyp="real", verbose-  )

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
            && elli < ellithr && fwhm < fhthr && fwhm > fhtmin) goto found
	  }
	}
# If no suitable FID star was found, ask the user to mark one:

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
	  parkey ( xfid, "irx_"//sp1//"_c"//chip//"_001.fits", "XFID", add+) 
	  parkey ( yfid, "irx_"//sp1//"_c"//chip//"_001.fits", "YFID", add+)
	} else {
          if ( access ("irx_"//sp1//"_c"//chip//"_001.fits"))  {
	    parkey ( xfid, "irx_"//sp1//"_c"//chip//"_001.fits", "XFID", add+) 
	    parkey ( yfid, "irx_"//sp1//"_c"//chip//"_001.fits", "YFID", add+)
	  }
 	  parkey ( xfid, "idf_"//sp1//"_c"//chip//".fits", "XFID", add+) 
	  parkey ( yfid, "idf_"//sp1//"_c"//chip//".fits", "YFID", add+)
	}
end
