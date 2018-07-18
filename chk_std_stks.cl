procedure chk_std_stks (inlist,scale)

string inlist  {"",prompt = "List of SN stacks to review (.fits)"}
real   scale   {0.196, prompt = "Image scale in units per pixel"}
bool   zscale  {yes,prompt = "Display range of greylevels near median"}
bool   zrange  {yes,prompt = "Display full image intensity range"}
real   z1      {0.,prompt = "Minimum greylevel to be displayed"}
real   z2      {100.,prompt = "Maximum greylevel to be displayed"}

struct *list1

begin
	string filelist, fname
	string stdname, filter
	real xstar, ystar, zd1, zd2, scl
	bool zds, zdr

	scl = scale

  center.verify = no
  centerpars.cbox=5.
  centerpars.calgori="gauss"
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
  datapars.readnoi=15.
  datapars.epadu=2.
  datapars.exposur=""
  datapars.airmass=""
  datapars.filter=""
  datapars.obstime=""
  datapars.itime=1

	filelist = inlist
        list1 = ""; list1 = filelist
        while (fscan (list1, fname, x, y) != EOF)     {

	   if ( access ( fname ) ) {

#	Initialize some display parameters
	      zds = zscale
	      zdr = zrange
	      zd1 = z1
	      zd2 = z2

# Read STD STAR name from header to help identify frame:
	      keypar (fname, "object", silent+)
	      stdname = keypar.value 
	      keypar (fname, "filter", silent+)
	      filter = keypar.value 
	
	      print ( "" )
	      print ( " ----------------------------------------------" )
	      print ( " STD NAME:    ",stdname,";     FILTER:  ",filter )
	      print ( " ----------------------------------------------" )
	      print ( "" )

              keypar (fname, "XSTAR", silent+)
              if (keypar.found) xstar = real(keypar.value)
              keypar (fname, "YSTAR", silent+)
              if (keypar.found) ystar = real(keypar.value)

	      wclear ("center.res")
	      print ( xstar, ystar, > "center.res")

disp:
	      display (fname, 1, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="", ocolors="", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=no, zscale=zds, contrast=0.25, zrange=zdr, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0,z1=zd1, z2=zd2, ztrans="linear", lutfile="")

# Mark the STD in green

	      tvmark (1, "center.res", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii=5./scl, lengths="0", font="raster", color=205, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)

# Interactively set the coordinates of the STD:

	      print ( "")
	      print ( "  >>>>> Identify the STD  ( SPACE-BAR and quit with CTRL-D )  " )
	      print ( "")
	      print ( " Type CTRL-D to change the display range " )
	      print ( "")

	      wclear ("center2.res")
	      center (fname, coords="", output="center2.res", plotfile="", interactive=yes, radplots=no, icommands="", gcommands="" )

	      if ( !access ("center2.res" )) {
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

	      txdump ("center2.res", "xc,yc", "yes", headers=no, parameters=yes) | scan (xstar,ystar)

	      parkey ( xstar, fname, "XSTAR", add+ )
	      parkey ( ystar, fname, "YSTAR", add+ )

# Mark the STD in red

	      tvmark (1, "center2.res", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii=5./scl, lengths="0", font="raster", color=204, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)

	   } else {
	      wsorry ( fname )
	   }
	}

	wclear ("center.res")
	wclear ("center2.res")

end
