procedure w_edges ( framein )

string framein

#	Sets the edges of a frame to the median on the part
#	of the frame away from the edges.(typically).

begin
	real frmedian
	string mask

	w_store ( framein )
	keypar ( framein, "FRMEDIAN", silent+ )
	frmedian = real(keypar.value)

	imreplace ( framein//"[1:1024,1000:1024]", value=frmedian, lower=INDEF, upper=INDEF, radius=0., imagina=0. )
	imreplace ( framein//"[1:1024,1:10]", value=frmedian, lower=INDEF, upper=INDEF, radius=0., imagina=0. )
	imreplace ( framein//"[1:10,1:1024]", value=frmedian, lower=INDEF, upper=INDEF, radius=0., imagina=0. )
	imreplace ( framein//"[1000:1024,1:1024]", value=frmedian, lower=INDEF, upper=INDEF, radius=0., imagina=0. )
			
	keypar ( framein, "BPM", silent+ )
        if (keypar.found) {
          mask = str(keypar.value) 
          imreplace ( mask//"[1:1024,1000:1024]", value=1, lower=INDEF, upper=INDEF, radius=0., imagina=0. )
          imreplace ( mask//"[1:1024,1:10]", value=1, lower=INDEF, upper=INDEF, radius=0., imagina=0. )
          imreplace ( mask//"[1:10,1:1024]", value=1, lower=INDEF, upper=INDEF, radius=0., imagina=0. )
          imreplace ( mask//"[1000:1024,1:1024]", value=1, lower=INDEF, upper=INDEF, radius=0., imagina=0. )
	}

end
