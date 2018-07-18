procedure w_norm ( pic_in, pic_out, ntype )

string pic_in, pic_out, ntype

#	Normalizes pic_in to the value of its 
#	mean, median, or mode; this is the 'type'.
#	'mean' or 'average' or 'avg' are OK 
#	'median' or 'med' or 'midpt' are OK
#	'mode' or 'mod'              are OK
#	Rev 29nov2003   SEP
#
#       Rev 22sep2004   GF
#       This version for WIRC, using w_store
#
#	Rev 28feb2006 GF Clean version.

begin
	real fac, fr_mean, fr_med, fr_mod

	w_store ( pic_in )

	if ( ntype == 'mean' || ntype == 'average' || ntype == 'avg' ) {
       	  keypar (pic_in, "FRMEAN", silent+)
       	  fac = real(keypar.value)
	} 

	if ( ntype == 'median' || ntype == 'med' || ntype == 'midpt' ) {
       	  keypar (pic_in, "FRMEDIAN", silent+)
       	  fac = real(keypar.value)
	} 

	if ( ntype == 'mode' || ntype == 'mod' ) {
       	  keypar (pic_in, "FRMODE", silent+)
       	  fac = real(keypar.value)
	}
 
	wclear ( "dummy" )
	imarith ( pic_in, "/", fac, "dummy", title="", divzero=1., pixtype="", calctyp="", verbose=no, noact=no )

	if ( pic_in == pic_out ) wclear ( pic_in )  
        imrename ( "dummy", pic_out, verbose- )
	w_store ( pic_out )

end
