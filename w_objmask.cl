procedure w_objmask (p1, p2,chip)

# This script should be equivalent of p_objmask for PANIC/RetroCAM

int p1	{prompt = "First frame"}
int p2	{prompt = "Last frame"}
int chip   {prompt="Chip number"}

struct	  *list1

begin

	int fr1, fr2, i, k, nx1, nx2, ny1, ny2, secx1, secx2, secy1, secy2
	string pre, sp1, sp2, filelist, fname, dither_name
	string old_name, root_name, mask_sect

	i = 0
	fr1 = p1
	fr2 = p2

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

	padindex (p1); sp1 = padindex.output

	if ( access ( "is2_"//sp1//"_c"//k//".fits" )) {

	  w_pre_list ( "is2", p1, p2, k )	
	  filelist = "is2_c"//k//"_list"
	  pre = "is2"

	} else {

	  w_pre_list ( "isx", p1, p2, k )
	  filelist = "isx_c"//k//"_list"
	  pre = "isx"
	  
	}

	list1 = "" ; list1 = filelist
	while (fscan (list1,fname) != EOF)  {

           keypar (fname,"referenc")
           dither_name = str(keypar.value)
	   root_name = substr (fname,5,9)
	   fr2 = int(root_name)
	   padindex (fr2); sp2 = padindex.output
	   root_name = substr (fname,5,12)

	   if ( i == 0 ) {

              old_name = dither_name
	      i = i+1

           } else if (dither_name != old_name) { 

	      hselect ( "stk_"//pre//"_"//sp1//"_"//sp2//"_c"//k, "NAXIS1,NAXIS2", yes ) | scan (nx1,ny1)
	      hselect ( "stk_"//pre//"_"//sp1//"_"//sp2//"_c"//k//"_tr", "NAXIS1,NAXIS2", yes ) | scan (nx2,ny2)

	      secx1 = int ( ( nx1 - nx2 ) / 2 )
	      secx2 = nx1 - secx1
	      secy1 = int ( ( ny1 - ny2 ) / 2 )
	      secy2 = ny1 - secy1

	      mask_sect = "["//secx1//":"//secx2//","//secy1//":"//secy2//"]"

	      display ( "stk_"//pre//"_"//sp1//"_"//sp2//"_c"//k, 1, bpmask="", bpdisplay="none", bpcolors="red", overlay="", ocolors="green", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=INDEF, z2=INDEF, ztrans="linear", lutfile="")

	      wclear ( "mask1.pl" )

	      makemask ( "stk_"//pre//"_"//sp1//"_"//sp2//"_c"//k, "mask1", hinlist="", subsample=3, checklimits=yes, zmin=-500., zmax=38000., filtsize=201, nsmooth=3, statsec=mask_sect, nsigrej=3., maxiter=20, threshtype="nsigma", nsigthresh=2.5, constthresh=0., negthresh=no, ngrow=0, verbose=yes, imglist="", outimglist="", hdrimglist="")

              wclear ("mask_"//pre//"_"//sp1//"_"//sp2//"_c"//k//".pl")

	      imcopy ("mask1.pl", "mask_"//pre//"_"//sp1//"_"//sp2//"_c"//k//".pl", ver-)

	      display ("mask_"//pre//"_"//sp1//"_"//sp2//"_c"//k//".pl", 2, bpmask="", bpdisplay="none", bpcolors="red", overlay="", ocolors="green", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=INDEF, z2=INDEF, ztrans="linear", lutfile="")

	      wclear ( "mask1.pl" )

	      fr1 = fr2 + 1

              old_name = dither_name
	   }
	}

	hselect (  "stk_"//pre//"_"//sp1//"_"//sp2//"_c"//k, "NAXIS1,NAXIS2", yes ) | scan (nx1,ny1)
	hselect (  "stk_"//pre//"_"//sp1//"_"//sp2//"_c"//k//"_tr", "NAXIS1,NAXIS2", yes ) | scan (nx2,ny2)

	secx1 = int ( ( nx1 - nx2 ) / 2 )
	secx2 = nx1 - secx1
	secy1 = int ( ( ny1 - ny2 ) / 2 )
	secy2 = ny1 - secy1

	mask_sect = "["//secx1//":"//secx2//","//secy1//":"//secy2//"]"

	display  ("stk_"//pre//"_"//sp1//"_"//sp2//"_c"//k, 1, bpmask="", bpdisplay="none", bpcolors="red", overlay="", ocolors="green", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=INDEF, z2=INDEF, ztrans="linear", lutfile="")

	wclear ( "mask1.pl" )

	makemask ( "stk_"//pre//"_"//sp1//"_"//sp2//"_c"//k, "mask1", hinlist="", subsample=3, checklimits=yes, zmin=-500., zmax=38000., filtsize=201, nsmooth=3, statsec=mask_sect, nsigrej=3., maxiter=20, threshtype="nsigma", nsigthresh=2.5, constthresh=0., negthresh=no, ngrow=0, verbose=yes, imglist="", outimglist="", hdrimglist="")

        wclear ("mask_"//pre//"_"//sp1//"_"//sp2//"_c"//k//".pl")

	imcopy ("mask1.pl", "mask_"//pre//"_"//sp1//"_"//sp2//"_c"//k//".pl", ver-)

	display ("mask_"//pre//"_"//sp1//"_"//sp2//"_c"//k//".pl", 2, bpmask="", bpdisplay="none", bpcolors="red", overlay="", ocolors="green", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=0.25, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0, z1=INDEF, z2=INDEF, ztrans="linear", lutfile="")

	wclear ( "mask1.pl" )

	  }
	}
end
