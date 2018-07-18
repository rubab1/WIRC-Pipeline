procedure w_offreset (filelist)

string	  filelist
struct	  *list1

#  Written by P McCarthy and J Wilson, 8/21/99
#  Renormalize offsets to be positive
#
#  SEP 02may2004: Called by 'w_dither1', expects a list of 
#  'isx' frames for chip 'cfid', the one having the  
#  original fiducial star. 
#
#  GF: A copy of w_snreset. Added is3 frames.

begin

	string filename, idf_name, isx_name, is2_name, is3_name
	real xref, xoff, xoff2,  yref, yoff, yoff2
	int i, k

        xref = 1000. ; yref = 1000.

# Get x and y offsets; select minimum value

	list1 = "" ; list1 = filelist
	while (fscan (list1,filename) != EOF) {
          keypar (filename, "XOFF")
          xoff = real(keypar.value)
          keypar (filename, "YOFF")
          yoff = real(keypar.value)
	  if ( xoff <= xref ) xref = xoff
	  if ( yoff <= yref ) yref = yoff
	}

	list1 = "" ; list1 = filelist
	while (fscan (list1,filename) != EOF) {
          keypar (filename, "XOFF")
          xoff = real(keypar.value)
          keypar (filename, "YOFF")
          yoff = real(keypar.value)
	  xoff2 = xoff - xref
	  yoff2 = yoff - yref

# Write the XOFF2,YOFF2 offsets into all 4 chip headers
# if the frames exist. This is for constructing stacks
# of the "sky" frames associated with the SN frames. 

	  for ( k = 1 ; k <= 4 ; k += 1 ) {
	    idf_name  = "idf_"//substr(filename,5,11)//k
	    isx_name  = "isx_"//substr(filename,5,11)//k
	    is2_name  = "is2_"//substr(filename,5,11)//k
	    is3_name  = "is3_"//substr(filename,5,11)//k
	    if ( access ( idf_name//".fits" )) {
	      parkey(xoff2,idf_name,"XOFF2",add+)
	      parkey(yoff2,idf_name,"YOFF2",add+)
	    }
	    if ( access ( isx_name//".fits" )) {
	      parkey(xoff2,isx_name,"XOFF2",add+)
	      parkey(yoff2,isx_name,"YOFF2",add+)
	    }
	    if ( access ( is2_name//".fits" )){
	      parkey(xoff2,is2_name,"XOFF2",add+)
	      parkey(yoff2,is2_name,"YOFF2",add+)
	    }
	    if ( access ( is3_name//".fits" )){
	      parkey(xoff2,is3_name,"XOFF2",add+)
	      parkey(yoff2,is3_name,"YOFF2",add+)
	    }
	  }
	}
end
