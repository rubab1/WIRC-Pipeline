procedure w_get_date ( pre, p1 )

string pre     {prompt = "Frame prefix"}
int p1         {prompt = "Frame number"}
string output  {"",prompt = "Return value of output string"}

#       Gets the date for the 'pre' frame 

begin
	string onumber, frame, date
	int k

	padindex(p1) ; onumber = padindex.output

	if ( pre == "irx" ) {
	  for ( k = 1 ; k <= 4 ; k += 1 ) {
	    frame = "irx_"//onumber//"_c"//k//"_001"
	    if ( access ( frame//".fits") ) {
	      keypar(frame,"NIGHT",silent+)
	      date=str(keypar.value)
	      break
	    }
	  }
	} else {
	  for ( k = 1 ; k <= 4 ; k += 1 ) {
	    frame = pre//"_"//onumber//"_c"//k
	    if ( access ( frame//".fits") ) {
	      keypar(frame,"NIGHT",silent+)
	      date=str(keypar.value)
	      break
	    }
	  }
	}
	output=date
end

