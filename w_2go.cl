procedure w_2go ( n1, n2, flag )

int n1		{prompt="First frame"}
int n2		{prompt="Last frame"}
string flag	{prompt="Process flag"}
struct *list1

#  WIRC pipeline for SNe, galaxies, and standard star data.
#  For WIRC SN observations we alternate between two chips.
#  For galaxy data its typically square-9 dithers, all 4 chips.
#  For standard stars its typically dice-5 dithers, one chip. 
#
#  Decode 'flag' to process:
#
#  n      routines that apply to all frames in the night, n1 - n2
#  a      alternating chips, e.g., for Supernovae - dice-5 dithers
#  u      uncrowded frames, e.g., LCIRS galaxies - square-9 dithers
#  c      crowded frames, e.g., rich starfields with separate skies 
#  s      standard stars - dice-5 dithers
#
#  If any of these flags are set, it is expected that the corresponding 
#  pairs files exist:
#
#   a    'alt_pairs'  should exist
#   u    'unc_pairs'    "      " 
#   c	 'crd_pairs'    "      "  
#   s    'std_pairs'    "      " 

begin
	int nf, i, p1, p2, p3, p4, p5, p6, chip
	bool naf, alt, unc, crd, std
	int k

	naf = no ; alt = no ; unc = no ; crd = no ; std = no
	nf = strlen(flag)
	for ( i = 1; i <= nf; i += 1 ) {
          if ( substr(flag,i,i) == "n") naf = yes 
          if ( substr(flag,i,i) == "a") alt = yes 
          if ( substr(flag,i,i) == "u") unc = yes 
          if ( substr(flag,i,i) == "c") crd = yes 
          if ( substr(flag,i,i) == "s") std = yes
	}

