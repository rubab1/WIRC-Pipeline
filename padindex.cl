procedure padindex (number)

int number     {prompt="Frame number"}
string output  {"",prompt = "Return value of output string"}

#	Converts the integer 'number' to a five digit string padded by 
#	leading zeros if necessary. 
#       For example, change 1508 to 01508 to put into icx_01508.fits
#
#       Original by Paul Martini 2003 Apr 12
#       Rev:  29nov2003  SEP

begin
	string pnumber
 
	pnumber = "0000"//str(number)
	output = substr(pnumber,strlen(pnumber)-4,strlen(pnumber))

end

