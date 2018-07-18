procedure w_avecomb ( filelist, outfile)

# This script should be equivalent of p_avecomb for PANIC/RetroCAM

file	  filelist	{prompt="List of input images."}
file	  outfile	{prompt="Name of output combined images."}

struct	  *list1

begin

# Declarations

	string expmap, fname
	int  j, jmax
	int  imoffx, imoffy
	real a, airmass, meansky, scale
	real moffx, moffy
  	real xoff2, yoff2
        real xfid_off2, yfid_off2, xst, yst
	real xfid, xshift, yfid, yshift, cbox

	scale = 0.196	
        cbox  = 5.

	centerpars.calgori="centroid"
	centerpars.cbox=cbox
	centerpars.cthresh=0
	centerpars.minsnra=1
	centerpars.cmaxite=10
	centerpars.maxshif=1
	centerpars.clean=no
	centerpars.rclean=1
	centerpars.rclip=2
	centerpars.kclean=3
	centerpars.mkcente=no
	datapars.scale=scale
	datapars.fwhmpsf=2.5
	datapars.emissio=yes
	datapars.sigma=INDEF
	datapars.datamin=INDEF
	datapars.datamax=INDEF
	datapars.noise="poisson"
	datapars.ccdread=""
	datapars.gain=""
	datapars.readnoi=0
	datapars.epadu=1
	datapars.exposur=""
	datapars.airmass=""
	datapars.filter=""
	datapars.obstime=""
	datapars.itime=1

  	wclear ("off.dat")

	j = 0
	airmass = 0.; meansky = 0.
	moffx = 0.
	moffy = 0.

	print ( "# Absolute ", > "off.dat" )
	list1 = ""; list1=filelist
	while (fscan (list1,fname) != EOF) {
         
          keypar (fname, "XOFF2",silent+)
          xoff2 = (real(keypar.value))
          keypar (fname, "YOFF2")
          yoff2 = (real(keypar.value))
          print (xoff2, "  ", yoff2 , >> "off.dat")

	  keypar(fname,"AIRMASS",silent+)
	  a = real(keypar.value)
	  airmass += a

	  keypar(fname,"SKYLEV",silent+)
	  a = real(keypar.value)
	  meansky += a
	  j += 1
	  jmax = j
	  if (xoff2 > moffx) moffx = xoff2
	  if (yoff2 > moffy) moffy = yoff2

  	}

	meansky = meansky/jmax
	airmass = airmass/jmax
	imoffx = int (moffx) + 14
	imoffy = int (moffy) + 14

# Combine images

   	expmap = "exp_"//substr(outfile,5,strlen(outfile))
   	wclear (expmap//".pl")
  	wclear (outfile)

	imcombine ("@"//filelist, outfile, headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks=expmap//".pl", sigmas="", logfile="STDOUT", combine="average", reject="none", project=no, outtype="real", outlimits="", offsets="off.dat", masktype="badvalue", maskvalue=1., blank=0., scale="none", zero="none", weight="none", statsec="", expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)

#	Compute and inspect XY location of original reference star in stack

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

	display (outfile, 1, bpmask="", bpdisplay="none", bpcolors="red", overlay="", ocolors="green", erase=yes, border_erase=yes, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=INDEF, z2=INDEF, ztrans="linear", lutfile="")

	center (outfile, coords="xy.in", output="xy.out", plotfile="", interactive=no, radplots=no, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=no, verbose=yes, graphics=")_.graphics", display=")_.display")

#	imexamine (outfile, 1, output="", ncoutput=101, nloutput=101, logfile="xy.out", keeplog=yes, defkey="a", autoredraw=yes, allframes=yes, nframes=0, ncstat=10, nlstat=10, graphcur="", imagecur="xy.in", wcs="logical", xformat="", yformat="", graphics="stdgraph", display="display(image='$1',frame=$2)", use_display=no)

	   !egrep -v '#' xy.out | egrep -v 'stk' - | awk '{print $1, $2}' - > xy.2
#	!tail -1 xy.out | awk '{ print $3, $4 }' > xy.2

	tvmark (1, "xy.2", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii="25", lengths="0", font="raster", color=205, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)

	type ("xy.2") | scan (xst, yst)

	parkey ( xst, outfile, "XSTAR", add+ )
	parkey ( yst, outfile, "YSTAR", add+ )
	parkey ( airmass, outfile, "AIRSTK", add+ )
	parkey ( meansky, outfile, "MEANSKY", add+ )

# Trim final stack

   	wclear ( outfile//"_tr" )
   	wclear ( expmap//"_tr.pl" )

   	imcopy ( outfile//"["//imoffx//":999,"//imoffy//":1002]", outfile//"_tr", verbose+ )
   	imcopy (expmap//"["//imoffx//":999,"//imoffy//":1002]", expmap//"_tr.pl", verbose+ )

# Compute XY location of reference star on trimmed image

	xst = xst - imoffx + 1
	yst = yst - imoffy + 1

#       display (outfile//"_tr", 1, erase+, bor+, fill+, zs+, xmag=1, ymag=1)

	parkey ( xst, outfile//"_tr", "XSTAR", add+ )
	parkey ( yst, outfile//"_tr", "YSTAR", add+ )

# Clean up intermediate files and clear variables

#	wclear ( "xy.out" ) ; wclear ( "xy.2" ); wclear ( "xy.in" )
#       wclear ("off.dat")

end
