procedure w_fid_c ( p1, p2, p3, p4, p5, p6, chip, autman )

int p1, p2, p3, p4, p5, p6 
int chip	{prompt="Chip number"}
string autman	{"aut",enum="aut|man",prompt="Automatic or manual star selection?"}
struct *list1


# Selects a fiducial star for sequence p1 - p2.
# Uses Sextractor.
#  This variant uses the 
#  sky frames created for the off-source positions

begin
	string pre, sp1, sp3, sp5, isx_frame
	real xfid, yfid, mag, elli, fwhm, fhthr, fhtmin, ellithr
	int flag

	  padindex(p1); sp1 = padindex.output
	  padindex(p3); sp3 = padindex.output
	  padindex(p5); sp5 = padindex.output

	isx_frame = "isx_"//sp1//"_c"//chip
        wclear (isx_frame )

	wclear ("sky") 
	if ( access ( "sky_"//sp3//"_c"//chip//".fits") && access ( "sky_"//sp5//"_c"//chip//".fits")) {
	  imarith ( "sky_"//sp3//"_c"//chip, "+", "sky_"//sp5//"_c"//chip, "sky")
	  imarith ( "sky","/", 2., "sky")
		}  else { 
	wsorry ("Off-source sky frame ") 
			}
	
#  In general cannot scale sky frame to median of crowded frame; just subtract. 

	fhtmin = 2.5
	fhthr = 10.0
	ellithr = 0.2

	if ( chip <= 4 )	{

	if ( access ("idf_"//sp1//"_c"//chip//".fits")) {
	   pre = "idf" 
	} else {
		pre = "icx"
		w_loops_combine ( "irx", p1, p2 ,chip)
	  }
}

	imarith ( pre//"_"//sp1//"_c"//chip, "-", "sky", isx_frame ) 

        wclear ( "sex_frame" )
	imcopy (isx_frame, "sex_frame", ver-)

# If on automatic mode: Call sextractor.
# Make a list of objects, sort it by decreasing magnitude, select the first object
# with 'flag = 0' and far enough from the borders:

	if (autman == "aut") {
	  wclear ("sex.cat"); wclear ("init.dat")

	  !sex sex_frame.fits -c default_fid.sex
	  !egrep -v # sex.cat | sort -g > init.dat

	  list1 = "" ; list1 = "init.dat"
	  while ( fscan ( list1, mag, xfid, yfid, elli, fwhm, flag ) != EOF )	{ 

	    if (flag == 0 && xfid > 80 && xfid < 944 && yfid > 80 && yfid < 944  \
	    && elli < ellithr && fwhm < fhthr ) goto found
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
	tvmark (1,"slist", mark="circle", radii=10, color=206, interac-)
	tvmark (1,"slist", mark="circle", radii=11, color=206, interac-)

	wclear ( isx_frame )

	if ( pre == "idf" )	{

	parkey ( xfid, "irx_"//sp1//"_c"//chip//"_001.fits", "XFID", add+) 
	parkey ( yfid, "irx_"//sp1//"_c"//chip//"_001.fits", "YFID", add+)
 	parkey ( xfid, "idf_"//sp1//"_c"//chip//".fits", "XFID", add+) 
	parkey ( yfid, "idf_"//sp1//"_c"//chip//".fits", "YFID", add+)
	   
	} else {

	parkey ( xfid, "irx_"//sp1//"_c"//chip//"_001.fits", "XFID", add+) 
	parkey ( yfid, "irx_"//sp1//"_c"//chip//"_001.fits", "YFID", add+)

	}


# Final clean-up

	wclear ("dummy"); wclear ("sky")
	wclear ("init.dat")
	wclear ("slist"); wclear ("sex_frame"); wclear ("sex.cat")


end
