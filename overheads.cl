procedure overheads ( infile, pre )

string infile {prompt = "File with frame pairs"}
string pre    {prompt = "Frame prefix"}
struct *list1

# This script is used to estimate overheads of WIRC observations.
# 

begin

	string sp1, sp2, sp3, sp4, outfile, fname
	int    p1, p2, p3, p4, chip, nloops
	real   sidt1, sidt2, sidt3, sidt4, expt
	real   totex, sptime, gapt, ovhead, ovhead1, totex1

# Initialize variables (chip default to 2)
	chip = 2
	gapt = -1000.
	totex = -1000.
	sptime = -1000.
 	ovhead = -1000.

	outfile = "overheads.out"
	wclear (outfile)
	print ( "# Seq.","  ","Tot.Expt"," ","Spent","    ","Gap","   ","Ohead","  ","Ohead-1", > outfile)

	if ( access ( infile ))	{

	list1 = "" ; list1 = infile
	while ( fscan ( list1, p1, p2, p3, p4 ) != EOF ) {

	padindex(p1) ; sp1 = padindex.output
	padindex(p2) ; sp2 = padindex.output
	padindex(p3) ; sp3 = padindex.output
	padindex(p4) ; sp4 = padindex.output

	fname = pre//"_"//sp1//"_c"//chip//".fits"
	if ( access (fname)) {
	   keypar(fname,"ST",silent+)
	   sidt1 = real(keypar.value)
	   keypar(fname,"EXPTIME",silent+)
	   expt = real(keypar.value)
	   keypar(fname,"NLOOPS",silent+)
	   nloops = int(keypar.value)
	} else { error ( 1, "Frame 1 not found." ) }

	fname = pre//"_"//sp4//"_c"//chip//".fits"
	if ( access (fname)) {
	   keypar(fname,"ST",silent+)
	   sidt4 = real(keypar.value)

	   totex = expt * (p4 - p1 + 1) * nloops

	   sptime = sidt4 - sidt1 + expt * nloops

	   if ( sptime < 0. ) sptime = sptime + 86400

	   ovhead = sptime - totex

	} else { error ( 1, "Frame 4 not found." ) }

	fname = pre//"_"//sp2//"_c"//chip//".fits"
	if ( access (fname)) {
	   keypar(fname,"ST",silent+)
	   sidt2 = real(keypar.value)
	} else { error ( 1, "Frame 2 not found." ) }

	fname = pre//"_"//sp3//"_c"//chip//".fits"
	if ( access (fname)) {
	   keypar(fname,"ST",silent+)
	   sidt3 = real(keypar.value)

	   gapt = sidt3 - sidt2 - expt * nloops

	   if ( gapt < 0. ) gapt = gapt + 86400

	   totex1 = expt * (p2 - p1 + 1) * nloops
	   ovhead1 = sidt2 - sidt1 + expt * nloops
	   if ( ovhead1 < 0. ) ovhead1 = ovhead1 + 86400
	   ovhead1 = (ovhead1 - totex1) /  (p2 - p1 + 1 ) 


	} else { error ( 1, "Frame 3 not found." ) }

	print ( p1//"-"//p4,"     ",totex,"   ",sptime,"  ",gapt,"  ",ovhead,"  ", ovhead1, >> outfile)

    } # close main while loop

} # close if access 
end