#  These are the procedures that apply to all frames

	if(naf)	{
	  w_linearize2 ( "w", n1, n2 )
	  w_defaults ( n1 )
	  w_loops_combine  ( "izx", n1, n2, 5 )
	  w_dark ( n1, n2 )
	  w_subdk ( n1, n2 )
	  if ( access ( "dflat_pairs" )) {
	    for (k = 1; k <= 4; k += 1) {
	      wclear ("mask_list_c"//k)
	    }
	    list1 = "" ; list1 = "dflat_pairs"
	    while ( fscan ( list1, p1, p2 ) != EOF ) {
	      w_dflat ( "nwd", p1, p2 )
	    }
	    for (k = 1; k <= 4; k += 1) {
	      if (access ("mask_list_c"//k)){
	        w_mask_comb ("mask_list_c"//k, k)
	      }
	    }
	  } else {}
	  if ( access ( "tflat_pairs" )) {
	    list1 = "" ; list1 = "tflat_pairs"
	    while ( fscan ( list1, p1, p2 ) != EOF ) {
	      w_tflat ( p1, p2 )
	    }
	  } else {}
	  w_flatten ( n1, n2 )
	  w_expunge
	} else {}

#  Done with procedures that apply to all frames in the night or run
#
#  Now come the several variants of the stacking procedures
#  Do stacks of all alternating-chip frames, e.g., CSP SNe.


	if(alt)	{
	  if ( access ( "alt_pairs" )) {
	    w_load
#  First go through all the off-source frames p3,p4,c in the list.
#  Make mosaics, masks, and stacks in the usual way, saving the 
#  'sky_000p3000p4' frames.

	    list1 = "" ; list1 = "alt_pairs"
	    while ( fscan ( list1, p1, p2, p3, p4, chip ) != EOF ) {
	      w_sky1    ( "idf", p3, p4, chip ) 
	      w_dither1 ( p3, p4, chip )
	      w_stk1    ( p3, p4, chip )         
	      w_mask1   ( p3, p4, chip )         
	      w_sksub1  ( p1, p2, p3, p4, chip )  
	      w_dither1 ( p1, p2, chip )  
	      w_stk2    ( p1, p2, chip )
	      w_mask2   ( p1, p2, chip )
	      w_sksub2  ( p1, p2, p3, p4, chip )
	      w_stk3    ( p1, p2, chip )
	    }
	    w_expunge
	  }
	} else {}


#
#  Do uncrowded frame (e.g. LCIRS galaxy) stacks.

	if(unc)	{
	  if ( access ( "unc_pairs" )) {
	    w_load
	    list1 = "" ; list1 = "unc_pairs"
	    while ( fscan ( list1, p1, p2, chip ) != EOF ) {
	      w_sky1    ( "idf", p1, p2, chip ) 
	      w_dither1 ( p1, p2, chip )  
	      w_stk1    ( p1, p2, chip )         
	      w_mask2   ( p1, p2, chip )         
	      w_sksub   ( p1, p2, chip )
	      w_stk3    ( p1, p2, chip )
	    }
	    w_expunge
	  } else {}
	} else {}

#
#  Do crowded frame stacks; off-source sky frames were done before and/or after
 
	if(crd)	{

	  if ( access ( "crd_pairs" ))	{

	     w_load

	     mk_crdlist ("crd_pairs")

	     list1 = "" ; list1 = "crdlist"
	     while ( fscan ( list1, p1, p2, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
	     		w_sky5   ( "idf", p1, p2, chip ) 
		}
	     }

	     list1 = "" ; list1 = "crdlist"
	     while ( fscan ( list1, p1, p2, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_dither ( p1, p2, chip ) 
		}
	     }

	     list1 = "" ; list1 = "crdlist"
	     while ( fscan ( list1, p1, p2, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_stk4   ( "isx", p1, p2, chip )         
		}
	     }

	     list1 = "" ; list1 = "crdlist"
	     while ( fscan ( list1, p1, p2, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_objmask( p1, p2, chip ) 
		}
	     }

	     list1 = "" ; list1 = "crdlist"
	     while ( fscan ( list1, p1, p2, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_skysub ( p1, p2, chip ) 
		}
	     }

	     list1 = "" ; list1 = "crdlist"
	     while ( fscan ( list1, p1, p2, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_rmskstk( p1, p2, chip )
		}
	     }

	     list1 = "" ; list1 = "crdlist"
	     while ( fscan ( list1, p1, p2, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_mimdel ( "is2", p1, p2, chip)
		}
	     }


	     list1 = "" ; list1 = "crd_pairs"
	     while ( fscan ( list1, p1, p2, p3, p4, p5, p6, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_sky3   ( p1, p2, p3, p4, p5, p6, chip )
		}
	     }

	     list1 = "" ; list1 = "crd_pairs"
	     while ( fscan ( list1, p1, p2, p3, p4, p5, p6, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_dither ( p1, p2, chip )
		}
	     }

	     list1 = "" ; list1 = "crd_pairs"
	     while ( fscan ( list1, p1, p2, p3, p4, p5, p6, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_stk4   ( "isx",  p1, p2, chip )
		}
	     }

	     list1 = "" ; list1 = "crd_pairs"
	     while ( fscan ( list1, p1, p2, p3, p4, p5, p6, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_objmask( p1, p2, chip )
		}
	     }

	     list1 = "" ; list1 = "crd_pairs"
	     while ( fscan ( list1, p1, p2, p3, p4, p5, p6, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_sky4   ( p1, p2, p3, p4, p5, p6, chip )
		}
	     }

	     list1 = "" ; list1 = "crd_pairs"
	     while ( fscan ( list1, p1, p2, p3, p4, p5, p6, chip ) != EOF )   {
		if ( chip==2 || chip==3 )      {
			w_stk4   ( "is2",  p1, p2, chip )
		}
	     }

	     w_expunge

	  }  else {
	     wsorry("crd_pairs")
	  }
	} else {}

#
#  Do stacks of all standard stars.

	if(std)	{
	  if ( access ( "std_pairs" )) {

#	    wclear ( "ngt_"//date )
	    list1 = "" ; list1 = "std_pairs"
	    while ( fscan ( list1, p1, p2, p3, p4, chip ) != EOF ) {

# This version of w_sky2 has 'chip' as input though it's not really needed. 
# It's kept for the sake of consistency:
	      w_sky2 ( p1, p2, p3, p4, chip ) 
              w_dither1 ( p1, p2, chip )
              w_stk2 ( p1, p2, chip ) 
              w_std ( p1, p2, chip )  # No photometry done 
#	      w_sort ( "ngt_"//date ) # Therefore, no w_sort.	
	    }	
	  } else {}
	} else {}

# Final clean-up: (don't know where these images are created)(sextractor?)
     wclear ( "in" )

end
