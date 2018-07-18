procedure w_dither1 (p1, p2, chip )

int p1
int p2
int chip
struct *list1
struct *list2

# This version is a copy of w_dither1 without all the displaying and
# imexamines.
# An attempt to speed up the reductions.

begin

	string filename, root_name, is2_frame, is3_frame
	string onumber, filelist, isx_frame, idf_frame
	int i, k
	real asecs0, dsecs0, x, y, x1, y1, x2, y2, x3, y3
	real newxinit, newyinit, rasec, decsec
	real xsum, ysum, ka, sense, xfid, yfid

#  Get starting asecs, dsecs values out - these are asecs0 and dsecs0

	padindex(p1) ; onumber = padindex.output

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

        isx_frame = "isx_"//onumber//"_c"//k
        idf_frame = "idf_"//onumber//"_c"//k
	if ( access ( idf_frame//".fits" )) {
	  keypar(idf_frame,"XFID",silent+)
	  if(keypar.found) xfid = real(keypar.value)
	  keypar(idf_frame,"YFID",silent+)
	  if(keypar.found) yfid = real(keypar.value)
	  keypar(idf_frame,"asecs",silent+)
	  asecs0 = real(keypar.value)
	  keypar(idf_frame,"dsecs",silent+)
	  dsecs0 = real(keypar.value)
	} else {
	  wsorry(idf_frame)
	  clbye()
	}

# Initialize variables

	wclear ("xycoor.dat")  ; wclear ("xycoor1.dat") ; wclear ("xycoor2.dat")
	wclear ("xycoor3.dat") ; wclear ("xycoor4.dat") ; wclear ("results.dat")
	wclear ("xy.dat")     ; wclear ("log.dat")     ; wclear ("newinits.dat")

# Loop through files calculating offset and new approx co-ors for fiducial;

	w_pre_list ( "isx", p1, p2, k )	
	filelist = "isx_c"//k//"_list"

# If 'is2' frames exist, use those
	if ( access ( "is2_"//onumber//"_c"//k//".fits" )) {
	  w_pre_list ( "is2", p1, p2, k )	
	  filelist = "is2_c"//k//"_list"
	}

#  If 'is3' frames exist, use those
	if ( access ( "is3_"//onumber//"_c"//k//".fits" )) {
	  w_pre_list ( "is3", p1, p2, k )	
	  filelist = "is3_c"//k//"_list"
	}

	i = 0		#counting variable

	list1 = ""; list1=filelist
 	while (fscan (list1,filename) != EOF) {
          i += 1
          if (i == 1) {
            wclear ("init.dat")
	    print ( xfid,"  ",yfid, > "init.dat" )

# Feed imexam coords to center task and 
# Use center task to get refined co-ors of fiducial star.

# First set centerpars and datapars used by center task:

  center.verify = no
  centerpars.calgori="centroid"
  centerpars.cbox=2.5
  centerpars.cthresh=0
  centerpars.minsnra=1
  centerpars.cmaxite=10
  centerpars.maxshif=1
  centerpars.clean=no
  centerpars.rclean=1
  centerpars.rclip=2
  centerpars.kclean=3
  centerpars.mkcente=no
  datapars.scale=0.196
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

	    display ( filename, 1, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="", ocolors="red", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=no, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=0., z2=100., ztrans="linear", lutfile="")

	    tvmark (1, "init.dat", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii="15", lengths="0", font="raster", color=205, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)
 
	    center (filename, coords="init.dat", output="results.dat", plotfile="", interactive=no, radplots=no, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=no, verbose=")_.verbose", graphics=")_.graphics", display=")_.display")
 
	    !egrep -v '#' results.dat > log.dat
	    !egrep -v 'is' log.dat >xy.dat
	    !awk '{print $1, $2}' xy.dat > xycoor1.dat

# print("")
# !awk '{print $1, $2}' xycoor1.dat
# print("")

# Write offsets to header of idf, isx, is2, and is3 frames if they exist.

	    parkey (0, idf_frame, "XOFF", add+)
	    parkey (0, idf_frame, "YOFF", add+)

	    if ( access ( isx_frame//".fits" ))	{
	      parkey (0, isx_frame, "XOFF", add+)
	      parkey (0, isx_frame, "YOFF", add+)
	    }
	    if ( access ( "is2_"//onumber//"_c"//k//".fits" )) {
	      is2_frame = "is2_"//onumber//"_c"//k
	      parkey (0, is2_frame, "XOFF", add+)
	      parkey (0, is2_frame, "YOFF", add+)
	    }
	    if ( access ( "is3_"//onumber//"_c"//k//".fits" )) {
	      is3_frame = "is3_"//onumber//"_c"//k
	      parkey (0, is3_frame, "XOFF", add+)
	      parkey (0, is3_frame, "YOFF", add+)
	    }

	    wclear ("results.dat")
	    wclear ("xy.dat")
            wclear ("log.dat")
	    wclear ("init.dat")

	  }   #closing brace for if i==1 loop 
	      
# For files after first, calc coords for center by
# adding offset to coordinates x1, y1
        
	  else if (i > 1) {

# Read offset values from header}

	    keypar (filename, "asecs", silent+)
	    rasec = real(keypar.value) 
	    keypar (filename, "dsecs", silent+)
	    decsec = real(keypar.value) 

# Read ref file coors from center output

            list2 = "" ; list2 = "xycoor1.dat"
            while (fscan (list2, x1, y1) !=EOF) {

# Calculate new estimated coors in pixels

	      newxinit = x1 + (rasec -  asecs0 ) / 0.196
	      newyinit = y1 - (decsec - dsecs0 ) / 0.196
	      print (newxinit, " ", newyinit ,>> "newinits.dat")
	    }

# Run center 2 times  (1) for general location, 
#                     (2) to refine using smaller search region

	    centerpars.cbox = 5.
	    center (filename, coords="newinits.dat", output="results.dat", plotfile="", interactive=no, radplots=no, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=no, verbose=")_.verbose", graphics=")_.graphics", display=")_.display")
 
	    !egrep -v '#' results.dat > log.dat
            !egrep -v 'fits' log.dat >xy.dat
	    !awk '{print $1, $2}' xy.dat > xycoor.dat

# Set smaller search region
            centerpars.cbox = 2.5
            wclear("results.dat")
            wclear("xy.dat")
            wclear("log.dat")
	    center (filename, coords="xycoor.dat", output="results.dat", plotfile="", interactive=no, radplots=no, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=no, verbose=")_.verbose", graphics=")_.graphics", display=")_.display")

            wclear("xycoor2.dat")

            !egrep -v '#' results.dat > log.dat
            !egrep -v 'is' log.dat > xy.dat
            !awk '{print $1, $2}' xy.dat > xycoor2.dat

	    display ( filename, 1, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="", ocolors="red", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=no, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=0., z2=100., ztrans="linear", lutfile="")

	    tvmark (1, "xycoor2.dat", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii="15", lengths="0", font="raster", color=205, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)
 

	    !paste xycoor1.dat xycoor2.dat > xycoor3.dat
# Subtract new coors from ref file coors to get offset for each fiducial star
	    !awk '{print ($1-$3), ($2-$4)}' xycoor3.dat > xycoor4.dat

# Offset = zeropt frame location - current frame location
# Calc average offset for all fiducials; xycoor4.dat is offsets list

            ka = 0.0
            xsum = 0.
            ysum = 0.
            list2 = "" ; list2 = "xycoor4.dat"
	    while (fscan (list2, x2, y2) !=EOF) { 
              ka = ka + 1.0
              xsum = xsum + x2
              ysum = ysum + y2
	    }
            x3 = xsum / ka
            y3 = ysum / ka
            wclear("init.dat")
            wclear("xycoor.dat")
            wclear("newinits.dat")
            wclear("results.dat")

# Write offset (in pix) into header 

	    root_name = substr(filename,5,12)
	    idf_frame = "idf_"//root_name
	    isx_frame = "isx_"//root_name
	    is2_frame = "is2_"//root_name
	    is3_frame = "is3_"//root_name

	    if (access (idf_frame//".fits" )) {
	      parkey (x3, idf_frame, "XOFF", add+)
	      parkey (y3, idf_frame, "YOFF", add+)
	    }
	    if (access (isx_frame//".fits" )) {
	      parkey (x3, isx_frame, "XOFF", add+)
	      parkey (y3, isx_frame, "YOFF", add+)
	    }
	    if (access (is2_frame//".fits" )) {
	      parkey (x3, is2_frame, "XOFF", add+)
	      parkey (y3, is2_frame, "YOFF", add+)
	    }
	    if (access (is3_frame//".fits" )) {
	      parkey (x3, is3_frame, "XOFF", add+)
	      parkey (y3, is3_frame, "YOFF", add+)
	    }
	  }  # close i>1 loop
	}  #close while loop used by fscan; fscan goes on to next file in list

# Call reset to fix offsets so that offset scale starts at zero

	print ("resetting offsets to positive values")
	w_offreset (filelist)

# Final cleanup of temp files

	wclear ("xycoor1.dat")
	wclear ("xycoor2.dat")
	wclear ("xycoor3.dat")
	wclear ("xycoor4.dat")
	wclear ("xy.dat")
	wclear ("log.dat")
	wclear ("psf0")
	wclear ("psf1")
	  }
	}
end
