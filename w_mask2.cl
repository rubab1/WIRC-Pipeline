procedure w_mask2 (p1, p2, chip )

int p1
int p2
int chip
struct	  *list1

#  Derived from 'w_mask1' by GF - adds a mask produced with
#  'makemask' to the one obtained from Sextractor.


begin
	string fname, onumber
	real xstar, ystar, xshift, yshift, newx, newy
	real size, x, y
	real r_small, r_medium, r_large, r_vlarge, r_alarge
	int k

	r_small  = 5
	r_medium = 10
	r_large  = 15
	r_vlarge = 25
	r_alarge = 45

# Set imedit parameters
#        imedit.display="no"
#        imedit.autodis="no"
        imedit.default="e"
#        set stdimage=imt2048

	wclear ("p0.fits") ; wclear ("p1.fits")
	wclear ("p2.fits") ; wclear ("p3.fits")
	wclear ("p4.fits") ; wclear ("e0.fits")
	wclear ("e1.fits") ; wclear ("e2.fits")
	wclear ("e3.fits") ; wclear ("e4.fits")
	wclear ("e0.pl")   ; wclear ("e1.pl")
	wclear ("e2.pl")   ; wclear ("e3.pl")
	wclear ("e4.pl")
 
	wclear ("sex_frame.fits")

        wclear ("objects_c")
        wclear ("small_objects_c")
        wclear ("medium_objects_c")
        wclear ("large_objects_c")
        wclear ("very_large_objects_c")
        wclear ("absurdly_large_objects_c") 

