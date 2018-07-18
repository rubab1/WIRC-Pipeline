procedure w_mfid ( flag, autman )

string flag	{prompt="Process flag"}
string autman	{"aut",enum="aut|man",prompt="Automatic or manual star selection?"}
struct *list1

#  Multiple 'w_fid' operates on frames 
#  in the lists of pairs files specified by 'flag'.
#  The decoding of 'flag' is as in 'w_1go.cl'.

begin

	int nf, i, p1, p2, p3, p4, p5, p6, chip
	bool unc, alt, std, crd
	string onumber, date

	unc = no ; alt = no ; std = no ; crd = no
	nf = strlen(flag)
	for ( i = 1; i <= nf; i += 1 ) {
          if ( substr(flag,i,i) == "u") unc = yes 
          if ( substr(flag,i,i) == "a") alt = yes 
          if ( substr(flag,i,i) == "s") std = yes
	  if ( substr(flag,i,i) == "c") crd = yes
	}

	w_load

#  ID stars in list of uncrowded pairs

	if(unc)	{
	  if ( access ( "unc_pairs" )) {
	    list1 = "" ; list1 = "unc_pairs"
	    while ( fscan ( list1, p1, p2, chip ) != EOF ) {
	      w_fid ( p1, p2, chip, autman )
	    }
	  } else {
	    wsorry ( "unc_pairs") 
	  }
	} else {}

#  ID stars in list of crowded pairs
#  First off-source

	if(crd)	{
	  if ( access ( "crd_pairs" ))	{

	mk_crdlist ("crd_pairs")

	list1 = "" ; list1 = "crdlist"
	while ( fscan ( list1, p1, p2, chip ) != EOF )   {

	    w_fid ( p1, p2, chip, autman ) 
						   }
#  Now on-source
#  Here we call a variant of 'w_fid' assuming that the
#  on-source frame is extremely crowded. The sky frames stored 
#  in the off-source sequence above are averaged and used.  

	list1 = "" ; list1 = "crd_pairs"
	while ( fscan ( list1, p1, p2, p3, p4, p5, p6, chip ) != EOF )   {

	    w_fid_c ( p1, p2, p3, p4, p5, p6, chip, autman )
						   }
					} else {
	    wsorry ( "crd_pairs") 
						}
		} else {}

#  Now alternating pairs
#  'w_fid_a' assumes that the p3,p4-same chip sky exists.
#  It runs after 'w_fid' has operated on the (alternating) 
#  sky frames.

	if(alt) {
	  if ( access ( "alt_pairs" )) {
	    list1 = "" ; list1 = "alt_pairs"
	    while ( fscan ( list1, p1, p2, p3, p4, chip ) != EOF ) {
	      w_fid   ( p3, p4, chip, autman )
	      w_fid_a ( p1, p2, p3, p4, chip, autman )
	    }
	  } else {
	    wsorry ( "alt_pairs") 
	  }
	} else {}

#  Now standard stars

	if(std)	{
	  if ( access ( "std_pairs" ))	{
	    list1 = "" ; list1 = "std_pairs"
	    while ( fscan ( list1, p1, p2, p3, p4, chip ) != EOF ) {
	      w_fid ( p1, p2, chip, autman )
	    }
	  } else {
	    wsorry ( "std_pairs") 
	  }
	} else {}

	w_expunge

end
 
