procedure w_bptest ( inimage, refval, nsig)

string inimage	{prompt = "Input prefix"}
string refval   {enum="median|mode|mean", prompt = "Reference value"}
real   nsig     {4., prompt = "Number of sigmas for rejection"}

begin

string image
real stdev, zlow, zhig, value

image = inimage
w_store ( image )
if (refval == "median") {
  keypar (image, "FRMEDIAN", silent+)
} else if (refval == "mode") {
  keypar (image, "FRMODE", silent+)
} else {
  keypar (image, "FRMEAN", silent+)
}  
value = real(keypar.value)
keypar (image, "FRSTDDEV", silent+)
stdev = real(keypar.value)
zlow = value - nsig * stdev
zhig = value + nsig * stdev
printf ("\n")
printf ("Image: %s\n",image)
printf ("%s = %8.3f; stddev = %8.3f\n",refval,value,stdev)
printf ("Lower limit = %8.3f; Upper limit = %8.3f\n",zlow,zhig)
wclear("dummy1")
median (image, "dummy1", 31, 31, zloreject=zlow, zhireject=zhig, boundary="nearest", constant=0., verbose=no)
wclear("dummy2")
imarith (image, "-", "dummy1", "dummy2", title=" ", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
w_store ( "dummy2" )
if (refval == "median") {
  keypar ("dummy2", "FRMEDIAN", silent+)
} else if (refval == "mode") {
  keypar ("dummy2", "FRMODE", silent+)
} else {
  keypar ("dummy2", "FRMEAN", silent+)
}  
value = real(keypar.value)
keypar ("dummy2", "FRSTDDEV", silent+)
stdev = real(keypar.value)
zlow = value - nsig * stdev
zhig = value + nsig * stdev
printf ("\n")
printf ("Image: %s - median\n",image)
printf ("%s = %8.3f; stddev = %8.3f\n",refval,value,stdev)
printf ("Lower limit = %8.3f; Upper limit = %8.3f\n",zlow,zhig)
wclear("dummy3")
imcalc ("dummy2", "dummy3", "if im1 .lt. "//zlow//" .or. im1 .gt. "//zhig//" then 1. else 0.", pixtype="old", nullval=0., verbose=no)
wclear ("bpmask_test")
imcopy("dummy3","bpmask_test",ver-)

#wclear("dummy1")
#wclear("dummy2")
#wclear("dummy3")

end
