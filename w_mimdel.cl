procedure w_mimdel ( pre, p1, p2, chip )

string pre
int chip, p1, p2

#	/home/persson/iraf/wirc_scripts/w_mimdel.cl
#	Deletes frames p1 through p2, for all looped
#	frames, skipping missing ones.
#	Rev:  29nov2003    SEP  panic
#	Rev:  22mar2004    SEP  wirc/fourstar
#	if 'chip' = 0 or 5 all 4 are to be deleted.

begin
	int i, k

	string pic_list, onumber1

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

	w_pre_list ( pre, p1, p2, k )

	pic_list = pre//"_c"//k//"_list" 
  
        if ( access ( pic_list )) {
#	  print ( "" ) ; page ( pic_list ) ; print ( "" )
	  imdelete ( "@"//pic_list )
        }
	  }
	}
	wclear ( pic_list )
end
