procedure w_sky5 ( pre, p1, p2,chip )

string pre	{"idf", prompt = "Image prefix"}
int p1		{prompt = "First frame"}
int p2		{prompt = "Last frame"}
int chip   {prompt="Chip number"}

struct *list1, *list2

#	First-pass sky creation and subtraction
#	for WIRC frames
#     
#       This script should be equivalent of p_sky1 for PANIC/RetroCAM
#
#	This produces 'isx' versions with median sky value = 0.0
#
#	Assumes that all frames p1 - p2 have the same
#	filter and exposure time.

begin

	int k
	string stsect, fname, isx_frame
	string skyname, root_sky, root_name, sp1, sp2
	real sky_lev, frm_lev, ratio

	padindex(p1); sp1 = padindex.output
	padindex(p2); sp2 = padindex.output

	stsect = "[41:984,41:984]"


	for ( k = 1 ; k <= 4 ; k += 1 ) {
	  if ( k == chip || chip == 5 || chip == 0 ) {
	    w_pre_list ( pre, p1, p2, k )
	    if ( access ( pre//"_c"//k//"_list" )) {

	wclear ( "sky_"//sp1//"_"//sp2//"_c"//k )

	imcombine ("@"//pre//"_c"//k//"_list", "sky_"//sp1//"_"//sp2//"_c"//k, headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="", sigmas="", logfile="STDOUT", combine="median", reject="pclip", project=no, outtype="real", outlimits="", offsets="none", masktype="none", maskvalue=0., blank=0., scale="mode", zero="none", weight="none", statsec=stsect, expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)

	w_store ( "sky_"//sp1//"_"//sp2//"_c"//k )

# Find surrounding images for sky frame; use all but the one at the same
# dither position.

	list1 = "" ; list1 = pre//"_c"//k//"_list"
	while ( fscan ( list1, fname ) != EOF ) 	{

           root_name = substr(fname,5,12)

	   wclear ("sky_list")
           list2 = "" ; list2 = pre//"_c"//k//"_list"
           while (fscan (list2,skyname) !=EOF) {

	      root_sky = substr(skyname,5,12)

	      if (skyname != fname ) {
	         print ("idf_"//root_sky//".fits", >> "sky_list")
	      }
	   }  # close sky_list while

	   wclear("sky_"//root_name)

	   imcombine ("@sky_list", "sky_"//root_name , headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="", sigmas="", logfile="STDOUT", combine="median", reject="pclip", project=no, outtype="real", outlimits="", offsets="none", masktype="none", maskvalue=0., blank=0., scale="mode", zero="none", weight="none", statsec=stsect, expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)

	  w_store ( "sky_"//root_name )
	  keypar("sky_"//root_name, "FRMEDIAN", silent+)
	  sky_lev = real(keypar.value)

	  keypar(fname, "FRMEDIAN",silent+)
	  frm_lev = real(keypar.value)

	  ratio = frm_lev / sky_lev

	  isx_frame = "isx_"//root_name//".fits"
          wclear ( isx_frame )

	  wclear ( "dummy" )

	  imarith ("sky_"//root_name, "*", ratio, "dummy", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

	  imarith (fname, "-", "dummy", isx_frame, title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

	  wclear ( "dummy" )

	  parkey ( frm_lev, isx_frame, "SKYLEV", add+ )

#	Remove residual sky treated as a constant (the median) for now.

	  w_offset_level ( isx_frame, "median" )

#	Set frame edges to zero

	  w_zero_edges ( isx_frame )
							}
				}
	  }
	}
# Clean up

	wclear ( pre//"_c"//k//"_list" )
	wclear ( "sky_list" )

end
