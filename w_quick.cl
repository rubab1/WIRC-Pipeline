procedure w_quick (n1, n2, chip)

###########################################################
#						          #
#  Written by P McCarthy 10/2004                          #
#                                                         #
#  Makes a quick sky subtracted stack of images           #
#  from frames n1 through n2, usually a dither sequence   # 
#  or set of continguous dither sequences. The frames     # 
#  are first loop combined and then a median sky is       # 
#  formed. This sky is then scaled to each frame          #
#  and subtracted. The first image in the sequence        # 
#  is displayed and the user is asked to mark one or      #
#  more stars. The telescope offsets are then used as     #
#  a first guess for the positions which are improved     #
#  with a two-pass centroiding. An image stack is formed  #
#  using a simple band pixel mask. Calls wclear.cl.       #
#  Uses "center" from digiphot/apphot and "parkey"        #
#  and "keypar" from STSDAS. Report problems to           #
#  pmc2@ociw.edu                                          #
#                                                         #
#                                                         #
###########################################################

# Adapted to WIRC by GF
# 
# Uses hselect and hedit instead of keypar and parkey.
# I replaced the call to imexamine by a call to phot.
# 21Sep2005

int n1	    {prompt = "First frame"}
int n2	    {prompt = "Last frame"}
int chip    {prompt = "Chip number"}

struct	  *list1, *list2

begin

# Declarations
  file		offs.dat
  file		afile, brlist
  string	filter_name, type, filename, somename
  string        root_name, filter_old, file_root
  string        name, anothername, root, first_file, first_root
  string	skycount, wcfile, zptfile, rootname, prename
  string        forename, filelist, si
  real	        ra, dec, dec_old, ra_old, mean_sky, smean
  real          ra_dif, dec_dif, exp_dif, xstart, ystart
  real          newxinit, newyinit, xsum, ysum
  real          newxoff, newyoff, scale, obj_mode, sky_mode
  real          rasec, decsec, xrasec, ydecsec
  real          exposure, exposure_old, first_asec, first_dsec
  real          x, y, x1, y1, x2, y2, x3, y3, det_scl
  int           i, k, ra_dif2, dec_dif2, wcnum
  string 	nip

 det_scl = 0.196

# Make sure to set centerpars and datapars used by center task as follows:
  center.verify = no
#  centerpars.calgori="centroid"
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
  datapars.scale=det_scl
  datapars.fwhmpsf=2.5
  datapars.emissio=yes
  datapars.sigma=INDEF
  datapars.datamin=INDEF
  datapars.datamax=INDEF
  datapars.noise="poisson"
  datapars.ccdread=""
  datapars.gain=""
  datapars.readnoi=18
  datapars.epadu=2
  datapars.exposur=""
  datapars.airmass=""
  datapars.filter=""
  datapars.obstime=""
  datapars.itime=1

  set stdimage = "imt1024"

# Initialize variables 

	wclear ("sky.fits")
	wclear ("sky_list")
	wclear ("skycount")
	wclear ("wcfile")
        first_asec = 0.0
        first_dsec = 0.0
        zptfile = ""
        i = 0

        xstart = 0.0
        ystart = 0.0

