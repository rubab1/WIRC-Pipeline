procedure w_stk2 ( p1, p2, chip )

int p1
int p2
int chip
struct *list1

#  Second-pass stacking for SN data.
#  p1,p2 in this routine can be p1,p2 SNe or std pairs.

begin
	int k, j, jmax
	real a, airmass, meansky
  	real xoff2, yoff2
        real xfid_off2, yfid_off2
	real xfid, xshift, yfid, yshift
	string idf_frame, isx_frame, onumber, outfile, filelist, fname

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

	w_pre_list ( "isx", p1, p2, k )	
	filelist = "isx_c"//k//"_list"

# If 'is2' frames exist, use those; means this is final stack for SNe.

	padindex(p1) ; onumber = padindex.output
	if ( access ( "is2_"//onumber//"_c"//k//".fits" )) {
	  w_pre_list ( "is2", p1, p2, k )	
	  filelist = "is2_c"//k//"_list"
	}
        wclear("offs.dat") ; wclear ("off.dat")
 
# Compute average airmass and store in header of stack
# Get xoff2,yoff2 out of headers

# Compute average sky level.
	j = 0 ; airmass = 0.; meansky = 0.
        list1 = ""; list1 = filelist
        while (fscan (list1, fname) != EOF) {

# Do not fix 60Hz noise:
#          w_fix60 ( fname, k )

	  keypar(fname,"AIRMASS",silent+)
	  a = real(keypar.value)
	  airmass += a
	  keypar(fname,"SKYLEV",silent+)
	  a = real(keypar.value)
	  meansky += a
	  j += 1
	  jmax = j
          keypar (fname, "XOFF2",silent+)
          xoff2 = (real(keypar.value))
          keypar (fname, "YOFF2")
          yoff2 = (real(keypar.value))
          print (xoff2, "  ", yoff2 , >> "off.dat")
	}
	airmass = airmass/jmax
	meansky = meansky/jmax 
	print ( "# Absolute ", > "offs.dat" )
	!cat off.dat >> offs.dat
	outfile = "stk_"//onumber//"_c"//k
	wclear (outfile)

# Combine images
 
	imcombine ("@"//filelist, outfile, headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="", sigmas="", logfile="STDOUT", combine="average", reject="none", project=no, outtype="real", outlimits="", offsets="offs.dat", masktype="badvalue", maskvalue=1., blank=0., scale="none", zero="none", weight="none", statsec="", expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)

# Compute and inspect XY location of original reference star in stack

        keypar (outfile, "XFID", silent+)
        xfid = real(keypar.value)
        keypar (outfile, "YFID", silent+)
        yfid = real(keypar.value)
        keypar (outfile, "XOFF2", silent+)
        xshift = real(keypar.value)
        keypar (outfile, "YOFF2", silent+)
        yshift = real(keypar.value)

        xfid_off2 = xfid + xshift
	yfid_off2 = yfid + yshift
	wclear ( "xy.in" )
	print (xfid_off2," ",yfid_off2,>>"xy.in")
	wclear ( "xy.out" ) ; wclear ( "xy.2" )

# Display combined image

	display (outfile, 1, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="", ocolors="red", erase=yes, border_erase=yes, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1, ymag=1, order=0, z1=0., z2=100., ztrans="linear", lutfile="")
 
	imexamine (outfile, 1, logfile="xy.out", keeplog=yes, defkey="a", autoredraw=yes, allframes=yes, nframes=0, ncstat=5, nlstat=5, graphcur="", imagecur="xy.in", wcs="logical", xformat="", yformat="", graphics="stdgraph", display="display(image='$1',frame=$2)", use_display=yes)

	!tail -1 xy.out | awk '{ print $3, $4 }' > xy.2

	tvmark (1, "xy.2", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii="25", lengths="0", font="raster", color=205, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)
 
	type ("xy.2") | scan (x,y)

	hedit ( outfile, "XSTAR", x, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
	hedit ( outfile, "YSTAR", y, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
	hedit ( outfile, "AIRSTK", airmass, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
	hedit ( outfile, "MEANSKY", meansky, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)

	}
	  }
# Clean up
	wclear ( "xy.out" ) ; wclear ( "xy.2" ); wclear ( "xy.in" )
        wclear("offs.dat") ; wclear ("off.dat")
	wclear(filelist)

end
