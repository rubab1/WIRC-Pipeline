procedure mk_crdlist ( sixcols )

string sixcols
struct *list1

#  Takes the pairs file 'crd_pairs', which has
#  six columns, and compresses columns 3-4 and 
#  5-6 to one list of pairs with no repetitions.
#  The output file is 'crdlist'

begin
	int p1, p2, p1t, p2t, chip

	p1t = 0 ; p2t = 0

 	wclear("dummy") ; wclear("dum3") ; wclear("dum5")
	wclear ("dum35") ; wclear ("crdlist")

	copy (sixcols, "dummy", ver-)

!awk '{print $3,$4}' dummy > dum3
!awk '{print $5,$6}' dummy > dum5
!cat dum3 dum5 | sort -n > dum35

	list1 = "" ; list1 = "dum35"
	while ( fscan ( list1, p1, p2 ) != EOF )  {

	  if ( p1 != p1t && p2 != p2t ) {
		for ( chip = 1 ; chip <= 4 ; chip += 1 )	{
	           print ( p1,"   ",p2,"   ",chip, >> "crdlist")
		}
	   p1t = p1 ; p2t = p2
					}
						  }

 	wclear("dummy") ; wclear("dum3") ; wclear("dum5")
	wclear ("dum35")	

end


