procedure w_expunge

#	task to delete sextractor defaults and/or  
#	from working directory

begin

	wclear ( "default.sex" )
	wclear ( "default.param" )
	wclear ( "default_fid.sex" )
	wclear ( "default_fid.param" )
	wclear ( "default.conv" )

	wclear ( "comblist_hchen" )
	wclear ( "comblist_xdim" )

end
