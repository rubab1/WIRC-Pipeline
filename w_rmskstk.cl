procedure w_rmskstk ( p1, p2,chip )

# Remove stacks of sky frames.

int chip, p1, p2

begin

string 	sp1, sp2

padindex(p1) ; sp1 = padindex.output   
padindex(p2) ; sp2 = padindex.output   

wclear ( "stk_isx_"//sp1//"_"//sp2//"_c"//chip//".fits" )
wclear ( "stk_isx_"//sp1//"_"//sp2//"_c"//chip//"_tr.fits" )

end
