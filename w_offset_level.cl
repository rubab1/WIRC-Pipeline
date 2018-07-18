procedure w_offset_level ( framein, frstat )

string framein, frstat

#	Subtracts off the mean, median, or mode of a frame.
#	Recalculates the stats and stores in header.

begin
	real level
	string stsect

	stsect = "[41:984,41:984]"

	w_store ( framein )

	if ( frstat == "median" || frstat== "midpt" ) 	{
		keypar ( framein, "FRMEDIAN", silent+ )
		level = real(keypar.value)
												}

	if ( frstat == "average" || frstat == "mean" ) 	{
		keypar ( framein, "FRMEAN", silent+ )
		level = real(keypar.value)
												}

	if ( frstat == "mode" ) 	{
		keypar ( framein, "FRMODE", silent+ )
		level = real(keypar.value)
							}
	wclear ( "dummy" )
	imarith (framein, "-", level, "dummy", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

	wclear ( framein )
	imrename ( "dummy", framein )
	w_store ( framein )

end
