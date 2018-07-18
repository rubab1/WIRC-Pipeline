procedure w_load

#	task to copy sextractor defaults and/or other 
#	stuff to working directory

begin

	wclear ( "default.sex" )
	wclear ( "default.param" )
	wclear ( "default_fid.sex" )
	wclear ( "default_fid.param" )
	wclear ( "default.conv" )

	copy ( "wirc_pp$default.sex", ".", verbose+ )
	copy ( "wirc_pp$default.param", ".", verbose+ )
	copy ( "wirc_pp$default_fid.sex", ".", verbose+ )
	copy ( "wirc_pp$default_fid.param", ".", verbose+ )
	copy ( "wirc_pp$default.conv", ".", verbose+ )
end