#  Get stack of sky frames created by 'w_stk1'    

	padindex(p1) ; onumber = padindex.output
        imcopy ("stk_"//onumber//"_c"//chip, "sex_frame", verbose-)

# Run sextractor to identify all objects

	!sex sex_frame.fits -c default.sex 
	!egrep -v '#' sex.cat >sex.list
	!awk '{print $8, $9, $10}' sex.list >objects_xy.dat

# Sort output into three lists according to isophotal size

        list1 = "" ; list1="objects_xy.dat"
        while (fscan (list1,size, x, y) != EOF) {
	  if (size <=  20) print (x," ",y, >> "small_objects_c")
          else if (size <= 100) print (x," ",y, >> "medium_objects_c")
          else if (size <= 400) print (x," ",y, >> "large_objects_c")
          else if (size <= 1000) print (x," ",y, >> "very_large_objects_c")
          if (size >= 1000) print (x," ",y, >> "absurdly_large_objects_c")
          print (x," ",y, >> "objects_c")
	}

# Zero out image to make blank template for mask to go in

	imreplace ("sex_frame.fits", 0.0, imaginary=0., lower=INDEF, upper=INDEF, radius=0.)
        imcopy ("sex_frame.fits","p0.fits", verbose-)
        imcopy ("sex_frame.fits","p1.fits", verbose-)
        imcopy ("sex_frame.fits","p2.fits", verbose-)
        imcopy ("sex_frame.fits","p3.fits", verbose-)
        imcopy ("sex_frame.fits","p4.fits", verbose-)
   
        wclear ("mask_isx_"//onumber//"_c"//chip//".fits")
        wclear ("mask_isx_"//onumber//"_c"//chip//".pl")

#  imedit the frame for large, medium and small objects, after checking that the
#  list is not empty for a particular size bin
#  makes intermediate masks for each size which will be added together later

        if (access ("small_objects_c")) {
          print ("small objects")

	  imedit ("sex_frame.fits", "e0.fits", cursor="small_objects_c", logfile="", display=yes, autodisplay=yes, autosurface=no, aperture="circular", radius=r_small, search=2., buffer=1., width=2., xorder=2, yorder=2, value=1, sigma=INDEF, angh=-33., angv=25., command="", graphics="stdgraph", default="e", fixpix=no)
	  flprcache
          imcopy ("e0.fits", "e0.pl", verbose-)
	}          
        if (access ("medium_objects_c")) {
          print ("medium objects")

	  imedit ("p1.fits", "e1.fits", cursor="medium_objects_c", logfile="", display=yes, autodisplay=yes, autosurface=no, aperture="circular", radius=r_medium, search=2., buffer=1., width=2., xorder=2, yorder=2, value=1, sigma=INDEF, angh=-33., angv=25., command="", graphics="stdgraph", default="e", fixpix=no)	
	  flprcache
          imcopy ("e1.fits", "e1.pl", verbose-)
	}          
        if (access ("large_objects_c")) {
          print ("large objects")

	  imedit ("p2.fits", "e2.fits", cursor="large_objects_c", logfile="", display=yes, autodisplay=yes, autosurface=no, aperture="circular", radius=r_large, search=2., buffer=1., width=2., xorder=2, yorder=2, value=1, sigma=INDEF, angh=-33., angv=25., command="", graphics="stdgraph", default="e", fixpix=no)	
	  flprcache
          imcopy ("e2.fits", "e2.pl", verbose-)
	}          
        if (access ("very_large_objects_c")) {
          print ("very large objects")

	  imedit ("p3.fits", "e3.fits", cursor="very_large_objects_c", logfile="", display=yes, autodisplay=yes, autosurface=no, aperture="circular", radius=r_vlarge, search=2., buffer=1., width=2., xorder=2, yorder=2, value=1, sigma=INDEF, angh=-33., angv=25., command="", graphics="stdgraph", default="e", fixpix=no)	
	  flprcache
          imcopy ("e3.fits", "e3.pl", verbose-)
	}         
        if (access ("absurdly_large_objects_c")) {
          print ("absurdly large objects")

	  imedit ("p4.fits", "e4.fits", cursor="absurdly_large_objects_c", logfile="", display=yes, autodisplay=yes, autosurface=no, aperture="circular", radius=r_alarge, search=2., buffer=1., width=2., xorder=2, yorder=2, value=1, sigma=INDEF, angh=-33., angv=25., command="", graphics="stdgraph", default="e", fixpix=no)	
	  flprcache
          imcopy ("e4.fits", "e4.pl", verbose-)
	}        

# Add up the size sorted object masks
	wclear ( "e99.pl" )
	imcopy ("p0.fits", "e99.pl", verbose-)
	if (access ("e0.pl")) imarith ("e99.pl", "+", "e0.pl", "e99.pl", title="", divzero=0., hparams="", pixtype="int", calctype="int", verbose=no, noact=no)

	if (access ("e1.pl")) imarith ("e99.pl", "+", "e1.pl", "e99.pl", title="", divzero=0., hparams="", pixtype="int", calctype="int", verbose=no, noact=no)

	if (access ("e2.pl")) imarith ("e99.pl", "+", "e2.pl", "e99.pl", title="", divzero=0., hparams="", pixtype="int", calctype="int", verbose=no, noact=no)

	if (access ("e3.pl")) imarith ("e99.pl", "+", "e3.pl", "e99.pl", title="", divzero=0., hparams="", pixtype="int", calctype="int", verbose=no, noact=no)

	if (access ("e4.pl")) imarith ("e99.pl", "+", "e4.pl", "e99.pl", title="", divzero=0., hparams="", pixtype="int", calctype="int", verbose=no, noact=no)

	imcopy ("e99.pl","mask_isx_"//onumber//"_c"//chip//".pl", verbose-)

	display ("mask_isx_"//onumber//"_c"//chip//".pl", 2, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="", ocolors="red", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=0., z2=100., ztrans="linear", lutfile="")

#	display ("stk_"//onumber//"_c"//chip, 2, erase=yes)

# Produce an alternative object mask using 'xdimsum'

	printf ( "Making a mask with makemask..." )
	wclear ( "mask_xdim"//onumber//"_c"//chip//".pl" )
	makemask ( "stk_"//onumber//"_c"//chip, "mask_xdim"//onumber//"_c"//chip//".pl", subsample=1, checklimits=yes, zmin=-200., zmax=30000., filtsize=201, nsmooth=3, statsec="", nsigrej=3., maxiter=20, threshtype="nsigma", nsigthresh=3.5, negthresh=yes, ngrow=0, verbose=no )
	print ( "done.\n" )

# Add this mask to the one produce with Sextractor:

	imarith ("mask_isx_"//onumber//"_c"//chip//".pl", "+", "mask_xdim"//onumber//"_c"//chip//".pl", "mask_isx_"//onumber//"_c"//chip//".pl", title="", divzero=0., hparams="", pixtype="int", calctype="int", verbose=no, noact=no)

	imreplace ( "mask_isx_"//onumber//"_c"//chip//".pl", 1, imaginary=0., lower=1, upper=INDEF, radius=0.)

	display ("mask_isx_"//onumber//"_c"//chip//".pl", 2, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="", ocolors="red", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=0., z2=100., ztrans="linear", lutfile="")

# Erase unnecessary stacked frame: (DISABLED)
#	wclear ( "stk_"//onumber//"_c"//chip )

# Clean-up:
	wclear ("p0.fits") ; wclear ("p1.fits")
	wclear ("p2.fits") ; wclear ("p3.fits")
	wclear ("p4.fits") ; wclear ("e0.fits")
	wclear ("e1.fits") ; wclear ("e2.fits")
	wclear ("e3.fits") ; wclear ("e4.fits")
	wclear ("e0.pl")   ; wclear ("e1.pl")
	wclear ("e2.pl")   ; wclear ("e3.pl")
	wclear ("e4.pl")   ; wclear ("e99.pl")
 
	wclear ("sex.cat") ; wclear ("sex_frame.fits")
	wclear ("sex.list") ; wclear ("objects_xy.dat")

        wclear ("objects_c")
        wclear ("small_objects_c")
        wclear ("medium_objects_c")
        wclear ("large_objects_c")
        wclear ("very_large_objects_c")
        wclear ("absurdly_large_objects_c")

end
