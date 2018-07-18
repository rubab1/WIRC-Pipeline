procedure w_chk_headers ( n1, n2 )

int n1
int n2

#	Extracts header information to a file
#	'arb_name' which can be edited to fix title, object,
#	obstype, airmass and night parameters.  
#	Gets information from the chip = 1 frame if it
#	exists, or 2, ... etc.

begin
	int i
	string pic, onumber, frame

	for ( i = n1 ; i <= n2 ; i += 1) {

	  padindex(i) ; onumber = padindex.output
	  frame = "irx_"//onumber//"_c1_001.fits"
	  if ( !access ( frame)) frame = "irx_"//onumber//"_c2_001.fits"
	  if ( !access ( frame)) frame = "irx_"//onumber//"_c3_001.fits"
	  if ( !access ( frame)) frame = "irx_"//onumber//"_c4_001.fits"

	  if ( access ( frame )) {
	    hselect ( frame, "$I, title, object, obstype, filter, airmass, exptime, night", "yes" )
	  }	   
	}
end