# First - make list of frames 
 
        wclear ("loop_list")

        for ( i = n1 ; i <= n2 ; i += 1) {
	   padindex(i); nip = padindex.output
           if (access ("irx_"//nip//"_c"//chip//"_001.fits")) {
              print ("irx_"//nip//"_c"//chip//"_001.fits",>>"loop_list")
           }
# close for loop 
        }

#   Now combine loops - only 20 loop per pointing combined

        wclear ("combined_list")
        list1 = ""; list1="loop_list"
        while (fscan (list1,filename) != EOF)  {
             forename = substr(filename,1,12)
             root = substr(filename,5,12)

             wclear ("list_1")
             for (i=1 ; i <= 20 ; i += 1) {

	       padindex(i); si = substr(padindex.output,3,5)
               if (access(forename//"_"//si//".fits")) {
                 print (forename//"_"//si//".fits",>>"list_1")
               }
             }
            if (access("icx_"//root//".fits")) {}
             else {
               imcombine ("@list_1",output="icx_"//root//".fits",combine="average",scale="none")
             }
             print ("icx_"//root//".fits",>>"combined_list")
              
        }

        filelist = "combined_list"

# Make sky image
        wclear ("sky")
        imcombine ("@"//filelist,"sky.fits", combine="median", scale="mode",masktyp="none")

# Subtract sky image
        list2 = "" ; list2 = filelist
        while (fscan(list2,somename) != EOF) {
           root_name = substr(somename,5,12)
# Now I decided to recompute sky-subtracted images every time over
# since they get better as you add images to be stacked
#
#           if (access("isx_"//root_name//".fits")) {}
#           else {
   
            wclear ("isx_"//root_name//".fits")

# Find scaling from sky to object
# Find sky median, object median

             imstat ("sky.fits[20:1000,20:1000]",field="midpt",lower=INDEF,upper=INDEF,format-) | scan (sky_mode)
             imstat ("icx_"//root_name//".fits[20:1000,20:1000]",field="midpt",lower=INDEF,upper=INDEF,format-) | scan (obj_mode)
             
            # scaling sky to object median
             
              scale = (obj_mode / sky_mode)
              print ("scaling ratio =",scale, "frame = ", root_name)

	      wclear ("dummy")
              imar ("sky.fits","*",scale,"dummy",divz=1.,pixtype="real",calctyp="real",ver-) 
              imar ("icx_"//root_name,"-","dummy","isx_"//root_name,divz=1.,pixtype="real",calctyp="real",ver-)

# Find and subtract any residual sky level
              imstat ("isx_"//root_name//".fits",field="midpt",lower=-7500,upper=7500,format=no) | scan (mean_sky)
#print("TITO:", "isx_"//root_name//".fits","\n")
              imarith ("isx_"//root_name//".fits","-",mean_sky,"isx_"//root_name//".fits",divz=1.,pixtype="real",calctyp="real",ver-)
#             hedit ("isx_"//root_name//".fits","BPM","/home/panic/iraf/panic/PANIC_mask.pl",add+,verify-)
#            } # close if access  
        } # close while

# Now start the dithering process

        i = 0
        list1 = ""; list1="combined_list"
        while (fscan (list1,filename) != EOF)  {

# Find the first position in each dither sequence 

        hselect (filename, "asecs", yes) | scan (xstart)
        hselect (filename, "dsecs", yes) | scan (ystart)

        i = i + 1

        if (i == 1)  {
# Populate REFERENC file variables

	  first_asec = xstart
	  first_dsec = ystart

          zptfile=filename
          wclear ("init.dat")
          wclear ("slist")

          rootname = substr(filename,1,12)
          prename = substr(filename,5,12)

          display ("isx_"//prename, 1, erase+, bor+, fill+, zs+, xmag=1.0, ymag=1.0)

# Use imexam to interactively get approx coors for fiducial star - mark with "a" then quit

          print ( "")
          print ( "  >>>>> Mark some stars ( a  q )  " )
          print ( "")

          imexamine ( "isx_"//prename,1,keeplog+,logfile='slist' )
          !egrep -v '#' slist | awk '{print $1, $2 }' > init.dat

# Feed imexam co-ors to center task
# Use center task to get refined co-ors of fiducial star;

           wclear ("results.dat")
	   center ("isx_"//prename, coords="init.dat", output="results.dat", interactive=no, radplots=no, verify=no, update=no, calgori="centroid") 

	   !egrep -v '#' results.dat > log.dat
	   !egrep -v 'isx' log.dat >xy.dat
	   !awk '{print $1, $2}' xy.dat > xycoor1.dat

# x1, x2 are coors of fiducial star in zeropt ref frame
	   list2=""; list2 = "xycoor1.dat"
	   while (fscan (list2, x1, y1) !=EOF) { }

#	   write offsets and ref file name to header of ref file
           prename = substr(filename,5,12)
	   root = substr(filename, 1,12)
	   hedit ("isx_"//prename, "XOFF", 0., add+, upd+, veri-, show+)

	   hedit ("isx_"//prename, "YOFF", 0., add+, upd+, veri-, show+)

	   hedit ("isx_"//prename, "REFERENC", zptfile, add+, upd+, veri-, show+)

           wclear ("results.dat")
       	   wclear ("xy.dat")
           wclear ("log.dat")
 	   wclear ("init.dat")

	}   #closing brace for if i==1 loop 
	      
# For files after first, calc coords for center by adding offset to coordinates x1, y1
        
	else if (i > 1)  {

	   #read offset values from header
	   hselect (filename, "asecs", yes) | scan (rasec)
	   hselect (filename, "dsecs", yes) | scan (decsec)
	   
# Calc offset w/r/t ref frame location, find newest coors for fid star

# Need to fix up putting in xstart and ystart variable
           xrasec = real (rasec)
           ydecsec = real (decsec)
	   
# read ref file coors from center output
           list2 = "" ; list2 = "xycoor1.dat"
           while (fscan (list2, x1, y1) !=EOF) {

# calculate new estimated coors in pixels
# xrasec - first_asec is delta in asecs 
   
	   newxinit = x1 + (xrasec -  first_asec) / det_scl
	   newyinit = y1 - (ydecsec - first_dsec) / det_scl

	   print (newxinit, " ", newyinit ,>> "newinits.dat")

           }
# display image file

           rootname = substr(filename,1,12)
           prename = substr(filename,5,12)

           display ("isx_"//prename, 1, fill+, zs+, xmag=0.5, ymag=0.5)
           tvmark (1, coords="newinits.dat", mark="circle", radii="15",color=206)

# run center 2 times- 1)for general location, 2)to refine using smaller search region
           centerpars.cbox = 5.

	   center ("isx_"//prename, coords="newinits.dat", output="results.dat", interactive=no, radplots=no, verify=no, update=no, calgori="centroid") 

	   !egrep -v '#' results.dat > log.dat
           !egrep -v 'isx' log.dat >xy.dat
	   !awk '{print $1, $2}' xy.dat > xycoor.dat

	   # set smaller search region
           centerpars.cbox = 2.5

            wclear("results.dat")
            wclear("xy.dat")
            wclear("log.dat")

           center ("isx_"//prename, coords="xycoor.dat", output="results.dat", interactive=no, calgori="centroid")

           wclear("xycoor2.dat")

           !egrep -v '#' results.dat > log.dat
           !egrep -v 'isx' log.dat >xy.dat
           !awk '{print $1, $2}' xy.dat > xycoor2.dat

# xycoor.dat contains center task's final coors for star
# show center task's coors on display
           tvmark (1, coords="xycoor2.dat", mark="circle",color=207, radii="10")

!          paste xycoor1.dat xycoor2.dat >xycoor3.dat
# subtract new coors from ref file coors to get offset for each fiducial star
           wclear ("xycoor4.dat")
           
!          awk '{print ($1-$3), ($2-$4)}' xycoor3.dat > xycoor4.dat


# offset = zeropt frame location - current frame location
# calc average offset for all fiducials; xycoor4.dat is offsets list

           k = 0.0
           xsum = 0.
           ysum = 0.
           list2 = "" ; list2 = "xycoor4.dat"
	   while (fscan (list2, x2, y2) !=EOF) { 
           k = k + 1.0
           xsum = xsum + x2
           ysum = ysum + y2
           }
           
           x3 = xsum / k
           y3 = ysum / k

#          print ("x3 =", x3," y3 = ",y3," k = ",k, "file =","isx_"//prename)

           wclear("init.dat")
           wclear("xycoor.dat")
           wclear("newinits.dat")
           wclear("results.dat")
 
     
	   
# write offset (in pix) and name of zerpoint REFERENC file into header 
           prename = substr(filename,5,12)
           root = substr(filename,1,12)

 	   hedit ("isx_"//prename, "XOFF", x3, add+, upd+, veri-, show+)

 	   hedit ("isx_"//prename, "YOFF", y3, add+, upd+, veri-, show+)

	   hedit ("isx_"//prename, "REFERENC", zptfile, add+, upd+, veri-, show+)

	   }	  # close i>1 loop

	}	#close while loop used by fscan; fscan goes on to next file in list


  wclear("init.dat")
  wclear ("slist")
  wclear ("xycoor.dat")
  wclear ("newinits.dat")
  wclear ("results.dat")
  wclear ("xy.dat")
  wclear ("log.dat")
  wclear ("dummy")

# final cleanup of temp files

  delete ("xycoor1.dat")
  delete ("xycoor2.dat")
  delete ("xycoor3.dat")
  delete ("xycoor4.dat")

            wclear ("off.dat")
            wclear ("obj_list")
            wclear ("stack_"//n1//"_"//n2//"_c"//chip//".fits")
        

         list1 = ""; list1="combined_list"
         while (fscan (list1,filename) != EOF) {
            prename = substr(filename,5,12)             
            hselect ("isx_"//prename, "xoff", yes) | scan (newxoff)
            hselect ("isx_"//prename, "yoff", yes) | scan (newyoff)
            print (newxoff, newyoff ,>> "off.dat")
            print ("isx_"//prename//".fits",>>"obj_list")

             } 

#       imcombine ("@obj_list",output="stack_"//n1//"_"//n2//"_c"//chip//".fits",combine="average",scale="none",offsets="off.dat",masktype="goodvalue",maskvalue=0)
       imcombine ("@obj_list",output="stack_"//n1//"_"//n2//"_c"//chip//".fits",combine="average",scale="none",offsets="off.dat",masktype="none",maskvalue=0)

      display  ("stack_"//n1//"_"//n2//"_c"//chip//".fits",1,zs+)
      imexamine ("stack_"//n1//"_"//n2//"_c"//chip)
#      phot ("stack_"//n1//"_"//n2//"_c"//chip, interac=yes, calgori="none", radplot=yes, salgori="centroid", annulus=5., dannulus=3., weighti="constant", apertur="2")

# Clean up junk files
      wclear ("list_1"); wclear("loop_list"); wclear("mean") 
      wclear("obj_list"); wclear("objmode"); wclear("sky.fits")
      wclear("off.dat"); wclear("omode"); wclear("skymode")
      wclear("smode"); wclear("combined_list")

end

