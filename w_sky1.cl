procedure w_sky1 ( pre, p1, p2, chip )

string pre
int p1
int p2
int chip
struct *list1

#	First-pass sky creation and subtraction
#	for WIRC or FOURSTAR frames. If chip = 0 or 5
#	all four chips are done.
#	
#	Assumes that 'idf' frames exist for normal data 
#	reduction.  These are 
#	linearized, loop-combined, and flattened versions
#	of the raw 'irx' or 'irf' frames.
#
#	However, for quick-looks 'pre' can be 'icp'.
#
#	This produces 'isx' versions with median sky value = 0.0
#
#	Assumes that all frames p1 - p2 have the same
#	filter and exposure time.
#	
#	Assumes that the median value of each frame has 
#	been stored in the header as 'FRMEDIAN'

begin
	int k
	real sky_med, frm_med, ratio
	string pre_frame, isx_frame, isx_list, root_name, onumber

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {
	    w_pre_list ( pre, p1, p2, k )
	    if ( access ( pre//"_c"//k//"_list" )) {

# Combine images using median

	      wclear ("sky.fits")
	      imcombine ("@"//pre//"_c"//k//"_list", "sky.fits", headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="", sigmas="", logfile="STDOUT", combine="median", reject="pclip", project=no, outtype="real", outlimits="", offsets="none", masktype="none", maskvalue=0., blank=0., scale="mode", zero="none", weight="none", statsec="", expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)
 
	      w_store ( "sky" )
	      keypar("sky", "FRMEDIAN",silent+)
	      sky_med = real(keypar.value)

# Scale the sky frame to the median value of each frame and subtract.
# Recalculate sky every time through.

	      list1 = "" ; list1 = pre//"_c"//k//"_list"
	      while ( fscan ( list1, pre_frame ) != EOF ) {

	        w_store ( pre_frame )
	        keypar(pre_frame, "FRMEDIAN",silent+)
	        frm_med = real(keypar.value)
	        ratio = frm_med / sky_med
                root_name = substr(pre_frame,5,12)
	        isx_frame = "isx_"//root_name//".fits"
                wclear (isx_frame )
	        wclear ( "dummy" )
	        imarith ("sky.fits", "*", ratio, "dummy", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
	        imarith (pre_frame, "-", "dummy", isx_frame, title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
                wclear ( "dummy" )
#
# No offset level applied
#
# Remove residual sky treated as a constant (the median) for now.
#
#	        p_offset_level ( isx_frame, "median" )
#
# Set frame edges to zero
#
#	        p_zero_edges ( isx_frame )
#
	      }
	    } else {}
	  }
	}
# Clean up
	wclear ("sky.fits")

end
