procedure chk_sn_stks (inlist,scale,aper)

string inlist  {"",prompt = "List of SN stacks to review (.fits)"}
real   scale   {0.196, prompt = "Image scale in units per pixel"}
real   aper    {2.,prompt = "Photometry aperture in scale units"} 
bool   zscale  {yes,prompt = "Display range of greylevels near median"}
bool   zrange  {yes,prompt = "Display full image intensity range"}
real   z1      {0.,prompt = "Minimum greylevel to be displayed"}
real   z2      {100.,prompt = "Maximum greylevel to be displayed"}


struct *list1

begin
	string filelist, fname, expmap, root_name, comment
	string snname, filter, exptime, ncomb
	real x, y, sum, area, diff, tol, zd1, zd2, emax, apert, scl, mag, merr 
	real rexp, totexp
	int l, npix, inc
	bool zds, zdr

# Parameter 'tol' for determining bad pixels in aperture
	tol = 0.5

	apert = aper
	scl = scale

# First set photpars, centerpars and datapars used by center task:

  photpars.weighti = "constant"
  photpars.apertur = apert
  photpars.zmag    = 25.
  photpars.mkapert = yes
  fitskypars.salgori = "centroid"
  fitskypars.annulus = 7.
  fitskypars.dannulu = 2.
  centerpars.cbox=aper
  centerpars.cthresh=0
  centerpars.minsnra=1
  centerpars.cmaxite=10
  centerpars.maxshif=1
  centerpars.clean=no
  centerpars.rclean=1
  centerpars.rclip=2
  centerpars.kclean=3
  centerpars.mkcente=no
  datapars.scale=scl
  datapars.fwhmpsf=2.5
  datapars.emissio=yes
  datapars.sigma=INDEF
  datapars.datamin=-500.
  datapars.datamax=30000.
  datapars.noise="poisson"
  datapars.ccdread=""
  datapars.gain=""
  datapars.readnoi=18.
  datapars.epadu=2.
  datapars.exposur=""
  datapars.airmass=""
  datapars.filter=""
  datapars.obstime=""
  datapars.itime=1

	wclear ( "chk_sn_stk.out" )
	wclear ( "chk_sn_stk.plot" )

	printf ("%-24s %9s  %4s  %7s %7s  %7s  %-20s\n","  FRAME","SN   ","FILT","EXPTIME","MAG ","MERR ","COMMENT", > "chk_sn_stk.out" )

	filelist = inlist
        list1 = ""; list1 = filelist
        while (fscan (list1, fname, x, y) != EOF)     {

	if ( access ( fname ) ) {

# Initialize some display parameters
	   zds = zscale
	   zdr = zrange
	   zd1 = z1
	   zd2 = z2

# Get the name of the exposure map:
	   l = strlen (fname)
	   root_name = substr (fname, 4, l-5)
	   expmap = "exp"//root_name//".pl"

# Get maximum pix value in expmap.
# This is used to determine if any badpix fell inside SN aperture

	   imstat (expmap,fields="max", lower=INDEF, upper=INDEF, nclip=0, lsigma=3., usigma=3., binwidth=0.1, format=no, cache=no) | scan (emax)
 

# Create an overlay mask to mark badpixels in display:
	   wclear ( "rejmask.pl" )
	   if ( access (expmap)) {
	   	imcopy (expmap, "rejmask.pl", verbose=no)

	   	imreplace ("rejmask.pl", 1., imaginary=0., lower=INDEF, upper=emax-0.5, radius=0.)
 
	   	imreplace ("rejmask.pl", 0., imaginary=0., lower=emax-0.5, upper=emax+0.5, radius=0.)
	   }
	   else {
		wsorry ( expmap )

		imcopy ( fname, "rejmask.pl", verbose=no )
		imreplace ("rejmask.pl", 0., imaginary=0., lower=INDEF, upper=INDEF, radius=0.)
	   }

# Read SN name from header to help identify frame:
	   	keypar (fname, "object", silent+)
	   	snname = keypar.value 
	   	keypar (fname, "filter", silent+)
	   	filter = keypar.value 
	   	keypar (fname, "exptime", silent+)
	   	exptime = keypar.value 
		rexp = real(exptime)
	   	keypar (fname, "ncombine", silent+)
	   	ncomb = keypar.value
		inc = int(ncomb)
		totexp = rexp * inc	
	
	   	print ( "" )
	   	print ( " --------------------------------------------" )
	   	print ( " SN NAME:    ",snname,";     FILTER:  ",filter )
	   	print ( " --------------------------------------------" )
	   	print ( "" )

# Display the image:

disp:
	   	display (fname, 2, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="rejmask.pl", ocolors="red", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=no, zscale=zds, contrast=0.1, zrange=zdr, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0,z1=zd1, z2=zd2, ztrans="linear", lutfile="")

	   	display (fname, 1, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="", ocolors="", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=no, zscale=zds, contrast=0.1, zrange=zdr, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0,z1=zd1, z2=zd2, ztrans="linear", lutfile="")

# Interactively set the coordinates of the SN
# and compute aperture photometry:

           	print ( "")
           	print ( "  >>>>> Identify the SN  ( SPACE-BAR and quit with CTRL-D )  " )
           	print ( "")
           	print ( "  >>>>> Type CTRL-D to change the display range " )
           	print ( "")

	   	centerpars.calgori="gauss"

	   	wclear ("dummy.mag")
    phot (fname, "", coords="", output="dummy.mag", plotfile="", interactive=yes, radplots=yes, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=")_.update", verbose=")_.verbose", graphics=")_.graphics", display=")_.display")
 
 
		if ( !access ("dummy.mag" )) {
		   zds = no
		   zdr = no
		   print ( "")
		   print ( " Enter the new display range " )
		   print ( "")
		   print ( " z1: " )
		   scan (zd1)
		   print ( " z2: " )
		   scan (zd2)
		   goto disp
		}

    txdump ("dummy.mag", "xc,yc", "yes", headers=no, parameters=yes) | scan (x,y)
    wclear ("center.res")
    print ( x, y, >"center.res")
    hedit (fname, "xsn", x, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
    hedit (fname, "ysn", y, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)

    txdump ("dummy.mag", "mag,merr", "yes", headers=no, parameters=yes) | scan (mag,merr)
    print ( " " )
    print ("Photometry:  MAG = ",mag,"  ERR = ",merr )
    print ( " " )

    printf ("%-24s %9s %4s  %7.5g  %7.5g  %7.5g",fname,snname,filter,totexp,mag,merr, >> "chk_sn_stk.out" )

# Repeat phot to create radial profile plot.
    centerpars.calgori="none"
    wclear ("dummy.mag")

    phot (fname, "", coords="center.res", output="dummy.mag", plotfile="chk_sn_stk.plot", interactive=no, radplots=yes, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=")_.update", verbose=")_.verbose", graphics=")_.graphics", display=")_.display")

# Check if any pixel was rejected inside SN aperture:
	   if ( access (expmap)) {

		centerpars.calgori="none"

		wclear ("exposure.mag")

	        phot (expmap, "", coords="center.res", output="exposure.mag", plotfile="", interactive=no, radplots=yes, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=")_.update", verbose=")_.verbose", graphics=")_.graphics", display=")_.display")
 
		txdump ("exposure.mag", "sum,area", "yes", headers=no, parameters=yes) | scan (sum,area)

		diff = emax * area - sum
		npix = int ( diff )
		if ( abs (diff - npix) > 0.5 ) npix = npix + 1
	
		if (diff <= tol ) {
		    hedit (fname, "snstatus", "GOOD", add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)

# Mark the SN and its aperture in green

			tvmark (1, "center.res", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii=apert/scl, lengths="0", font="raster", color=205, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)

		}

		else {
		    hedit (fname, "snstatus", "BAD", add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)

# Mark the SN and its aperture in blue

		tvmark (1, "center.res", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii=apert/scl, lengths="0", font="raster", color=206, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)

		     }

		hedit (fname, "snbadpix", npix, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
		hedit (fname, "snaper", apert, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)	

	   }

	   else{
# Mark the SN and its aperture in yelow

		tvmark (1, "center.res", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii=apert/scl, lengths="0", font="raster", color=207, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)
		
		hedit (fname, "snstatus", "UNKNOWN", add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
		hedit (fname, "snbadpix", "UNKNOWN", add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
		hedit (fname, "snaper", apert, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)	
	   }	

# Prompt to add a comment in image header:
           comment=""
	   keypar ( fname, "comment", silent+)
	   if(keypar.found) comment=keypar.value

           print ( "")
	   print ( " Please add a comment in image header (one word)" )
           print ( "")
	   if (comment == "") {
	       print ( " If nothing is typed, then default is OK " )
	   }
	   else {
	       print ( " If nothing is typed, then default is ", comment )
	   }
           print ( "")


	   scan (comment)
	   if (comment == "") comment = "OK"

		hedit (fname, "comment", comment, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
	
	        printf ("  %-20s\n",comment, >> "chk_sn_stk.out" )

	   }
	   else {
	    	wsorry ( fname )    
	   }

	}	# close main while loop 

	wclear ("center.res")
	wclear ("exposure.mag")
	wclear ( "rejmask.pl" )
	wclear ("dummy.mag")

end
