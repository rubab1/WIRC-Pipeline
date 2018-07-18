procedure addsnpos (inlist)

string inlist  {"",prompt = "Input list name (frame, XSN, YSN)"}
struct *list1

begin
	string filelist, fname
	real   x, y

	filelist = inlist
        list1 = ""; list1 = filelist
        while (fscan (list1, fname, x, y) != EOF) {

	  if ( access ( fname ) ) {
	    hedit ( fname, "XSN", x, verify-, update+, add+, addonly+, del-)
	    hedit ( fname, "YSN", y, verify-, update+, add+, addonly+, del-)
	  } 
	  else {
	    wsorry ( fname )    
	  }
	} 

end

