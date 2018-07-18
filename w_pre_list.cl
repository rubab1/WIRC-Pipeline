procedure w_pre_list ( pre, p1, p2, chip )

string pre
int p1, p2, chip

#	For any frames of the form pre_NNNNN_cX - not pre_NNNNN_cX_001 etc,
#	make a list of all frames that exist between 
#	frame numbers p1 and p2. Names of files are pre_cX_list.

#	GF added the treatment of irx frames.
#	
#	Rev:  03apr2004   SEP
#	Rev:  29oct2004   GF

begin
	int i
	string onumber, frame

	wclear ( pre//"_c"//chip//"_list" )
	if (pre != "irx") {
	  for ( i = p1; i <= p2 ; i += 1) {
	    padindex(i)  ; onumber = padindex.output
	    frame = pre//"_"//onumber//"_c"//chip
	    if ( access ( frame//".fits" )) {
	      print ( frame, >> pre//"_c"//chip//"_list" )
	    }
	  }
	} else {
	  for ( i = p1; i <= p2 ; i += 1) { 	
	    padindex(i)  ; onumber = padindex.output
	    frame = pre//"_"//onumber//"_c"//chip//"_001"
	    if ( access ( frame//".fits" )) {
	      w_loop_expand ( frame, chip )
	      type ( frame//"_list", >> pre//"_c"//chip//"_list" )
	    }
	  }
	}

end






















