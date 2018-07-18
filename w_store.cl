procedure w_store ( framein )

string framein
struct *list1

#	Store the mean, median, and mode of a frame in its header
#	Assumes a 1024 frame; omits some pixel border.
#
#	It does not matter if 'framein' has a '.fits' extension on it.
#
#	Rev  29nov2003     SEP	
#	Rev  08mar2004     SEP:
#	Because PANIC frames have bad-looking edges, restrict the 
#	section for imstat to be well within - leave a 40-pixel 
#	border.
#       Rev 16sep2004      GF:
#       The section was modified for the case of WIRC to
#	 [20:990,20:990]

begin

	real fr_mean, fr_med, fr_mod, fr_stddev

	imstat (framein//"[20:990,20:990]", fields="mean,midpt,mode,stddev", lower=-500., upper=30000., nclip=5, lsigma=3., usigma=3., binwidth=0.1, format=no, cache=no) | scan (fr_mean, fr_med, fr_mod, fr_stddev)
 
        hedit (framein,"FRMEAN", fr_mean,update+,add+,verify-,show-)
        hedit (framein,"FRMEDIAN", fr_med,update+,add+,verify-,show-)
        hedit (framein,"FRMODE", fr_mod,update+,add+,verify-,show-)
	hedit (framein,"FRSTDDEV", fr_stddev,update+,add+,verify-,show-)

end
