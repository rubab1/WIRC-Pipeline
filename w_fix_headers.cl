procedure w_fix_headers ( arb_name )

string arb_name
struct *list1

#	Works with 'w_chk_headers.cl' and the 
#	resulting filelist 'arb_name'.
#
#	Usage:  (1) run 'w_chk_headers' 
#               (2) edit the 'arb_name' file to correct errors
#               (3) run 'w_fix_headers' arb_name
#	
#	This will fix all the 'irx*_c*_001 ' frame header parameters

begin
	int i, nloops, k
	string frame, framein, title, object, obstype, filter, night
	real airmass, exptime

	list1 = "" ; list1 = arb_name
	while ( fscan ( list1, framein, title, object, obstype, filter, airmass, exptime, night ) != EOF ) {
	  for ( k = 1 ; k <= 4 ; k += 1 ) {
	    frame = substr(framein,1,11)//k//substr(framein,13,21)
	    if ( access ( frame )) {
	      hedit ( frame, "TITLE"  , title , verify-, show-, add+, update+ )
	      hedit ( frame, "OBJECT" , object , verify-, show-, add+, update+ )
#	      hedit ( frame, "OBSTYPE", obstype, verify-, show-, add+, update+ )
# 	      hedit ( frame, "FILTER", filter, verify-, show-, add+, update+ )
#	      hedit ( frame, "AIRMASS", airmass, verify-, show-, add+, update+ )
#	      hedit ( frame, "EXPTIME", exptime, verify-, show-, add+, update+ )
	      hedit ( frame, "NIGHT"  , night  , verify-, show-, add+, update+ )
	    } else {}
	  }
	}
end
