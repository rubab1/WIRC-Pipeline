procedure chk_frames (inlist)

string inlist  {"",prompt = "List of SN stacks to review (.fits)"}
bool   zscale  {yes,prompt = "Display range of greylevels near median"}
bool   zrange  {yes,prompt = "Display full image intensity range"}
real   z1      {0.,prompt = "Minimum greylevel to be displayed"}
real   z2      {100.,prompt = "Maximum greylevel to be displayed"}
real   contr   {0.25,prompt = "Display contrast"}

struct *list1

begin
	string filelist, fname, comment
	string snname, filter, ans
	real zd1, zd2, zco
	bool zds, zdr

	wclear ("rej_frames.cl")

        print ( "")
        print ( "  >>>>> Hit any key to accept an image, or n to reject it." )
        print ( "")
        print ( "A comment keyword will be written in the image header:" )
        print ( "")
        print ( "RAW_COMM=GOOD, or BAD.")
        print ( "")
        print ( "A list of rejected images, rej_frames.cl, will be created.")

	filelist = inlist
        list1 = ""; list1 = filelist
        while (fscan (list1, fname) != EOF)     {

	if ( access ( fname ) ) {

# Initialize some display parameters
	   zds = zscale
	   zdr = zrange
	   zd1 = z1
	   zd2 = z2
	   zco = contr

# Read SN name from header to help identify frame:
	   keypar (fname, "object", silent+)
	   snname = keypar.value 
	   keypar (fname, "filter", silent+)
	   filter = keypar.value 
	
	   print ( "" )
	   print ( " ---------------------------------------------" )
	   print ( " OBJ NAME:    ",snname,";     FILTER:  ",filter )
	   print ( " ---------------------------------------------" )
	   print ( "" )

# Display image:

	   display (fname, 1, bpmask="BPM", bpdisplay="none", bpcolors="green", overlay="", ocolors="red", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=no, zscale=zds, contrast=zco, zrange=zdr, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0,z1=zd1, z2=zd2, ztrans="linear", lutfile="")

#	  imexa(fname, 1)

	   print ( "" )
	   print ( " Hit n to reject image, or any other key to accept it." )
	   print ( "" )

	ans=""
	scan (ans)
        comment=""

	if (ans == 'n')  {
	   comment = "BAD"
	   print ("imdel	",fname, >> "rej_frames.cl")
	}
	else   {
	   comment = "GOOD"
	}

	hedit (fname, "raw_comm", comment, add=yes, addonly=no, delete=no, verify=no, show=yes, update=yes)

	}
	else {
	    wsorry ( fname )    
	}

	}	# close main while loop 

end
