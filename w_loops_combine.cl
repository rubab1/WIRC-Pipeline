procedure w_loops_combine ( pre, p1, p2, chip )

string pre
int p1, p2, chip

#	Calls 'w_loopavg_sep.cl' which is a modified 
#	version of P. Martini's 'loopsum.cl'. Input 
#	frames are 'izp' for normal data reduction, or
#	'irx' for quick-look stacks; output are 'icx'.

begin
	int i

	for ( i = p1; i <= p2 ; i += 1)	{
	  w_loopavg ( pre, i, chip )
	}
end
