procedure w_zero_edges ( framein )

string framein

#	Sets to zero the edges of (typically) isx PANIC frames

# TODO Check this for RetroCam

begin

	imreplace (framein//"[1:1024,1003:1024]", 0., imaginary=0., lower=INDEF, upper=INDEF, radius=0.)

	imreplace (framein//"[1:1024,1:15]", 0., imaginary=0., lower=INDEF, upper=INDEF, radius=0.)

	imreplace (framein//"[1:15,1:1024]", 0., imaginary=0., lower=INDEF, upper=INDEF, radius=0.)

	imreplace (framein//"[1000:1024,1:1024]", 0., imaginary=0., lower=INDEF, upper=INDEF, radius=0.)
			
end
