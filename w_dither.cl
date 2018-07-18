procedure w_dither (p1, p2,chip)

# This script should be equivalent of p_dither for PANIC/RetroCAM

string cam
int p1, p2
int chip
struct *list1
struct *list2

begin

	string sp1, filelist, filename, reffile, zptfile
	int i, flag, k
	real scale, xstart, ystart, first_asec, first_dsec, rotang
	real sense, xfid, yfid, mag, elli, fwhm, fhthr, ellithr
	real x1, y1, psf_e, psf_d, rasec, decsec, x2, y2, xdiff, ydiff
	real newxinit, newyinit, cbox

        ellithr = 0.1
	fhthr = 10.0	
	scale = 0.196
	cbox = 5

	centerpars.calgori="centroid"
	centerpars.cbox=cbox/2.
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

	padindex (p1); sp1 = padindex.output

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

	if ( access ( "is2_"//sp1//"_c"//k//".fits" )) {

	  w_pre_list ( "is2", p1, p2,k )	
	  filelist = "is2_c"//k//"_list"

	} else {

	  w_pre_list ( "isx", p1, p2, k )	
	  filelist = "isx_c"//k//"_list"
	  
	}

	i = 0

  	list1 = ""; list1=filelist
  	while (fscan (list1,filename) != EOF)  {

       	keypar (filename, "asecs", silent+)
       	xstart = real(keypar.value)
       	keypar (filename, "dsecs", silent+)
        ystart = real(keypar.value)

        i += 1
        if (i == 1)  {

	   zptfile=filename
	   reffile = filename
	   first_asec = xstart
	   first_dsec = ystart

	   rotang = 250.
	   keypar(filename,"ROTANG",silent+)
	   if ( keypar.found ) rotang = real(keypar.value)

	   if ( rotang <= 50. ) sense = -1.
	   if ( rotang >= 200. ) sense = 1. 

	   xfid = 0. ; yfid = 0.

	   keypar(filename,"XFID",silent+)
	   if(keypar.found) xfid = real(keypar.value)

	   keypar(filename,"YFID",silent+)
	   if(keypar.found) yfid = real(keypar.value)
	   
	   wclear ( "init.dat" )
	   wclear ( "results.dat" )

	   print ( xfid,"  ",yfid, > "init.dat" )
	   center (filename, coords="init.dat", output="results.dat", plotfile="", interactive=no, radplots=no, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=no, verbose=yes, graphics=")_.graphics", display=")_.display")

	   !egrep -v '#' results.dat | egrep -v 'is' - | awk '{print $1, $2}' - > xycoor1.dat

	   wclear ( "psf0" ); wclear ( "psf1" )

	   imexamine (filename, 1, filename, output="", ncoutput=101, nloutput=101, logfile="psf0", keeplog=yes, defkey="a", autoredraw=yes, allframes=yes, nframes=0, ncstat=5, nlstat=5, graphcur="", imagecur="xycoor1.dat", wcs="logical", xformat="", yformat="", graphics="stdgraph", display="display(image='$1',frame=$2)", use_display=no)
	
	   type ("xycoor1.dat") | scan ( x1, y1 )

           !egrep -v '#' psf0 | awk '{print $12, $14 }' - > psf1
	   type ("psf1")      | scan ( psf_e, psf_d )

	   parkey (0, filename, "XOFF", add+)
	   parkey (0, "idf_"//substr(filename, 5,12), "XOFF", add+)
	   parkey (0, filename, "YOFF", add+)
	   parkey (0, "idf_"//substr(filename, 5,12), "YOFF", add+)
	   parkey (zptfile, filename, "REFERENC", add+)
	   parkey (zptfile, "idf_"//substr(filename, 5,12), "REFERENC", add+)

	   parkey (psf_e, filename, "PSFE", add+)
	   parkey (psf_e, "idf_"//substr(filename, 5,12), "PSFE", add+)
	   parkey (psf_d, filename, "PSFD", add+)
	   parkey (psf_d, "idf_"//substr(filename, 5,12), "PSFD", add+)

	   wclear ("results.dat")
	   wclear ("init.dat")
#	   wclear ("init2.dat")
	   wclear ("psf0"); wclear("psf1")

	}   # closing brace for if i==1 loop 
	      
	else if (i > 1)  {

	   wclear ("newinits.dat")
	   wclear ( "results.dat" )

	   keypar (filename, "asecs", silent+)
	   rasec = real(keypar.value) 
	   keypar (filename, "dsecs", silent+)
	   decsec = real(keypar.value) 
	   
 	   newxinit = x1 + (rasec -  first_asec ) / scale
	   newyinit = y1 -  (decsec - first_dsec) / scale
	   
	   print (newxinit, " ", newyinit ,>> "newinits.dat")

	   display (filename, 1, bpmask="", bpdisplay="none", bpcolors="red", overlay="", ocolors="green", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=INDEF, z2=INDEF, ztrans="linear", lutfile="")
           
	   tvmark (1, "newinits.dat", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii="15", lengths="0", font="raster", color=205, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)

           centerpars.cbox = cbox

	   center (filename, coords="newinits.dat", output="results.dat", plotfile="", interactive=no, radplots=no, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=no, verbose=yes, graphics=")_.graphics", display="")

	   !egrep -v '#' results.dat | egrep -v 'is' - | awk '{print $1, $2}' - > xycoor1.dat

           centerpars.cbox = cbox/2.
	   wclear ( "results.dat" )

	   center (filename, coords="xycoor1.dat", output="results.dat", plotfile="", interactive=no, radplots=no, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=no, verbose=yes, graphics=")_.graphics", display="")

	   !egrep -v '#' results.dat | egrep -v 'is' - | awk '{print $1, $2}' - > xycoor1.dat

	   wclear ( "psf0" ); wclear ( "psf1" )

	   imexamine (filename, 1, filename, output="", ncoutput=101, nloutput=101, logfile="psf0", keeplog=yes, defkey="a", autoredraw=yes, allframes=yes, nframes=0, ncstat=5, nlstat=5, graphcur="", imagecur="xycoor1.dat", wcs="logical", xformat="", yformat="", graphics="stdgraph", display="display(image='$1',frame=$2)", use_display=no)
	
	   type ("xycoor1.dat") | scan ( x2, y2 )

           !egrep -v '#' psf0 | awk '{print $12, $14 }' - > psf1
	   type ("psf1")      | scan ( psf_e, psf_d )

	   tvmark (1, "xycoor1.dat", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii="15", lengths="15", font="raster", color=204, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)

	   xdiff = x1 - x2
	   ydiff = y1 - y2

	   parkey (xdiff, filename, "XOFF", add+)
	   parkey (xdiff, "idf_"//substr(filename, 5,12), "XOFF", add+)
	   parkey (ydiff, filename, "YOFF", add+)
	   parkey (ydiff, "idf_"//substr(filename, 5,12), "YOFF", add+)
	   parkey (zptfile, filename, "REFERENC", add+)
	   parkey (zptfile, "idf_"//substr(filename, 5,12), "REFERENC", add+)
	   parkey (psf_e, filename, "PSFE", add+)
	   parkey (psf_e, "idf_"//substr(filename, 5,12), "PSFE", add+)
	   parkey (psf_d, filename, "PSFD", add+)
	   parkey (psf_d, "idf_"//substr(filename, 5,12), "PSFD", add+)

           wclear("newinits.dat")
           wclear("results.dat")
           wclear("xycoor1.dat")
           wclear("psf0")
           wclear("psf1")

	}	  # close i>1 loop

	}	#close while loop used by fscan; fscan goes on to next file in list

    }

}

	w_reset (filelist)

end
