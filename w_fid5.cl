procedure w_fid5 ( p1, p2 )

int p1		{prompt="First frame"} 
int p2		{prompt="Last frame"} 
struct *list1

#  Used during the night to loop-combine 'irx'
#  frames, find median sky, subtract it, and 
#  display the first resulting frame for 
#  identifying the fiducial star. Will use 'idf'
#  frames if they exist.
#
#  This variant displays all four chips arranged
#  as they are on the sky, but inserted in a 2048**2
#  frame. The fiducial star identification is decoded
#  to give the correct chip.   

begin
	string onumber, isx_frame, q1, q2, q3, q4, quad
	real xfid, yfid, frm_med, sky_med, ratio
	real xfid5, yfid5
	int k, chip, chip_fid

	padindex(p1); onumber = padindex.output
	wclear ("i_list")

	q1 = "[1025:2048,1025:2048]"
	q2 = "[1025:2048,1:1024]"
	q3 = "[1:1024,1:1024]"
	q4 = "[1:1024,1025:2048]"

	wclear ( "zero2048" )
	imcopy ( "home$panic_scripts/zero2048.fits", "." )

	for ( k = 1 ; k <= 4 ; k += 1 )	{

          chip = k 
	  if ( chip == 4 ) quad = q4 ; if ( chip == 1 ) quad = q1
	  if ( chip == 3 ) quad = q3 ; if ( chip == 2 ) quad = q2

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
	  imcopy ( "sky", "sky_"//onumber//"_c//chip )

#	Scale the sky frame to the median value of the first frame and subtract.
	  w_store ( pre//onumber//"_c"//chip )
	  keypar( pre//onumber//"_c"//chip, "FRMEDIAN",silent+)
	  frm_med = real(keypar.value)
	  ratio = frm_med / sky_med

	  isx_frame = "isx_"//onumber//"_c"//chip
          wclear (isx_frame )

	  wclear ( "dummy" )
	  imar ( "sky.fits", "*", ratio, "dummy" )


	  imar ( pre//onumber//"_c"//chip, "-", "dummy", isx_frame )
	  imcopy ( isx_frame, "zero2048"//quad )

	}      #  End of k loop

        wclear ("init.dat") ; wclear ("slist") 
	display ("zero2048", 1, erase-, bor+, fill+, zs+, xmag=0.5, ymag=0.5)

# 	Use imexam to interactively get approx coords for fiducial star
#	This could be generalized to a list of stars if we wanted to keep 
#	these files of XY values around until pipeline is used.

	print ( "")
        print ( "  >>>>> Identify a star  ( a  q )  " )
        print ( "")

	imexamine ( "zero2048",1,keeplog+,logfile='slist' )
        !egrep -v '#' slist | awk '{print $1, $2 }' > init.dat

	list1 = "" ; list1 = "init.dat"
	while ( fscan ( list1, xfid5, yfid5 ) != EOF )	{ }
#
#	Decode into correct chip

	xfid = xfid5 ; yfid = yfid5
	if ( xfid5 >= 1025. ) xfid = xfid5 - 1024.
	if ( yfid5 >= 1025. ) yfid = yfid5 - 1024.

	chip_fid = 3
	if ( xfid5 >= 1025. && yfid5 >= 1025. ) chip_fid = 1
	if ( xfid5 >= 1025. && yfid5 <= 1024. ) chip_fid = 2
	if ( xfid5 <= 1024. && yfid5 >= 1025. ) chip_fid = 4

	if ( pre == "icx_" ) {
	  parkey ( xfid, "irx_"//onumber//"_c"//chip_fid//"_001.fits", "XFID", add+) 
	  parkey ( yfid, "irx_"//onumber//"_c"//chip_fid//"_001.fits", "YFID", add+)
	} else {
 	  parkey ( xfid, "idf_"//onumber//"_c"//chip_fid//".fits", "XFID", add+) 
	  parkey ( yfid, "idf_"//onumber//"_c"//chip_fid//".fits", "YFID", add+)
	}
end
