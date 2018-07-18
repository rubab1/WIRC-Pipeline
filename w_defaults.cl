procedure w_defaults ( n1 )

int n1
struct *list1

#	Specifies where to get default flats, darks, and bp_masks.
#	Formats:
#
#	  nwtflatJcc2_23Feb2004     /home/persson/iraf/wirc_files/flats/
#	  nwdflatHcc1_23Feb2004     /home/persson/iraf/wirc_files/flats/
#	  dk_020_c1_23Feb2004       /home/persson/iraf/wirc_files/darks/
#	  dk_025_c3_24Feb2004       /home/persson/iraf/wirc_files/darks/
#	  maskc3_08Jul2004          /home/persson/iraf/wirc_files/bp_masks/

begin
	string date, pic, frame, ftype, path_to_it, onumber

#	Get the date out of the header of pic n1, test for chip
#	Will work for irx or icx frames.

	padindex(n1) ; onumber = padindex.output

	frame = "irx_"//onumber//"_c1"//"_001.fits"
	if ( !access ( frame )) frame = "irx_"//onumber//"_c2"//"_001.fits"
	if ( !access ( frame )) frame = "irx_"//onumber//"_c3"//"_001.fits"
	if ( !access ( frame )) frame = "irx_"//onumber//"_c4"//"_001.fits"

	if ( !access ( frame )) frame = "icx_"//onumber//"_c1"//".fits"
	if ( !access ( frame )) frame = "icx_"//onumber//"_c2"//".fits"
	if ( !access ( frame )) frame = "icx_"//onumber//"_c3"//".fits"
	if ( !access ( frame )) frame = "icx_"//onumber//"_c4"//".fits"

	keypar(frame ,"NIGHT",silent+)
	date=str(keypar.value)

	if ( access ( "defaults" )) { 
	  list1 = "" ; list1 = "defaults"
	  while ( fscan ( list1, ftype, path_to_it ) != EOF ) {

#	Flats

	    if (substr(ftype,1,2) == "nw") {

	      wclear ( substr(ftype,1,12)//date )
	      imcopy ( path_to_it//ftype, substr(ftype,1,12)//date, verbose- )
	    }
#	Darks

	    if (substr(ftype,1,2) == "dk") {
	      wclear ( substr(ftype,1,10)//date )
	      imcopy ( path_to_it//ftype, substr(ftype,1,10)//date, verbose- )
	    }
#	Badpixel masks

	    if (substr(ftype,1,2) == "ma") {
	      wclear ( substr(ftype,1,8)//date )
	      imcopy ( path_to_it//ftype, substr(ftype,1,8)//date//".pl", verbose- )
	    }
	  }
	} else {
	  wsorry ("defaults")
	}	
end
	

