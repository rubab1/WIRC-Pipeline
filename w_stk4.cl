procedure w_stk4 ( pre, p1, p2, chip )

# This script should be equivalent of p_stk1 for PANIC/RetroCAM

string pre  {"idf", prompt = "Image file prefix"}
int    p1   {prompt = "First frame"}
int    p2   {prompt = "Last frame"}
int chip   {prompt="Chip number"}

struct *lista

begin

	int i, k, fr1, fr2
	string sp1, sp2, biglist, thefile, reffile, refold, output, root_name

	i=0
	fr1 = p1
	fr2 = p2

	for ( k = 1 ; k <= 4 ; k += 1 ) {

	  if ( k == chip || chip == 5 || chip == 0 ) {

	wclear ("comblist")

	w_pre_list ( pre, p1, p2, k )
	biglist = pre//"_c"//k//"_list"

  	lista = "" ; lista = biglist
  	while (fscan (lista,thefile) !=EOF) {

  	  keypar(thefile,"referenc")
	  reffile = str(keypar.value)
	  root_name = substr (thefile,5,9)
	  fr2 = int (root_name)
	  root_name = substr (thefile,5,12)

	  if (i==0) {

   	    print (substr(thefile,1,12),>> "comblist")

   	    refold=reffile
   	    i = i+1

# If reffile changes, combine the files in comblist to this point.
	  } else if (reffile==refold) {

	    print (substr(thefile,1,12),>> "comblist")

      	    refold=reffile 

	  } else {

            padindex(fr1); sp1 = padindex.output
	    padindex(fr2); sp2 = padindex.output

	    output = "stk_"//pre//"_"//sp1//"_"//sp2//"_c"//k

	    w_avecomb ( "comblist", output)

   	    wclear("comblist")

# begin new lists starting with current file

   	    print (substr(thefile,1,12),>> "comblist")

	    fr1 = fr2 + 1
   	  } 

	}

#  call avecomb for the last set of frames, since they did not
#  trigger reffile != oldref

        padindex(fr1); sp1 = padindex.output
	padindex(fr2); sp2 = padindex.output

	output = "stk_"//pre//"_"//sp1//"_"//sp2//"_c"//k

	w_avecomb ( "comblist", output)

	wclear ("comblist")

lista = ""

}

}

end
