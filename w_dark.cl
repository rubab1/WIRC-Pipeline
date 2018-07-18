procedure w_dark ( n1, n2 )

int n1
int n2
struct *list1

#	Searches through 'icx' frames for darks, and creates 
#	'dk_exptime_chip_date' frames.
#	Simple script expects only one 'icx' frame per exptime.

begin
	int etime
	string icx_frame, type, date, padtime, default_path, dk_frame

	wclear("copy.sh")
	for ( k = 1 ; k <= 4 ; k += 1 )	{
	  w_pre_list ( "icx", n1, n2, k )
	  if ( access ( "icx_c"//k//"_list" )) {
	    list1 = ""; list1 = "icx_c"//k//"_list"
	    while (fscan (list1, icx_frame ) != EOF ) {
	      keypar (icx_frame, "OBSTYPE", silent+)
	      type = str(keypar.value)
	      if ( type == "dark" ) {
	        keypar (icx_frame, "EXPTIME", silent+)
	        etime = int(keypar.value)
	        padindex(etime)
	        padtime = substr(padindex.output,3,5)
	        keypar (icx_frame, "NIGHT", silent+)
	        date = str(keypar.value)
	        dk_frame = "dk_"//padtime//"_c"//k//"_"//date
	        wclear ( dk_frame )
	        imcopy ( icx_frame, dk_frame, verbose+ )
		show ("wfiles") | scan (default_path)
		print("cp "//dk_frame//".fits "//default_path//"darks/", >> "copy.sh")
		print("chmod 664 "//default_path//"darks/"//dk_frame//".fits", >> "copy.sh")
#		print("chgrp rwxirphot "//default_path//"darks/"//dk_frame//".fits", >> "copy.sh")
	       # default_path = "wfiles$darks/"
	      #  copy ( dk_frame//".fits", default_path, verbose+ )
	      } else {}
	    }
	  } else {}
	}
	! source copy.sh
end
