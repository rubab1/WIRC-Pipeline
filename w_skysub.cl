procedure w_skysub ( p1, p2, chip )

int p1
int p2
int chip
struct	*list1, *list2, *lista


begin

string  sp1, sp2, filelist, obj_mask, fname, root_name, skyname, root_sky, stsect
real    xshift, yshift, sky_lev, obj_lev, scale
int k

stsect = "[20:990,20:990]"

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

padindex(p1) ; sp1=padindex.output
padindex(p2) ; sp2=padindex.output

# obj_mask = "mask_isx_"//sp1//"_c"//k//".pl"
obj_mask = "mask_isx_"//sp1//"_"//sp2//"_c"//k//".pl"

w_pre_list ( "idf", p1, p2, k )
filelist = "idf_c"//k//"_list"

list1 = "" ; list1 = filelist
while (fscan (list1,fname) !=EOF) {

  root_name = substr(fname,5,12)

  keypar (fname, "xoff2")
  xshift = real(keypar.value) * -1.
  keypar (fname, "yoff2")
  yshift = real(keypar.value) * -1.

# Copy object mask file (mask_isx) into mask template to create mask of 
# correct size (mask2) and update header in sky frames.

  wclear ( "mask2_"//root_name//".pl" )
  imshift (obj_mask, "mask2_"//root_name//".pl", xshift, yshift, shifts_file="", interp_type="linear", boundary_typ="constant", constant=1)
  imcopy ("mask2_"//root_name//".pl"//"[1:1024,1:1024]", "mask2_"//root_name//".pl", verbose-)

#  Now add in the badpixel mask = mcx_NNNNN_ck.pl, 
  imarith ("mask2_"//root_name//".pl", "+", "mcx_"//root_name//".pl", "mask2_"//root_name//".pl", title="", divzero=0., hparams="", pixtype="", calctype="", verbose=no, noact=no)
  imreplace ("mask2_"//root_name//".pl", 1, imaginary=0., lower=1.01, upper=INDEF, radius=0.)
  parkey("mask2_"//root_name//".pl", fname, "BPM",add+)

}   # close while over files in input list - all masks are now done

#  Go through p1,p2,chip list to make 'is2' sky-subtracted frames
#  Use all but the one at the same dither position.

list1 = "" ; list1 = filelist
while ( fscan ( list1, fname ) != EOF )  {

  root_name = substr(fname,5,12)

  wclear ("sky_list")
  list2 = ""; list2 = filelist
  while (fscan (list2,skyname) !=EOF) {

    root_sky = substr(skyname,5,12)
    if (skyname != fname ) {
      print ("idf_"//root_sky//".fits", >> "sky_list")
    }
  }  # close sky_list while

  wclear ("sky_"//root_name)

# Combine frames to make sky image

  imcombine ("@sky_list", "sky_"//root_name, headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="", sigmas="", logfile="STDOUT", combine="median", reject="pclip", project=no, outtype="real", outlimits="", offsets="", masktype="goodvalue", maskvalue=0., blank=-999., scale="mode", zero="none", weight="none", statsec=stsect, expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)

  w_store ( "sky_"//root_name )
  keypar ( "sky_"//root_name, "FRMEDIAN", silent+ )
  sky_lev = real(keypar.value)
  imreplace ( "sky_"//root_name, sky_lev, imagina=0., lower=INDEF, upper=-990.,radius=0.)

# Create a masked frame to do statistics on.

  wclear ("masked_frame")
  imcalc ( fname//",mask2_"//root_name//".pl", "masked_frame", "if im2 .eq. 1 then -999. else im1", pixtype="old", nullval=-999.,verbose- )
  w_store ( "masked_frame" )
  keypar ( "masked_frame", "FRMEDIAN", silent+ )
  obj_lev = real(keypar.value)
  scale = obj_lev / sky_lev

  wclear ("dummy")
  wclear ("is2_"//root_name)

  imarith ("sky_"//root_name//".fits", "*", scale, "dummy", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

  imreplace ("dummy", obj_lev, imaginary=0., lower=INDEF, upper=-500., radius=0.)
  imarith (fname, "-", "dummy", "is2_"//root_name//".fits", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)

# No offset level applied

  w_store ( "is2_"//root_name )
  parkey ( obj_lev, "is2_"//root_name, "SKYLEV", add+ )

  display ("sky_"//root_name//".fits", 2, bpmask="", bpdisplay="none", bpcolors="red", overlay="", ocolors="green", erase=yes, border_erase=yes, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=INDEF, z2=INDEF, ztrans="linear", lutfile="")

  display ("is2_"//root_name//".fits", 1, bpmask="", bpdisplay="none", bpcolors="red", overlay="", ocolors="green", erase=yes, border_erase=yes, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=INDEF, z2=INDEF, ztrans="linear", lutfile="")

}   # close main while

#  Put correct mask back into idf and is2 file headers

list1 = "" ; list1 = filelist
while (fscan (list1,fname) !=EOF) {

  root_name = substr(fname,5,12)
  parkey ("mcx_"//root_name//".pl", "is2_"//root_name//".fits", "BPM", add+)
  parkey ("mcx_"//root_name//".pl", fname//".fits", "BPM", add+)
  wclear ("mask2_"//root_name//".pl")
}
	  }
	}
# Clean up
wclear ("sky_list")
wclear ("idf_c"//k//"_list")
wclear ("sky_scale")
wclear ("masked_frame")
wclear ("dummy")


end
