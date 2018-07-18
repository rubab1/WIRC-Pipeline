procedure w_loopavg_sep ( pre, number, chip )

string pre
int number
int chip    

string output  

#	/home/persson/iraf/wirc_scripts/w_loopavg_sep.cl
#	PANIC or RetroCam -->  wirc or fourstar
#
#	Input image is a linearized 'izx_' one.
#
#	Output image is icx_number_cX.fits and is the pclipped 
#	average of the inputs if nloops >= 4. For nloops <= 3
#  	cosmicray cleaning is applied to the difference images.
#
#	chip = the chip to be processed; 0 or 5 means do all 4
#
#	Rev:  30nov2003   SEP   panic
#	Rev:  12mar2004   SEP   panic
#	Rev:  16mar2004   SEP   panic
#	Rev:  22mar2004   SEP   wirc/fourstar
#       Rev:  28sep2004   GF after SEP   CR mask   

begin

	int nloops, k
	string out, onumber, pic, pic_list
	string out_sigma, out_scale
	string msk, msk1

	padindex(number) ; onumber = padindex.output

	for ( k = 1 ; k <= 4 ; k += 1 )	{
	  if ( chip == k || chip == 0 || chip == 5 )  {
	    pic = pre//"_"//onumber//"_c"//k//"_001.fits"
	    if ( access ( pic )) {

# Get the number of frames in the loop
	      keypar(pic,"NLOOPS",silent+)
	      nloops = int(keypar.value)

#  No CR rejection will be done.
#  Expand the picture names into a file called 'pic_list'
	      w_loop_expand ( pic, chip )
	      pic_list = pre//"_"//onumber//"_c"//k//"_list"

#  Create output image name and wclear it. 
	      out = "icx_"//onumber//"_c"//k//".fits"
	      wclear ( out )
	      out_scale = "icx_"//onumber//"_c"//k//"_scale.fits"
	      wclear ( out_scale )
	      out_sigma = "icx_"//onumber//"_c"//k//"_sigma.fits"
	      wclear ( out_sigma )

# I leave CR rejection when nloops > 3 because that will
# be the case of non-science frames.

	      if (nloops < 4) { 
	        imcombine ("@"//pic_list, out, headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="",sigmas="", logfile="STDOUT", combine="average", reject="none", project=no, outtype="real", outlimits="", offsets="none", masktype="none", maskvalue=0., blank=0., scale="none", zero="none", weight="none", statsec="", expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)
	      } else {
	        imcombine ("@"//pic_list, out, headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="",sigmas="", logfile="STDOUT", combine="average", reject="pclip", project=no, outtype="real", outlimits="", offsets="none", masktype="none", maskvalue=0., blank=0., scale="none", zero="none", weight="none", statsec="", expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)
	      }

#  Now combine the masks. These are in .pl format at this point. 

	      msk = "mcx_"//onumber//"_c"//k//".pl"
	      wclear ( msk )
	      if ( access  ( "msk_"//onumber//"_c"//k//"_001.pl" )) {
	        imcopy ( "msk_"//onumber//"_c"//k//"_001.pl", msk, verbose=no )
	      }
	      if (  access  ( "msk_"//onumber//"_c"//k//"_002.pl" )) {
	        imarith ("msk_"//onumber//"_c"//k//"_002.pl","+", msk, msk, title="", divzero=0., hparams="", pixtype="int", calctype="int", verbose=no, noact=no)
	      }
	      if (  access  ( "msk_"//onumber//"_c"//k//"_003.pl" )) {
	        imarith ("msk_"//onumber//"_c"//k//"_003.pl","+", msk, msk, title="", divzero=0., hparams="", pixtype="int", calctype="int", verbose=no, noact=no)
	      }
	      if ( access ( msk )) imreplace (msk, 1, imaginary=0., lower=1, upper=INDEF, radius=0.)
 
#  For loops of many, save the sigma image with scaling turned on; 
#  these are for making bp_masks.  (NOT IMPLEMENTED ACTUALLY)

#	      if ( nloops > 8) {
#	        imcombine ("@"//pic_list, out_scale, headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="", sigmas=out_sigma, logfile="STDOUT", combine="average", reject="none", project=no, outtype="real", outlimits="", offsets="none", masktype="none", maskvalue=0., blank=0., scale="median", zero="none", weight="none", statsec="", expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)
#	      } else {}
	    } else { 
	      wsorry ( pic ) 
	    }
	  }
	}
end

