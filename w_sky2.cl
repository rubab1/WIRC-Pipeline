procedure w_sky2 ( p1, p2, p3, p4, chip )

int p1
int p2
int p3
int p4
int chip
struct *list1, *list2

#	Second alternative sky subtraction method for WIRC or 
#	FourStar frames.
#	This is a modified version of w_sky4. This version done by GF.
#
#	In this case the median sky is created from 
#       a combination of the p3,p4,chip frames and the p1,p2,chip frames
#	excluding the frame of interest. Scaled versions
#	are subtracted from the p1,p2 'idf' frames to produce
#	p1,p2 'isx' frames. The p3,p4 'idf' frames are first scaled by 
#	exposure time before imcombining with the p1.p2 set.
#
#	USES:
#
#	1.   Primarily for standard stars where no cleaning via Sextractor
#	     is to be done.
#
#	CAVEATS:
#
#	This will work better than 'w_sky3' if the airmasses are rather
#	different or if >~ 1/2 hour has elapsed between sequences. 
#	
#	Assumes that 'idf' frames exist. These are 
#	linearized, loop-combined, and flattened versions.
#
#	Assumes that xfid,yfid values are stored in the header of the 
#	frame/chip of interest, which will always be p1 in the list
#
#	This produces 'isx' frames
#
#	Assumes that all frames p1 - p2 have the same
#	filter and exposure time. Likewise for p3 - p4. 
#	
#	Assumes that the median value of each frame has 
#	been stored in the header as "FRMEDIAN"
#
#	DIFFERENCES WITH w_sky4:
#
#	This one requires 'chip' as input.
#	Does not do imreplace to clean quadrant boundaries.

begin
	int i, k
	real sky_med, frm_med, ratio, etime1, etime3, eratio, isx_med
	string idf_frame, isx_frame, root_name
	string idf_scaled, idf_test, sp1, sp3

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

# Get date from header keyword NIGHT

	padindex(p1) ; sp1 = padindex.output
	padindex(p3) ; sp3 = padindex.output

# Get exptime from headers for scaling

	idf_frame = "idf_"//sp1//"_c"//k
	keypar(idf_frame,"EXPTIME",silent+)
	etime1 = real(keypar.value)

	idf_frame = "idf_"//sp3//"_c"//k
	keypar(idf_frame,"EXPTIME",silent+)
	etime3 = real(keypar.value)

	eratio = etime1/etime3

# Create list of 'idf' frames that will be used to make sky frame
# This creates 'idf_cX_list'  (with X = chip = 1, 2, 3, or 4)

	w_pre_list ( "idf", p3, p4, k )

# Scale these by exptime

	wclear("p3list")
	list1 = "" ; list1 = "idf_c"//k//"_list"
	while ( fscan ( list1, idf_frame) != EOF ) {
	  idf_scaled = idf_frame//"_scl"
	  wclear ( idf_scaled )
	  imarith(idf_frame,"*",eratio,idf_scaled)
	  print(idf_scaled, >> "p3list")
	}
# Go through list of p1,p2,chip frames excluding the frame to be subtracted
  
	wclear ( "isx_list" )
	w_pre_list ( "idf", p1, p2, k )
	list1 = "" ; list1 = "idf_c"//k//"_list"
	while ( fscan ( list1, idf_frame ) != EOF ) {
	  wclear("plist") ; copy ( "p3list","plist")
	  list2 = "" ; list2 = "idf_c"//k//"_list"
	  while ( fscan ( list2, idf_test ) != EOF ) {
	    if ( idf_test != idf_frame ) print ( idf_test, >> "plist")
	  }

# Combine images using median
	  wclear ("sky")
	  imcombine ( "@"//"plist", "sky.fits", headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="", sigmas="", logfile="STDOUT", combine="median", reject="pclip", project=no, outtype="real", outlimits="", offsets="none", masktype="none", maskvalue=0., blank=0., scale="mode", zero="none", weight="none", statsec="[20:990,20:990]", expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)

# Store image statistics in header and get the median
	  w_store ( "sky" )
	  keypar ( "sky.fits", "FRMEDIAN", silent+ )
	  sky_med = real(keypar.value)
	  wclear ( "sky_"//sp1//"_c"//k )
	  imcopy ( "sky", "sky_"//sp1//"_c"//k )

# Scale the sky frame to the median value of each frame and subtract.
# Recalculate sky every time through.

	  keypar(idf_frame, "FRMEDIAN",silent+)
	  frm_med = real(keypar.value)
	  ratio = frm_med / sky_med

          root_name = substr(idf_frame,5,9)
	  isx_frame = "isx_"//root_name//"_c"//k//".fits"
          wclear (isx_frame )

	  wclear ( "dummy" )
	  imarith ( "sky.fits", "*", ratio, "dummy", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no )
	  imarith ( idf_frame, "-", "dummy", isx_frame, title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no )

# TOOK THIS OUT. ONLY LEFT THE w_store CALL.
#  The following imreplace step is just a quick-and-dirty way to clean up
#  the quadrant boundaries for standard stars; this could be improved by
#  rewriting the '.pl' mask frames just for the short-exposure standards.
#
	  w_store(isx_frame)
#	  keypar ( isx_frame, "FRMEDIAN", silent+ )
#	  isx_med = real(keypar.value)
#	  imreplace(isx_frame//"[511:512,1:1024]", isx_med)
# Maybe it's worth trying an 'imedit'
#

# Put mask and sky level into 'isx' and 'idf' frame headers

	  parkey ( "mcx_"//root_name//"_c"//k//".pl", isx_frame, "BPM", add+)
	  parkey ( "mcx_"//root_name//"_c"//k//".pl", idf_frame, "BPM", add+)
#  Note this is the MEDIAN while for objects, the MODE is used.(Check this)
	  hedit (  isx_frame, "SKYLEV", frm_med, add+, verify-, update+)
	}
	  }
	}
# Clean up
  	wclear ( "p3list" ); wclear ( "plist" ); wclear ( "sky" )
  	wclear ( "dummy" )
	wclear ( idf_scaled )
end
