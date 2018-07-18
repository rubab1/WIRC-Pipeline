procedure w_subdk ( n1, n2 )

int n1
int n2
struct *list1

#	Searches through 'icx' frames for non-dark frames
#	and subtracts the appropriate dark created by 'w_dark' 

begin
	int etime, k
	string icx_frame, icd_frame, root_name, type, padtime, date
	string dk_frame, fnumber

	for ( k = 1 ; k <= 4 ; k += 1 ) {
	  w_pre_list ( "icx", n1, n2, k )
	  if ( access ( "icx_c"//k//"_list" )) {
	    list1 = ""; list1 = "icx_c"//k//"_list"
	    while (fscan (list1, icx_frame ) != EOF ) {
	      keypar (icx_frame, "OBSTYPE", silent+)
	      type = str(keypar.value)
	      keypar (icx_frame, "NIGHT", silent+)
	      date = str(keypar.value)
	      if ( type != "dark" ) {
	        fnumber = substr(icx_frame,5,9)
	        icd_frame = "icd_"//fnumber//"_c"//k
	        wclear ( icd_frame )
	        keypar (icx_frame, "EXPTIME", silent+)
	        etime = int(keypar.value)
	        padindex(etime)
	        padtime = substr(padindex.output,3,5)
	        dk_frame = "dk_"//padtime//"_c"//k//"_"//date
	        if ( access  ( dk_frame//".fits" )) {
	          imarith (icx_frame, "-", dk_frame, icd_frame, title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
		  hedit (icd_frame, "DARK", dk_frame, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
	        } else {
	          wsorry ( dk_frame )
	        }
	      } else  {}
	    }
	  }  else {}
	}
end
