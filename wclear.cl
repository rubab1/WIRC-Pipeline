procedure wclear ( input_name )

string input_name

begin
	if ( access ( input_name//".fits" )) {
	  imdelete ( input_name//".fits" , verify- )
	} else if ( access ( input_name )) {
	  delete ( input_name, verify- )  
	} else { }
end
