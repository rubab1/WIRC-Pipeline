procedure chk_sn_stks (inlist,scale,aper)

string inlist  {"",prompt = "List of SN stacks to review (.fits)"}
real   scale   {0.196, prompt = "Image scale in units per pixel"}
real   aper    {5.,prompt = "Photometry aperture in scale units"} 
bool   zscale  {yes,prompt = "Display range of greylevels near median"}
bool   zrange  {yes,prompt = "Display full image intensity range"}
real   z1      {0.,prompt = "Minimum greylevel to be displayed"}
real   z2      {100.,prompt = "Maximum greylevel to be displayed"}


struct *list1

begin
	string filelist, fname, root_name, comment
	string snname, filter
	real x, y, sum, area, diff, tol, zd1, zd2, emax, apert, scl
	int l, npix
	bool zds, zdr

	apert = aper
	scl = scale


	filelist = inlist
        list1 = ""; list1 = filelist
        while (fscan (list1, fname, x, y) != EOF)     {

	if ( access ( fname ) ) {

# Initialize some display parameters
	   zds = zscale
	   zdr = zrange
	   zd1 = z1
	   zd2 = z2

# Display image:

	   display (fname, 1, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="", ocolors="red", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=no, zscale=zds, contrast=0.05, zrange=zdr, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0,z1=zd1, z2=zd2, ztrans="linear", lutfile="")

# Check if the SN has already been marked before and if so, mark it on display:
	   keypar (fname, "xsn", silent+)
	
	   if (keypar.found && keypar.value != "") {
	   	x = real(keypar.value)
	   	keypar (fname, "ysn", silent+)
	   	y = real(keypar.value)

	   	wclear ("center2.res")
	   	print ( x, y, >"center2.res")
	
			tvmark (1, "center2.res", logfile="", autolog=no, outimage="", deletions="", commands="", mark="plus", radii=apert/scl, lengths="0", font="raster", color=204, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)

	   }

# Read SN name from header to help identify frame:
	   	keypar (fname, "object", silent+)
	   	snname = keypar.value 
	   	keypar (fname, "filter", silent+)
	   	filter = keypar.value 
	
	   	print ( "" )
	   	print ( " --------------------------------------------" )
	   	print ( " SN NAME:    ",snname,";     FILTER:  ",filter )
	   	print ( " --------------------------------------------" )
	   	print ( "" )

# Display the image:

# Interactively set the coordinates of the SN:

           	print ( "")
           	print ( "  >>>>> Identify the SN  ( a and quit with q )  " )
           	print ( "")
           	print ( " Type q to change the display range " )
           	print ( "")

disp:
	   	wclear ("center.res")

		imexamine (fname, 1, logfile="center.res", keeplog=yes, defkey="a")

		if ( !access ("center.res" )) {
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

	   	tdump ("center.res", cdfile="dev$null", pfile="dev$null", datafil="STDOUT", columns="1,2",rows="-",pwidth=-1) | scan (x,y)
 
	print(x)
	print(y)

	   	hedit (fname, "xsn", x, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)
	
	   	hedit (fname, "ysn", y, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)


# Mark the SN and its aperture in green

			tvmark (1, "center.res", logfile="", autolog=no, outimage="", deletions="", commands="", mark="plus", radii=apert/scl, lengths="0", font="raster", color=205, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)

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
	
	   }
	   else {
	    	wsorry ( fname )    
	   }

	}	# close main while loop 

	wclear ("center.res")
	wclear ("center2.res")

end
