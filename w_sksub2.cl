procedure w_sksub2 (p1, p2, p3, p4, chip )

int p1
int p2
int p3
int p4
int chip
struct	  *list1, *list2, *lista

# This is a version of w_sksub1, modified to subtract sky in a second
# pass, with improved scaling.

begin

# Declarations

	string sp1, sp3, sp4, date, somefile, mask_file, root_name
	string isx_num, num_, sky, idf_list, idf_frame, msk
	int k, j, xshift, yshift, xs, ys
	real sky_mode, fr_mode, scale, ss_mode
	real sky_mdpt, fr_mdpt, scale2, ss_mdpt

# Get date and chip out of header of first 'idf' frame in list
# 'sp1' means 'string version of p1'

	padindex(p1) ; sp1=padindex.output
	padindex(p3) ; sp3=padindex.output
	padindex(p4) ; sp4=padindex.output

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

# Initialize a file for use with 'imsurfit':

#	wclear ( "surf.section" )
#	print ( 20, "  ", 990, "  ", 20, "  ", 990, > "surf.section" )

#  This is the mask of the stack

	mask_file = "mask_isx_"//sp1//"_c"//k//".pl"

# Sky frame has already been created by w_sksub1

	sky = "sky_"//sp3//"_"//sp4//"_c"//k//".fits"
	keypar ( sky,"FRMODE",silent+ )
	sky_mode = real(keypar.value)
	keypar ( sky,"FRMEDIAN",silent+ )
	sky_mdpt = real(keypar.value)

#  Go through p1,p2,chip list to make 'is3' second-pass 
#  sky-subtracted frames

        w_pre_list ( "idf", p1, p2, k )
	idf_list = "idf_c"//k//"_list"
	list1 = "" ; list1 = idf_list
	while ( fscan ( list1, idf_frame ) != EOF ) {
	  num_ = substr(idf_frame,5,10)//"c"
	  keypar (idf_frame, "xoff2")
          xshift = real(keypar.value)
          xs = xshift * -1
          keypar (idf_frame, "yoff2")
          yshift = real(keypar.value)
          ys = yshift * -1

# Mask objects before finding scale factor to apply to sky stack
	  wclear ( "masked_frame" )

# Shift object mask
          wclear ("mask2_"//num_//k//".pl" )
	  imshift (mask_file, "mask2_"//num_//k//".pl", xs, ys, shifts_file="", interp_type="linear", boundary_typ="constant", constant=1)
 
          imcopy ("mask2_"//num_//k//".pl"//"[1:1024,1:1024]", "mask2_"//num_//k//".pl", verbose-)

# Read badpix mask
	  keypar ( idf_frame, "BPM", silent+ ) ; msk = keypar.value

# Add the two masks:
	  if ( access ( msk )) {
	    imarith ( msk, "+", "mask2_"//num_//k//".pl", "mask2_"//num_//k//".pl", title="", divzero=0., hparams="", pixtype="int", calctype="int", verbose=no, noact=no)

	    imreplace ( "mask2_"//num_//k//".pl", 1, imaginary=0., lower=1, upper=INDEF, radius=0.)
	  } else  {}

# Create a masked frame to do statistics on.
	  imcalc ( idf_frame//",mask2_"//num_//k//".pl", "masked_frame", "if im2 .eq. 1 then -999. else im1", pixtype="old", nullval=-999.,verbose- ) 

# Delete computed mask:
	  wclear ("mask2_"//num_//k//".pl" )

# Do statistics on masked frame:
	  w_store ( "masked_frame" )
	  keypar ( "masked_frame","FRMODE",silent+ ) ; fr_mode = real(keypar.value)
	  keypar ( "masked_frame","FRMEDIAN",silent+ ) ; fr_mdpt = real(keypar.value)

# Scale sky to object mode (NOT IN USE)
#         scale = (fr_mode / sky_mode)
# Scale sky to object median
	  scale = (fr_mdpt / sky_mdpt)
	  wclear ( "sky_scale" )
	  imarith (sky, "*", scale, "sky_scale", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

# Fix any blank pixels in the sky frame
	  w_store ( "sky_scale" )
	  keypar ( "sky_scale","FRMODE",silent+ ) ; ss_mode = real(keypar.value)

	  imreplace ("sky_scale", ss_mode, imaginary=0., lower=INDEF, upper=-500, radius=0.)

# Subtract the sky frame from the flattened frame
	  wclear ( "is3_"//num_//k )
	  imarith (idf_frame, "-", "sky_scale", "is3_"//num_//k//".fits", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
	  flprcache
	  hedit ( "is3_"//num_//k//".fits", "SKYLEV", fr_mdpt, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)

#  Try commenting this to speed up.
	  display ("is3_"//num_//k//".fits", 1, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="", ocolors="red", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=no, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=0., z2=100., ztrans="linear", lutfile="")

# Try subtracting a residual smooth surface:

#	  wclear ( "is4_"//num_//k )
#	  imsurfit ("is3_"//num_//k, "is4_"//num_//k, 3, 3, type_ou="residual", function="legendre", cross_t=yes, xmedian=1, ymedian=1, lower=3., upper=3., ngrow=0,niter=5, regions="sections", section="surf.section")
#	  display ("is4_"//num_//k//".fits",1,zs+)

	} 

#  Put correct mask back into is3 and is4 file headers
#  The masks are "mcx_NNNNN_ck.pl".

        lista = "" ; lista = idf_list
        while (fscan (lista,somefile) !=EOF) {
          root_name = substr(somefile,5,11)
          parkey ("mcx_"//root_name//k//".pl", "is3_"//root_name//k//".fits", "BPM", add+)
#         parkey ("mcx_"//root_name//k//".pl", "is4_"//root_name//k//".fits", "BPM", add+)
	}
	  }
	}
# Clean up
	wclear ("sky_scale")
	wclear ("masked_frame")
#	wclear ( "surf.section" )

end
