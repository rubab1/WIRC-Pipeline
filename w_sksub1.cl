procedure w_sksub1 (p1, p2, p3, p4, chip )

int p1
int p2
int p3
int p4
int chip
struct	  *list1, *list2, *lista

########################################################
#  Written by P McCarthy and J Wilson, 8/19/99         #
#  This  task imcombines files to create a sky image   #
#  (using a combined object and bad pixel mask),       #
#  which is scaled by the object_mode/sky_mode ratio,  #
#  and is subtraced from the idf file to create an     #
#  is2 file. Output files are is2*fits and mask2*pl    #
#  files.				               #
########################################################

begin

# Declarations

	string sp1, sp3, sp4, somefile, mask_file, root_name
	string isx_num, num_, sky_list, sky, idf_list, idf_frame
	int k, j, xshift, yshift, xs, ys
	real sky_mode, fr_mode, scale, ss_mode
	real sky_mdpt, fr_mdpt

# Get date and chip out of header of first isx frame in list
# 'sp1' means 'string version of p1'

	padindex(p1) ; sp1=padindex.output
	padindex(p3) ; sp3=padindex.output
	padindex(p4) ; sp4=padindex.output

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

# Only need to go through p3,p4,'chip' list to make the sky

	w_pre_list ( "isx", p3, p4, k )

#  This is the mask of the stack

       mask_file = "mask_isx_"//sp3//"_c"//k//".pl"
 
       list1 = "" ; list1 = "isx_c"//k//"_list"
       while (fscan (list1,somefile) !=EOF) {

         isx_num = substr(somefile,1,9)
         num_    = substr(somefile,5,10)//"c"

         keypar (somefile, "xoff2")
         xshift = real(keypar.value)
         xs = xshift * -1

         keypar (somefile, "yoff2")
         yshift = real(keypar.value)
         ys = yshift * -1

# Copy mask file (mask_isx) into mask template to create mask of 
# correct size (mask2) and update header in sky frames
# Now remake mask2 files.

        wclear ("mask2_"//num_//k//".pl" )
	imshift (mask_file, "mask2_"//num_//k//".pl", xs, ys, shifts_file="", interp_type="linear", boundary_typ="constant", constant=1)
        imcopy ("mask2_"//num_//k//".pl"//"[1:1024,1:1024]", "mask2_"//num_//k//".pl", verbose-)

#  Now add in the badpixel mask = mcx_NNNNN_ck.pl, 

	imarith ("mask2_"//num_//k//".pl", "+", "mcx_"//num_//k//".pl", "mask2_"//num_//k//".pl", title="", divzero=0., hparams="", pixtype="", calctype="", verbose=no, noact=no)
	imreplace ("mask2_"//num_//k//".pl", 1, imaginary=0., lower=1.01, upper=INDEF, radius=0.)
	parkey("mask2_"//num_//k//".pl", "idf_"//num_//k//".fits", "BPM",add+)
	flprcache

	}   # close while over files in input list - all masks are now done

# Combine frames to make sky image

	w_pre_list ( "idf", p3, p4, k )
        sky_list = "idf_c"//k//"_list"
        sky = "sky_"//sp3//"_"//sp4//"_c"//k//".fits"
        wclear(sky)

	imcombine ("@"//sky_list, sky, headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="", sigmas="", logfile="STDOUT", combine="median", reject="pclip", project=no, outtype="real", outlimits="", offsets="none", masktype="goodvalue", maskvalue=0., blank=-999, scale="mode", zero="none", weight="none", statsec="", expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)

#  Store statistics in header

	w_store ( sky )
	keypar ( sky,"FRMODE",silent+ )
	sky_mode = real(keypar.value)   # Not in use
	keypar ( sky,"FRMEDIAN",silent+ )
	sky_mdpt = real(keypar.value)

#  Go through p1,p2,chip list to make 'is2' sky-subtracted frames

        w_pre_list ( "idf", p1, p2, k )
	idf_list = "idf_c"//k//"_list"

	list1 = "" ; list1 = idf_list
	while ( fscan ( list1, idf_frame ) != EOF )  {

	  w_store ( idf_frame )
	  keypar ( idf_frame,"FRMODE",silent+ )
	  fr_mode = real(keypar.value)          # Not in use
	  keypar ( idf_frame,"FRMEDIAN",silent+ )
	  fr_mdpt = real(keypar.value)
	  num_ = substr(idf_frame,5,10)//"c"

# OLD: # Scale sky to object mode
#             scale = (fr_mode / sky_mode)
# Scale sky to object median
	  scale = (fr_mdpt / sky_mdpt)

	  wclear ( "sky_scale" )
	  imarith (sky, "*", scale, "sky_scale", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

# Fix any blank pixels in the sky frame

	  w_store ( "sky_scale" )
	  keypar ( "sky_scale","FRMODE",silent+ )
	  ss_mode = real(keypar.value)
	  imreplace ("sky_scale", ss_mode, imaginary=0., lower=INDEF, upper=-500, radius=0.)

# Subtract the sky frame from the flattened frame

	  wclear ( "is2_"//num_//k//".fits" )
	  imarith (idf_frame, "-", "sky_scale", "is2_"//num_//k//".fits", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
	  flprcache

# Keep sky level in headers:
	  hedit ( "is2_"//num_//k//".fits", "SKYLEV", fr_mdpt, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)

# Commented this to speed up.
#         display ("is2_"//num_//k//".fits",1,zs+)

	}

#  Put correct mask back into idf and is2 file headers
#  Here is the change in the naming of the masks 28sep2004. 
#  They are now "mcx_NNNNN_ck.pl", created in 'w_flatten'.

        lista = "" ; lista = idf_list
        while (fscan (lista,somefile) !=EOF) {
          root_name = substr(somefile,5,11)
          parkey ("mcx_"//root_name//k//".pl", "is2_"//root_name//k//".fits", "BPM", add+)
          parkey ("mcx_"//root_name//k//".pl", "idf_"//root_name//k//".fits", "BPM", add+)
	}

# Restore the masks also in headers of sky frames and to delete useless masks:
        w_pre_list ( "idf", p3, p4, k )
        sky_list = "idf_c"//k//"_list"

        lista = "" ; lista = sky_list
        while (fscan (lista,somefile) !=EOF) {
         root_name = substr(somefile,5,11)
         parkey ("mcx_"//root_name//k//".pl", "idf_"//root_name//k//".fits", "BPM", add+)
	 wclear ("mask2_"//root_name//k//".pl")
	}
	  }
	}
# Clean up
	wclear (sky_list); wclear (idf_list)
	wclear ("sky_scale")

end
