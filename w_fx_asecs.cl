procedure w_fx_asecs (p1, p2, chip)

int p1
int p2
int chip
struct *list1

#	Used to repair erroneous asecs, dsecs values in idf, isx 
#	frame headers

begin

	string filelist, isx_frame, idf_frame, onumber, root_name
	string fname, imlist, raw_frame, fid_frame
	int i, k, c_fid
	real asecs, asecs0, dsecs, dsecs0
	real x, y, xfid, yfid, obj_lev, sky_lev, ratio

# Get c_fid chip number (GIVEN AS INPUT)
	c_fid = chip

	padindex(p1) ; onumber = padindex.output
#	for ( k = 1 ; k <= 4 ; k += 1 )	{
#	  idf_frame = "idf_"//onumber//"_c"//k
#	  if ( access ( idf_frame//".fits") ) {
#	    keypar(idf_frame,"XFID",silent+)
#	    if(keypar.found) c_fid = k
#	  }
#	}

# Now only need to process chip 'c_fid' frames

# If "isx_" frames do not exist, create them

        isx_frame = "isx_"//onumber//"_c"//c_fid
        idf_frame = "idf_"//onumber//"_c"//c_fid
        if ( !access ( isx_frame//".fits" )) {
	  if ( access ( idf_frame//".fits" )) {
	    w_pre_list ( "idf", p1, p2, c_fid )
	    imlist = "idf_c"//c_fid//"_list"
	  } else {
	    w_loops_combine ( "irx", p1, p2, c_fid )
	    w_pre_list ( "icx", p1, p2, c_fid )
	    imlist = "icx_c"//c_fid//"_list"
	  }
          wclear ( "sky" )
	  imcombine ("@"//imlist, "sky", headers="", bpmasks="", rejmasks="", nrejmasks="", expmasks="", sigmas="", logfile="STDOUT", combine="median", reject="pclip", project=no, outtype="real", outlimits="", offsets="none", masktype="none", maskvalue=0., blank=0., scale="mode", zero="none", weight="none", statsec="[20:990,20:990]", expname="", lthreshold=INDEF, hthreshold=INDEF, nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="0.", gain="1.", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0.)

	  w_store ( "sky" )
	  keypar ( "sky", "FRMEDIAN", silent+ )
	  sky_lev = real (keypar.value)
	  list1 = "" ; list1 = imlist
	  while (fscan (list1, fname) !=EOF) {
	    root_name = substr(fname,5,12)
	    isx_frame = "isx_"//root_name
	    w_store ( fname )
	    keypar (fname, "FRMEDIAN", silent+ )
	    obj_lev = real (keypar.value)
	    ratio = obj_lev / sky_lev
	    wclear ( isx_frame )
	    wclear ( "dummy" )
	    imarith ("sky", "*", ratio, "dummy", title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
	    imarith (fname, "-", "dummy", isx_frame, title="", divzero=0., hparams="", pixtype="real", calctype="real", verbose=no, noact=no)
	    wclear ( "dummy" )
	  }
	  wclear ( imlist )
	  wclear ( "sky" )
	}

# Get starting asecs, dsecs values out - these are asecs0 and dsecs0

	raw_frame = "irx_"//onumber//"_c"//c_fid//"_001"
	isx_frame = "isx_"//onumber//"_c"//c_fid

	if ( access (raw_frame//".fits")) {
	  fid_frame = raw_frame
	} else if ( access (idf_frame//".fits")) {
	  fid_frame = idf_frame
	}
	keypar(fid_frame,"XFID",silent+)
	if(keypar.found) xfid = real(keypar.value)
	keypar(fid_frame,"YFID",silent+)
	if(keypar.found) yfid = real(keypar.value)
	keypar(fid_frame,"asecs",silent+)
	asecs0 = real(keypar.value)
	keypar(fid_frame,"dsecs",silent+)
	dsecs0 = real(keypar.value)

        wclear ("init.dat") 
	print ( xfid, "  ", yfid, > "init.dat" )
	display ( isx_frame, 1)
        tvmark (1, coords="init.dat", mark="circle", radii="15",color=205)

	!sleep 2

	w_pre_list ( "isx", p1, p2, c_fid )	
	filelist = "isx_c"//c_fid//"_list"
	i = 0
	list1 = "" ; list1 = filelist
	while ( fscan ( list1, isx_frame ) != EOF ) {
	  i += 1
	  onumber = substr(isx_frame,5,9)
          raw_frame = "irx_"//onumber//"_c"//c_fid//"_001"
          idf_frame = "idf_"//onumber//"_c"//c_fid
	  if ( i <= 1 ) {
            wclear ("init.dat") ; wclear ("slist")
	    display ( isx_frame, 1)

#  Give the option of choosing a new fiducial star
	    print ( "")
            print ( "  >>>>> Identify a star  ( a  q )  " )
            print ( "")

	    imexamine ( isx_frame,1,keeplog+,logfile='slist' )
            !egrep -v '#' slist | awk '{print $1, $2 }' > init.dat
	    type ("init.dat") | scan ( xfid, yfid )

	    if ( access (raw_frame//".fits" )) {
              parkey ( xfid, raw_frame, "XFID", add+)
              parkey ( yfid, raw_frame, "YFID", add+)
	    }
            parkey ( xfid, isx_frame, "XFID", add+)
            parkey ( yfid, isx_frame, "YFID", add+)
	    if ( access (idf_frame//".fits" )) {
	      parkey ( xfid, idf_frame, "XFID", add+)
	      parkey ( yfid, idf_frame, "YFID", add+)
	    }
	  } else {
	    wclear ("init.dat") ; wclear ("slist")
	    if ( access ( isx_frame//".fits" ))	{
	      display ( isx_frame, 1)
	      print ( "")
              print ( "  >>>>> Identify the same star  ( a  q )  " )
              print ( "")
	      imexamine ( isx_frame,1,keeplog+,logfile='slist' )
              !egrep -v '#' slist | awk '{print $1, $2 }' > init.dat
	      type ("init.dat") | scan ( x, y )
	      asecs = asecs0 + (x - xfid)*0.196
	      dsecs = dsecs0 - (y - yfid)*0.196
	      print ( isx_frame,"  ", asecs, "  ", dsecs )

	      if ( access (raw_frame//".fits" )) {
                parkey ( asecs, raw_frame, "ASECS", add+)
                parkey ( dsecs, raw_frame, "DSECS", add+)
	      }
              parkey ( asecs, isx_frame, "ASECS", add+)
              parkey ( dsecs, isx_frame, "DSECS", add+)
	      if ( access (idf_frame//".fits" )) {
	        parkey ( asecs, idf_frame, "ASECS", add+)
	        parkey ( dsecs, idf_frame, "DSECS", add+)
	      }
	    }
	  }
	}

end
