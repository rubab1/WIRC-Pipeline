procedure w_std ( p1, p2, chip )

int p1 
int p2
int chip

#	The photometric aperture size is 5 arseconds radius.
#	The stack is the output of w_stk2: stk_std_<p1>_<p2>_c<chip>
#
# GF: This version just changes the stacked image name. It does not call
# the photometry scripts, which will be done using the snphot package.

begin
	string isx_frame, root_name, fname
	string onumber1, onumber2
	string std

	padindex(p1) ; onumber1 = padindex.output
	padindex(p2) ; onumber2 = padindex.output

	std = "stk_std_"//p1//"_"//p2//"_c"//chip
	wclear(std)
	imrename ( "stk_"//onumber1//"_c"//chip, std, verbose+ )

#	Call photometry program. (NOT AVAILABLE)

#	w_tst ( p1, p2, chip )

end




