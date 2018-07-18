procedure w_loop_expand ( pic, chip )

string pic
int chip
struct *list1

#	This creates a list of frames within a loop. 
#	In this version the argument 'pic' is the first frame
#	of the loop. It can be, for example, irx_00055, irx_00055_c1,
#	irx_00055_c1_001, or irx_00055_c1_001.fits.
#
#	Change loopmax parameter if necesssary
#
#	Rev:  17dec2003   SEP
#	Rev:  31mar2004   SEP

begin
	int i, k, m, loopmax
	string pic_root, pic_list, pic_n

	loopmax = 30

#	'pic' can have a .fits extension or not, or can 
#	have a loop extension, or not. 

	for ( k = 1 ; k <= 4 ; k += 1 )	{
	  if ( chip == k || chip == 0 || chip == 5 )  {
	    pic_root = substr(pic,1,9)//"_c"//k
	    pic_list = pic_root//"_list"  ;  wclear ( pic_list )
	    for ( m = 1 ; m <= loopmax ; m += 1 ) {
	      padindex(m) ; pic_n = substr(padindex.output,3,5)
	      if ( access ( pic_root//"_"//pic_n//".fits" )) {
	        print ( pic_root//"_"//pic_n//".fits", >> pic_list )  
	      } else {}
	    }
	  } else {}
	}

end
