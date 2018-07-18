procedure w_chk_dark ( pre, n1, n2, chip )

string pre	{prompt="Frame prefix"}
int n1		{prompt="First frame"}
int n2		{prompt="Last frame"}
int chip	{prompt="Chip number"}
struct *list1
struct *list2

#	Searches through input frames for darks, and then chacks 
#	that all exptimes are covered. Assumes all frames with
#	equal NIGHT keyword in headers.
#	If some dark is missing, itsexptime will appear in the file
#	'missing_darks'.

begin
	int etime, reftime
	string frame, type, date, refdate, onumber
	bool alltimes, found

	alltimes = yes
	if (pre == "irx") {
	  wclear ("raw_pic_list")
	  for ( i = n1; i <= n2 ; i += 1) {
	    padindex(i)  ; onumber = padindex.output
	    frame = pre//"_"//onumber//"_c"//chip
	    if ( access ( frame//"_001.fits" )) {
	      print ( frame//"_001.fits", >> "raw_pic_list" )
	    }
	  }
	  wclear (pre//"_c"//chip//"_list")
	  copy ("raw_pic_list", pre//"_c"//chip//"_list", verbose-)
	  wclear ("raw_pic_list")
	} else {
	  w_pre_list ( pre, n1, n2, chip )
	}
	if ( access ( pre//"_c"//chip//"_list" )) {
	  wclear ("exptime_list")
	  list1 = ""; list1 = pre//"_c"//chip//"_list"
	  while (fscan (list1, frame ) != EOF ) {
	    keypar (frame, "OBSTYPE", silent+)
	    type = str(keypar.value)
	    if ( type == "dark" ) {
	      keypar (frame, "EXPTIME", silent+)
	      etime = int(keypar.value)
	      keypar (frame, "NIGHT", silent+)
	      date = str(keypar.value)
	      print (etime,"  ",date, >> "exptime_list")
	    } else {}
	  }
	} else {}
	if ( access ( pre//"_c"//chip//"_list" )) {
	  wclear ("missing_darks")
	  list1 = ""; list1 = pre//"_c"//chip//"_list"
	  while (fscan (list1, frame ) != EOF ) {
	    found = no
	    keypar (frame, "EXPTIME", silent+)
	    etime = int(keypar.value)
	    keypar (frame, "NIGHT", silent+)
	    date = str(keypar.value)
	    list2 = ""; list2 = "exptime_list"
	    while (fscan (list2, reftime, refdate ) != EOF ) {
	      if (etime == reftime && date == refdate) {
	        found = yes
	        break
	      }
	    }
	    if (!found) {
	      alltimes = no
	      print ("Missing:  ",frame,"  ",etime,"  ",date)
	      print (frame,"  ",etime,"  ",date, >> "missing_darks")
	    }
	  }
	}
	if (alltimes) print ("All darks are available")

end
