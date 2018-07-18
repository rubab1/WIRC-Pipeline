procedure w_raw_list ( pre, p1, p2, chip )

string pre
int p1
int p2 
int chip

#	For irx (wirc) or irf (fourstar)
#	make a list of all frames that exist between 
#	frame numbers p1 and p2. 'chip' is 1, 2, 3, or 4, NOT
#	0 or 5.
#	Rev:  30nov2003   SEP

begin
	string onumber, frame
	int nloops

# Set the frame prefix according to the camera
	wclear ( "raw_pic_list" )
	for ( i = p1; i <= p2 ; i += 1) {
	  padindex(i)  ; onumber = padindex.output
	  frame = pre//"_"//onumber//"_c"//chip
	  if ( access ( frame//"_001.fits" ))	{
	    w_loop_expand ( frame, chip )
	    page ( frame//"_list", >> "raw_pic_list" )
	  }
	  wclear ( frame//"_list" )
	}
end






















