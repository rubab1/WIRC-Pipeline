procedure w_linearize2 ( camera, n1, n2 )

string camera 
int n1
int n2

struct *list1

#
# This is a new version of the linearization script, which calls
# a SPP program written by Mark Phillips.
# 12oct2004 GF.

begin 
	string  pre, cam, plin, pic, pout
	int k

#	Get list of all pictures to be linearized
#	Output is "raw_pic_list"

	if ( camera == 'w' || camera == 'W' || camera == 'wirc' || camera == 'WIRC' ) {
	  pre = "irx"
	  plin = "izx"
	  cam = "w"
	}
	if ( camera == 'f' || camera == 'F' || camera == 'fourstar' || camera == 'FOURSTAR' ) {
	  pre = "irf"
	  plin = "izf"
	  cam = "f"
	}

# Go through chips and input images:
	for ( k = 1; k <= 4 ; k += 1 ) {
	  wclear ( "in_list" )
	  wclear ( "out_list" )
	  w_raw_list ( pre, n1, n2, k )
	  if ( access ( "raw_pic_list" )) {
	    list1 = "" ; list1 = "raw_pic_list"
	    while ( fscan ( list1, pic ) != EOF ) {
	      pout = plin//substr(pic,4,21)
	      wclear ( pout )
# Linearize
	      print ( "Linearizing:  ", pic, "  -->  ",pout )
	      ir_linearize ( pic, pout, cam )
	    }
	  }
	}

# Clean up:
	wclear ( "raw_pic_list" )
	wclear ( "in_list" ); wclear ( "out_list" )

end
