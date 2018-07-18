procedure w_reset (filelist)

string	  filelist	{prompt="List of input files"}
struct	  *list1, *list2

begin

	string filename, dither_name, old_name, root_name, subroot
	real xshift, yshift, xref, yref, x3, y3
	int i

#       Initialize file lists

        old_name = ""
        root_name = ""
        xref = 0.0
        yref = 0.0
        x3 = 0.0
        y3 = 0.0
        i = 0
  
# 	Put images into a list file

	list1 = "" ; list1 = filelist
	while (fscan (list1,filename) != EOF)  {

#	Pull out xoff and yoff and reference file name

	   keypar (filename, "referenc")
	   dither_name = str(keypar.value)

	   keypar (filename, "xoff")
	   xshift = real(keypar.value)

	   keypar (filename, "yoff")
	   yshift = real(keypar.value)

	   if (i == 0) {
	      xref = 0.0
	      yref = 0.0
	      old_name = dither_name
	   } else {}

	   if (dither_name == old_name) { 

	      if (xshift <= xref) xref = xshift
	      if (yshift <= yref) yref = yshift
	      i = i + 1
	   } else {

	      list2 = "" ; list2 = filelist
	      while (fscan (list2,filename) != EOF)  {

#	Get file root names

	         root_name = substr(filename,1,12)
	         subroot = substr(filename,5,12)

#	Pull out xoff and yoff and reference file name

	         keypar (filename, "referenc")
	         dither_name = str(keypar.value)

	         keypar (filename, "xoff")
	         xshift = real(keypar.value)

	         keypar (filename, "yoff")
	         yshift = real(keypar.value)

	         if (dither_name == old_name) {
	            x3 = xshift - xref
	            y3 = yshift - yref

	            parkey (x3, root_name, "XOFF2", add+)
	            parkey (y3, root_name, "YOFF2", add+)
	            parkey (x3, "idf_"//subroot, "XOFF2", add+)
	            parkey (y3, "idf_"//subroot, "YOFF2", add+) 
	         } else {}

	      } # Close second while loop

	      old_name = dither_name
	      i = 0

	   }  # Close else for dither_name neq old_name

	}   # Close first while loop

	list1 = "" ; list1 = filelist
	while (fscan (list1,filename) != EOF)  {

#	Get root name

	   root_name = substr(filename,1,12)
	   subroot = substr(filename,5,12)

#	Pull out xoff and yoff and reference file name

	   keypar (filename, "referenc")
	   dither_name = str(keypar.value)

	   keypar (filename, "xoff")
	   xshift = real(keypar.value)

	   keypar (filename, "yoff")
	   yshift = real(keypar.value)

	   if (dither_name == old_name) {
	      x3 = xshift - xref
	      y3 = yshift - yref
	      parkey (x3, root_name, "XOFF2", add+)
	      parkey (y3, root_name, "YOFF2", add+)
	      parkey (x3, "idf_"//subroot, "XOFF2", add+)
	      parkey (y3, "idf_"//subroot, "YOFF2", add+)
	   } else {}
	}

end
