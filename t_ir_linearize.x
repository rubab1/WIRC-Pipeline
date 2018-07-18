include <imhdr.h>
include	<error.h>


# T_IR_LINEARIZE -- Corrects Panic/Retrocam images for non linearity.

procedure t_ir_linearize ()

char	cam                     # camera (Panic or Retrocam)
pointer	inlist, outlist		# input and output image lists
real	td			# delay time
real	tf			# frame readout time
real	ta			# acquisition time
real	c1, c2, c3		# coefficients of correction
real	linthresh               # threshold for correction

pointer	imin, imout
pointer	input, output, orig, temp
pointer	sp

int	strlen()
int	imtgetim(), imtlen()
real	clgetr()
pointer	immap(), imtopenp()

begin
	# Get parameters
	inlist  = imtopenp ("input")
	outlist = imtopenp ("output")
	call clgstr ("camera", cam, SZ_LINE)

	# Check that the input and output image lists have the
	# same number of images. Abort if that's not the case.
	if (imtlen (inlist) != imtlen (outlist)) {
	    call imtclose (inlist)
	    call imtclose (outlist)
	    call error (1, "Input and output image lists don't match")
	}

	# Allocate string space
	call smark  (sp)
	call salloc (input,  SZ_FNAME, TY_CHAR)
	call salloc (output, SZ_FNAME, TY_CHAR)
	call salloc (orig,   SZ_FNAME, TY_CHAR)
	call salloc (temp,   SZ_FNAME, TY_CHAR)

	# Assign the correction coefficients according to the camera used.
	# Also set delay time, frame readout time, acquisition time, and 
        # threshold values.
	# [NB. Values for RetroCam have yet to be determined!]
        if (cam == 'r' || cam == 'R') {
	    c1 = 4.291443e+01
	    c2 = 9.752524e-01
	    c3 = 1.962545e-06
            td = 0.010
            tf = 2.0
            ta = 0.085
            linthresh = 8000.
#	    call printf ("RetroCam:\n")
        }
        else if (cam == 'w' || cam == 'W') {
	    c1 = 4.291443e+01
	    c2 = 9.752524e-01
	    c3 = 1.962545e-06
            td = 0.010
            tf = 2.0
            ta = 0.085
            linthresh = 8000.
#	    call printf ("WIRC:\n")
        }
        else if (cam == 'p' || cam == 'P') {
	    c1 = 4.291443e+01
	    c2 = 9.752524e-01
	    c3 = 1.962545e-06
            td = 0.010
            tf = 2.0
            ta = 0.085
            linthresh = 8000.
#	    call printf ("Panic:\n")
        } else {
            call error (1, "Camera not defined.")
        }

	# Loop over all images in the input and output lists
	while ((imtgetim (inlist, Memc[input], SZ_FNAME) != EOF) &&
	       (imtgetim (outlist, Memc[output], SZ_FNAME) != EOF)) {

	    # Generate temporary output image name to allow for
	    # input and output images having the same name
	    call xt_mkimtemp (Memc[input], Memc[output], Memc[orig], SZ_FNAME)

	    # Open input and output images. The output image does not exist
	    # already so it is opened as a new copy of the input image.
	    iferr (imin = immap (Memc[input], READ_ONLY, 0)) {
	        call erract (EA_WARN)
	        next
    	    }
	    iferr (imout = immap (Memc[output], NEW_COPY, imin)) {
	        call imunmap (imin)
	        call erract (EA_WARN)
	        next
	    }
	    IM_PIXTYPE (imout) = TY_SHORT

	    # Perform the linear correction.
	    call ir_correct (imin, imout, c1, c2, c3, td, tf, ta, linthresh)

	    # Close images
	    call imunmap (imin)
	    call imunmap (imout)

	    # Replace output image with the temporary image. This is a
	    # noop if the input and output images have different names
	    call xt_delimtemp (Memc[output], Memc[orig])
	}

	# Free memory and close image lists
	call imtclose (inlist)
	call imtclose (outlist)
end


# IR_CORRECT -- Corrects an IR imager frame for non-linearity using an
# algorithm from Paul Martini

procedure ir_correct (imin, imout, c1, c2, c3, td, tf, ta, linthresh)

pointer	imin			# input image pointer
pointer	imout			# output image pointer
real	c1, c2, c3		# coefficients for correction
real    td			# delay time
real    tf			# frame readout time
real    ta			# acquisition time
real    linthresh		# threshold for correction

real	exp    			# exposure time
real    reads_ep		# number of endpoint reads
real	pre_ep			# number of pre-endpoint reads (= 1)
real	t_read			# total effective frame readout time
real	t_pre_ep		# pre-endpoint readout time
real	delta			# overhead due to pre-reads and reads
real	p			# fraction of total time due to readout
char	readmode		# readout mode

int	col, ncols
real	z2, z3, z4, z5
long	v1[IM_MAXDIM], v2[IM_MAXDIM]
pointer	inbuf, outbuf

int	imgeti()
int	imgnlr(), impnlr()
real	imgetr()

begin
        pre_ep = 1.

	# Get exposure time from image header
        exp = imgetr (imin, "EXPTIME")
#	call printf ("  Linearizing: %21s\n")
#	call pargstr (imin)
#	call printf ("  EXPTIME: %f\n")
#	call pargr (exp)

	# Get number of end-point reads from image header
        call imgstr (imin, "READMODE", readmode, SZ_LINE)
        if (readmode == 'Do') reads_ep = 1.
        if (readmode == 'Qu') reads_ep = 2.
        if (readmode == 'Se') reads_ep = 3.
        if (readmode == 'Oc') reads_ep = 4.
#	call printf ("  READMODE: %10s   reads_ep: %f\n")
	call pargstr (readmode)
	call pargr (reads_ep)

	# Calculate total effective readout time
	t_pre_ep = pre_ep * (tf + td)
        t_read = reads_ep * (tf + td + ta)
#	call printf ("  t_read: %f\n")
	call pargr (t_read)

	# Set fraction of total time due to readout
	delta = t_pre_ep + t_read / 2.
        p = delta / (delta + exp)
#	call printf ("  delta: %f   p: %f\n")
	call pargr (delta)
	call pargr (p)

	# Initiliaze counters for line i/o
	call amovkl (long(1), v1, IM_MAXDIM)
	call amovkl (long(1), v2, IM_MAXDIM)

	# Number of pixels per line
	ncols = imgeti (imin, "i_naxis1")

	# Loop over image lines
	while ((imgnlr (imin, inbuf, v1) != EOF) &&
	       (impnlr (imout, outbuf, v2) != EOF)) {
	    do col = 1, ncols {
		z2 = Memr[inbuf+col-1] * (1. + p)
 		z4 = Memr[inbuf+col-1] * p
 		if (z2 <= linthresh) {
 			z3 = z2
 			z5 = z4
 		}
 		else if (z4 <= linthresh) {
 			z3 = c1 + c2*z2 + c3*z2*z2
 			z5 = z4
 		}
 		else {
 			z3 = c1 + c2*z2 + c3*z2*z2
 			z5 = c1 + c2*z4 + c3*z4*z4
 		}
 		Memr[outbuf+col-1] = z3 - z5
	    }
	}
end
