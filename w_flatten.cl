procedure w_flatten ( n1, n2 )

int n1
int n2
struct *list1

#  	Flattens 'icd' frames to produce 'idf' frames.
#
#	Assumes that 'icd' linearized, loop-combined, and 
#	dark-subtracted frames exist. 
#
#	'n1' and 'n2' are the starting and ending 
#	frame numbers of a set. Frames n1 and n2 must exist,
#  	but those in between need not. 
#
#	It is assumed that frames n1 and n2 are on the same date. 
#
#	It is assumed that 'chk_headers' and 'fix_headers' have 
#	been run and that therefore all obstypes are correct. 
#
#	The existence of frames within a set is not assumed (in
#	case it has been necessary to delete some) but is worked
#	around. 
#	
#	Only 'astro' and 'standard' obstype frames are processed.
#	
#	Flats must exist. The nomenclature is:
#	
#	nwtflatJcc2_28nov2003.fits (normalized/wirc/twi/flat/filter/chip/_date)
#	    
#	   (if it exists). If not, the dome rather than twi flat is used)
#	   If this does not exist, then a canonical flat is taken from 
#	   the flat storage directory. 
#
#	If a flattened frame exists, it is written over.
#
#  Rev 28sep2004 GF after SEP: Now add the two mask files 
#  mask_ck_date.pl and mask_NNNNN.pl and store in header. 

begin
	string filter, obstyp, date, flat_path, flat, dflat, tflat, sflat
	string icd_frame, idf_frame, flat_now, onumber, msk
	real fr, frmedian
	int k

	for ( k = 1 ; k <= 4 ; k += 1 )	{
	  for ( i = n1 ; i <= n2; i += 1 ) {

#  Get filter, night, and obstyp out of header of each frame in 
#  the n1,n2 sequence

	    padindex(i) ; onumber = padindex.output 
	    icd_frame = "icd_"//onumber//"_c"//k//".fits"

	    if ( access ( icd_frame )) {

	      keypar(icd_frame, "FILTER",silent+)
	      filter = str(keypar.value)
	      keypar(icd_frame, "NIGHT",silent+)
	      date = str(keypar.value)
	      keypar(icd_frame, "OBSTYPE",silent+)
	      obstyp = str(keypar.value)

# All but dark frames are flattened. The flattened dome flats 
# are best for computing badpixel masks. 

	      if ( obstyp == 'astro' || obstyp == 'standard' ) {
	        idf_frame = "idf_"//onumber//"_c"//k
	        wclear ( idf_frame )

# Select flat in priority order: twi, dome, stored

	        tflat = "nwtflat"//filter//"c"//k//"_"//date//".fits"
	        dflat = "nwdflat"//filter//"c"//k//"_"//date//".fits"

	        flat_path = "wfiles$flats/"
	        sflat = flat_path//"sptflat"//filter//"c"//k//".fits"

# Compute, store, and retrieve the icd frame median to use for 
# the divzero parameter.

	        w_store ( icd_frame )
	        keypar(icd_frame, "FRMEDIAN",silent+)
	        frmedian = real(keypar.value)
	        if ( access ( tflat )) flat = tflat
	        if ( access ( dflat )) flat = dflat
	        if ( !access ( dflat ) && !access ( tflat )) flat = sflat

	        imarith ( icd_frame, "/", flat, idf_frame, title="", divzero=frmedian, hparams="", pixtype="real", calctype="real", verbose=yes, noact=no)
 
	        hedit (idf_frame, "FLAT", flat, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
	        hedit (idf_frame, "ZMAG", 26.00, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
 
# No pixel value can be outside original range of +- 32768/flat(x,y).
# Consistent with the allowed range in the flat-making routines, we
# allow flat to go as low as +0.6. There is no way for a valid 
# pixel value to be < -500 in an icd frame, so set lower limit to -1000.
# There could be a valid icd pixel value near 30000 on top of a valid
# flat(x,y) ~ 0.6, so set upper limit to 50000.
# Any outside this range have been created by spurious values in the
# flat.
	
	        imreplace (idf_frame, frmedian, imaginary=0., lower=INDEF, upper=-1000, radius=0.)
	        imreplace (idf_frame, frmedian, imaginary=0., lower=50000, upper=INDEF, radius=0.)
 
# Store mask names in header

	        msk = "mcx_"//onumber//"_c"//k//".pl"
	        if (access ( msk )) {

	          imarith (msk, "+", "mask_c"//k//"_"//date//".pl", msk, title="", divzero=0., hparams="", pixtype="int", calctype="int", verbose=no, noact=no)
 
	          imreplace (msk, 1, imaginary=0., lower=1, upper=INDEF, radius=0.)
	        } else {
	          imcopy ( "mask_c"//k//"_"//date//".pl", msk, verbose- )
	        }
	        parkey ( msk, idf_frame, "BPM", add+)

# Fix frame edges, which stores the median value of the frame in its header.

	        w_edges ( idf_frame )
	      }
	    }
	  }
	}
end















