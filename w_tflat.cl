procedure w_tflat ( p1, p2 )

int p1
int p2
struct *list1

#	Assumes that 'icd' linearized, loop-combined, and 
#	dark-subtracted frames exist. 
#
#	'p1' and 'p2' are the starting and ending 
#	frame numbers (of valid non-saturated) frames of a set  
#	taken as the sky is changing during twilight.
#
#	It is assumed that 'w_chk_headers' and 'w_fix_headers' have 
#	been run and that therefore it is not necessary to check  
#	for filter consistency.
#
#	The existence of frames within a set is not assumed (in
#	case it has been necessary to delete some) but is worked
#	around. However frames p1 and p2 must exist.
#
#	This script assumes that the data have been taken
#	according to the procedure specified for twiflats
#	in the WIRC camera control gui. IN PARTICULAR, the
#	telescope must be moved between frames so that field
#	stars can be medianed away. 
#
#	If there are any bright stars in these frames, this 
#	script will not work well unless N > 10 or even 15.
#
#	It is assumed FOR NOW that they all have the same exposure time.
#	These difference frames are imcombined with scaling on.
#
#	Rev: 28nov2003  SEP
#	Rev: 12mar2004  SEP
#	Rev: 13mar2004  SEP
#	Rev: 14mar2004  SEP - now wants dark-subtracted frames.

begin
	string onumber1, onumber2, date, filter_p1, filter_p2, default_path
	string icd_1,icd_2
	int k

	wclear("copy.sh")
	for ( k = 1 ; k <= 4 ; k += 1 )	{

#	Get filter and date out of headers

	  padindex(p1) ; onumber1 = padindex.output
	  padindex(p2) ; onumber2 = padindex.output

	  icd_1 = "icd_"//onumber1//"_c"//k//".fits"
	  icd_2 = "icd_"//onumber2//"_c"//k//".fits"

	  if ( access ( icd_1) && access ( icd_2)) {
	    keypar(icd_1, "FILTER",silent+)
	    filter_p1 = str(keypar.value)
	    keypar(icd_2, "FILTER",silent+)
	    filter_p2 = str(keypar.value)
	    keypar(icd_1, "NIGHT",silent+)
	    date = str(keypar.value)
#							
#	Check for filter consistency

	    if ( filter_p1 == filter_p2 ) {
	      w_pre_list ( "icd", p1, p2, k )
	      wclear ( "flat" )
	      wclear ("nwtflat"//filter_p1//"c"//k//"_"//date)

	      imcombine ("@"//"icd_c"//k//"_list", "flat", headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="", sigmas="", logfile="STDOUT", combine="median", reject="pclip", project=no, outtype="real", outlimits="", offsets="none", masktype="none", maskvalue=0., blank=0., scale="median", zero="none", weight="none", statsec="", expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)
 
#	Normalize
#	Fix edges, which also stores image statistics

	      w_norm ( "flat", "flat", "median" )
	      w_edges ( "flat" )

#	Get rid of nonsensical values. SEE COMMENTS IN w_dflat.cl

	      imreplace ("flat", 1, imaginary=0., lower=INDEF, upper=0.2, radius=0.)
	      imreplace ("flat", 1, imaginary=0., lower=5, upper=INDEF, radius=0.)
 
	      wclear ( "nwtflat"//filter_p1//"c"//k//"_"//date )
	      imrename ( "flat", "nwtflat"//filter_p1//"c"//k//"_"//date, verbose- )

     #         default_path = "wfiles$flats/"
		show ("wfiles") | scan (default_path)
		print("cp nwtflat"//filter_p1//"c"//k//"_"//date//".fits "//default_path//"flats/", >> "copy.sh")
		print("chmod 664 "//default_path//"flats/nwtflat"//filter_p1//"c"//k//"_"//date//".fits", >> "copy.sh")
#		print("chgrp rwxirphot "//default_path//"flats/nwtflat"//filter_p1//"c"//k//"_"//date//".fits", >> "copy.sh")
	#      copy ( "nwtflat"//filter_p1//"c"//k//"_"//date//".fits", default_path, verbose+ )
	    } else {
	      print ( "" )
	      print ( "  >> SORRY: Filters are not consistent " )
	      print ( "" )
	    }
	  }
	}
	! source copy.sh
end
