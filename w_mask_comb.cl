procedure w_mask_comb ( in_name, chip )

string in_name
int chip
struct *list1

# Combines N badpixel masks from flats of different filters into one 
# bp_mask.
# Every bad pixel present in N-1 masks is considered to be bad.

begin

	string maskin, date, default_path, listin
	int nmask
	real low

	wclear("copy.sh")
	listin = in_name
	nmask = 0
	wclear ("mask"); wclear ("masko")

	list1 = ""; list1 = listin
	while (fscan (list1, maskin) != EOF ) {

	  if (!access ("masko.fits")) {
	     imcopy ( maskin, "masko", ver-)
	     keypar( maskin, "NIGHT",silent+)
	     date = str(keypar.value)
	  }  else {
	     imarith ("masko", "+", maskin, "masko", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
	  }

	  nmask = nmask + 1
	}
#	imreplace ("masko", value=1, imagina=0., lower=0.9, upper=INDEF, radius=0.)
#
# Keep only those bad pixels detected in N-1 filters (if N>1).

	if (nmask == 2) {
	   low = 1.9
	   imreplace ("masko", value=0, imagina=0., lower=INDEF, upper=low, radius=0.)
	   imreplace ("masko", value=1, imagina=0., lower=low, upper=INDEF, radius=0.)
	}
	if (nmask > 2) {
	   low = real (nmask) - 1.1
	   imreplace ("masko", value=0, imagina=0., lower=INDEF, upper=low, radius=0.)
	   imreplace ("masko", value=1, imagina=0., lower=low, upper=INDEF, radius=0.)
	}
	wclear ( "mask_c"//chip//"_"//date//".pl" )
	imcopy ( "masko", "mask_c"//chip//"_"//date//".pl", ver-)

	#default_path = "wfiles$bp_masks/"

	#wclear ( default_path//"mask_c"//chip//"_"//date//".pl")
	#copy ( "mask_c"//chip//"_"//date//".pl", default_path, ver+ )
	show ("wfiles") | scan (default_path)
	print("cp mask_c"//chip//"_"//date//".pl "//default_path//"bp_masks/", >> "copy.sh")
	print("chmod 664 "//default_path//"bp_masks/mask_c"//chip//"_"//date//".pl", >> "copy.sh")
#	print("chgrp rwxirphot "//default_path//"bp_masks/mask_c"//chip//"_"//date//".pl", >> "copy.sh")
	! source copy.sh
end

