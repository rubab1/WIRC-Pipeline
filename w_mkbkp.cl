procedure w_mkbkp

# A script to make copies of the files that will go to the 
# back-up DVD. 
# To be run after the stacks have been produced in the directory
# where the stacks are.

struct *list1

begin

	string bkpdir, copyfile

# Prepare back-up directory

	bkpdir = "../burn/"
	if ( !access (bkpdir)) mkdir (bkpdir)

# Make a list of files to copy:

	delete ( "*~", verify-, allvers+, subfile+, go_ahead+ )

	wclear ( "bkp_list" )

	files ("*_pairs",sort=yes,> "bkp_list")
	files ("headers*",sort=yes,>>"bkp_list")
	files ("README*",sort=yes,>>"bkp_list")
	files ("idf_*.fits",sort=yes,>>"bkp_list")
	files ("stk_[0-9]*_[0-9]*.fits",sort=yes,>>"bkp_list")
	files ("stk_std_[0-9]*_[0-9]*.fits",sort=yes,>>"bkp_list")
	files ("mask_*.pl",sort=yes,>>"bkp_list")
#	files ("mask_*_c*.pl",sort=yes,>>"bkp_list")
	files ("dk_*.fits",sort=yes,>>"bkp_list")
	files ("nwdflat*.fits",sort=yes,>>"bkp_list")
	files ("nwtflat*.fits",sort=yes,>>"bkp_list")
#	files ("msk_*.pl",sort=yes,>>"bkp_list")
	files ("mcx_*.pl",sort=yes,>>"bkp_list")
	files ("exp_*.pl",sort=yes,>>"bkp_list")
	files ("list_addfid*",sort=yes,>>"bkp_list")
	files ("list_stk",sort=yes,>>"bkp_list")
	files ("defaults*",sort=yes,>>"bkp_list")
	files ("chk_sn_stk.out",sort=yes,>>"bkp_list")

	print (" Copying files listed in bkp_list..." )

# Read the list and copy files.

	list1 = "" ; list1 = "bkp_list"
	while ( fscan ( list1, copyfile ) != EOF ) {
	  wclear (bkpdir//copyfile)
	  copy (copyfile, bkpdir, verbose-)
	}

end
