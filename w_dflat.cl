procedure w_dflat ( pre, p1, p2 )

string pre	{prompt = "Image prefix"}
int    p1 	{prompt = "Lamp-on dome flat frame"}
int    p2 	{prompt = "Lamp-off dome flat frame"}

# 	'pre' should be "nwd" for WIRC, and "nfd" for FourStar.
#
#	The filter is taken out of each header and checked for 
#	consistency.

begin

string stsection, onumber1, onumber2, filter_p1, filter_p2, junk
string date, default_path, pre2, icd_1, icd_2
real frmed, median, stdev, zlow, zhig, nsig
int k

nsig = 4.

w_get_date ( "icx", p1 )
date = w_get_date.output

# Get filter and date out of headers

wclear("copy.sh")
for ( k = 1 ; k <= 4 ; k += 1 ) {
  padindex(p1) ; onumber1 = padindex.output
  padindex(p2) ; onumber2 = padindex.output
  icd_1 = "icd_"//onumber1//"_c"//k//".fits"
  icd_2 = "icd_"//onumber2//"_c"//k//".fits"
  if ( access ( icd_1) && access ( icd_2)) {
    keypar(icd_1, "FILTER",silent+)
    filter_p1 = str(keypar.value)
    keypar(icd_2, "FILTER",silent+)
    filter_p2 = str(keypar.value)

# Check for filter consistency

    if ( filter_p1 == filter_p2) {
      wclear ("flat")
      imarith (icd_1, "-", icd_2, "flat", title=" ", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
      wclear ("hot1")
      imcopy ( icd_2, "hot1", ver- )
#Make sure it is a positive image
      w_store ( "flat" )
      keypar  ( "flat", "FRMEDIAN", silent+ )
      frmed = real(keypar.value)
      if ( frmed <= 0. ) {
        imarith ( "flat", "*", -1., "flat", title=" ", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
        junk = onumber1
        onumber1 = onumber2
        onumber2 = junk
        wclear ("hot1")
        imcopy ( icd_1, "hot1", ver- )
      }

# Normalize to the mode of the lamp-on minus lamp-off difference image
# Note that the output image is positive.
# Fix edges, which also stores image statistics.

      w_norm ( "flat", "flat", "median" )
      wclear ( "mask" )
      imcopy ( "flat", "mask", verbose- )
# Get rid of nonsensical values. THIS IS CRITICAL: A PIXEL CAN
# HAVE A QE NO LESS THAN 60% AND NO MORE THAN 140% RELATIVE TO THE MEDIAN OF ALL.
      imreplace ("flat", 1, imaginary=0., lower=INDEF, upper=0.6, radius=0.)
      imreplace ("flat", 1, imaginary=0., lower=1.4, upper=INDEF, radius=0.)
      w_store ( "flat" )
      wclear ( "dummy" )
      wclear ( "dummy2" )
      wclear ( "dummy3" )
      keypar ("flat", "FRMEDIAN", silent+)
      median = real(keypar.value)
      keypar ("flat", "FRSTDDEV", silent+)
      stdev = real(keypar.value)
      zlow = median - nsig * stdev
      zhig = median + nsig * stdev
      median ("flat", "dummy", 31, 31, zloreject=zlow, zhireject=zhig, boundary="nearest", constant=0., verbose=no)
      imarith ("flat", "-", "dummy", "dummy2", title=" ", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
      w_store ( "dummy2" )
      keypar ("dummy2", "FRMEDIAN", silent+)
      median = real(keypar.value)
      keypar ("dummy2", "FRSTDDEV", silent+)
      stdev = real(keypar.value)
      zlow = median - nsig * stdev
      zhig = median + nsig * stdev
      imcalc ("flat,dummy2", "dummy3", "if im2 .lt. "//zlow//" .or. im2 .gt. "//zhig//" then 1. else im1", pixtype="old", nullval=0., verbose=no)
      wclear ("flat")
      imrename ("dummy3", "flat", ver-)
      wclear ( pre//"flat"//filter_p1//"c"//k//"_"//date )
      imcopy ( "flat", pre//"flat"//filter_p1//"c"//k//"_"//date, ver- )
#      default_path = "wfiles$flats/"
      show ("wfiles") | scan (default_path) 
 #    wclear ( default_path//"flats/"//pre//"flat"//filter_p1//"c"//k//"_"//date//".fits" )
      printf ("\n")
      print("cp "//pre//"flat"//filter_p1//"c"//k//"_"//date//".fits "//default_path//"flats/", >> "copy.sh")
      print("chmod 664 "//default_path//"flats/"//pre//"flat"//filter_p1//"c"//k//"_"//date//".fits", >> "copy.sh")
#      print("chgrp rwxirphot "//default_path//"flats/"//pre//"flat"//filter_p1//"c"//k//"_"//date//".fits", >> "copy.sh") 
#     copy ( pre//"flat"//filter_p1//"c"//k//"_"//date//".fits", default_path, ver+ )

# Now create badpixel mask using the same definitions of 'dead' and 'hot'
# pixels.

      imarith ("mask", "/", "flat", "mask", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
      wclear ( "mask2" )
      imcopy ( "mask", "mask2", ver- )
      imreplace ("mask2", 0, imaginary=0., lower=1, upper=1, radius=0.)
      imarith ("mask", "/", "mask2", "mask", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
#imcopy ("mask", "mask_"//"c"//k//".pl", verb-)

# Add hot and dead pixels detected just in the lamp-off flats
      w_store ( "hot1" )
      keypar ("hot1", "FRMEDIAN", silent+)
      median = real(keypar.value)
      keypar ("hot1", "FRSTDDEV", silent+)
      stdev = real(keypar.value)
      zlow = median - nsig * stdev
      zhig = median + nsig * stdev
      printf ("\n")
      printf ("Lamp-off flat:\n")
      printf ("median = %8.3f; stddev = %8.3f\n",median,stdev)
      printf ("Lower limit = %8.3f; Upper limit = %8.3f\n",zlow,zhig)
      wclear("dummy")
      median ("hot1", "dummy", 31, 31, zloreject=zlow, zhireject=zhig, boundary="nearest", constant=0., verbose=no)
      wclear("dummy2")
      imarith ("hot1", "-", "dummy", "dummy2", title=" ", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
      w_store ( "dummy2" )
      keypar ("dummy2", "FRMEDIAN", silent+)
      median = real(keypar.value)
      keypar ("dummy2", "FRSTDDEV", silent+)
      stdev = real(keypar.value)
      zlow = median - nsig * stdev
      zhig = median + nsig * stdev
      printf ("\n")
      printf ("Lamp-off flat - median:\n")
      printf ("median = %8.3f; stddev = %8.3f\n",median,stdev)
      printf ("Lower limit = %8.3f; Upper limit = %8.3f\n",zlow,zhig)
      wclear("dummy3")
      imcalc ("dummy2", "dummy3", "if im1 .lt. "//zlow//" .or. im1 .gt. "//zhig//" then 1. else 0.", pixtype="old", nullval=0., verbose=no)
      wclear ( "mask2" )
      imcopy("dummy3","mask2",ver-)
#imcopy ("mask2", "mask2_"//"c"//k//".pl", verb-)

      wclear("dummy")
      imarith ("mask", "+", "mask2", "mask", title=" ", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
      imreplace ("mask", value=1., lower=1.01, upper=INDEF, radius=0., imagina=0. )

# Mask the borders:
      imreplace ( "mask[1:1024,1003:1024]", value=1., lower=INDEF, upper=INDEF, radius=0., imagina=0. )
      imreplace ( "mask[1:1024,1:15]", value=1., lower=INDEF, upper=INDEF, radius=0., imagina=0. )
      imreplace ( "mask[1:15,1:1024]", value=1., lower=INDEF, upper=INDEF, radius=0., imagina=0. )
      imreplace ( "mask[1000:1024,1:1024]", value=1., lower=INDEF, upper=INDEF, radius=0., imagina=0. )

      wclear ( "mask_"//filter_p1//"_c"//k//"_"//date//".pl" )
      imcopy ( "mask", "mask_"//filter_p1//"_c"//k//"_"//date//".pl", ver- )

      print ("mask_"//filter_p1//"_c"//k//"_"//date//".pl", >> "mask_list_c"//k )

      wclear ( "flat" )
      wclear ( "mask" )
      wclear ( "hot1" )
      wclear ( "mask2" )
      wclear ( "dummy" )
      wclear ( "dummy2" )
      wclear ( "dummy3" )

    } else {
      print ( "" )
      print ( "  >> SORRY: Filters are not consistent " )
      print ( "" )
    }
    
  }
}
! source copy.sh
end
