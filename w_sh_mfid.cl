procedure w_sh_mfid ( flag )

string flag
struct *list1

#  Multiple 'w_show_mfid' operates on frames 
#  in the lists of pairs files specified by 'flag'.
#  The decoding of 'flag' is as in 'w_1go.cl'.

begin

	int nf, i, p1, p2, p3, p4, p5, p6, chip
	bool unc, alt, std

	unc = no ; alt = no ; std = no
	nf = strlen(flag)
	for ( i = 1; i <= nf; i += 1 ) {
          if ( substr(flag,i,i) == "u") unc = yes 
          if ( substr(flag,i,i) == "a") alt = yes 
          if ( substr(flag,i,i) == "s") std = yes
	}
	w_load

#  ID stars in list of uncrowded pairs

	if(unc)	{
	  if ( access ( "unc_pairs" )) {
	    list1 = "" ; list1 = "unc_pairs"
	    while ( fscan ( list1, p1, p2, chip ) != EOF ) {
	      w_show_fid ( p1, p2, chip )
	    }
	  } else {
	    wsorry ( "unc_pairs") 
	  }
	} else {}

#  ID stars in list of alternated pairs

	if(alt)	{
	  if ( access ( "alt_pairs" )) {
	    list1 = "" ; list1 = "alt_pairs"
	    while ( fscan ( list1, p1, p2, p3, p4, chip ) != EOF ) {
	      w_show_fid ( p1, p2, chip ) 
	    }
	  } else {
	    wsorry ( "alt_pairs") 
	  }
	} else {}



#  Now standard stars

	if(std)	{
	  if ( access ( "std_pairs" )) {
	    list1 = "" ; list1 = "std_pairs"
	    while ( fscan ( list1, p1, p2, chip ) != EOF ) {
	      w_show_fid ( p1, p2, chip )
	    }
	  } else {
	    wsorry ( "std_pairs") 
	  }
	} else {}

	w_expunge

end
 
