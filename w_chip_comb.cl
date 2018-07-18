procedure w_chip_comb (iname1,iname2,oname)

string iname1   {"",prompt="First image to combine"}
string iname2   {"",prompt="Second image to combine"}
string oname    {"",prompt="Output image"}

struct *list1

begin

	display (iname1,1)
	display (iname2,2)

	print("")
	print("Use <a> to mark several stars in common region")
	print("Quit with <q>") 
	print("")

	if (access ("coo1")) delete ("coo1", verify-)
	imexamine (iname1,1,keeplog+,logfile="coo1")
	!grep -v '#' coo1 | awk '{print $1, $2}' - > coo3

        print("")
        print("Now mark the same star in both images")

        print("")
        print("Do <a> and <q>) on the star")
        print("")
        if (access ("coo1")) delete ("coo1", verify-)
        imexamine (iname1,1,keeplog+,logfile="coo1")

        print("")
        print("Do <a> and <q>) on the star")
        print("")
        if (access ("coo2")) delete ("coo2", verify-)
        imexamine (iname2,2,keeplog+,logfile="coo2")

        !grep -v '#' coo1 | awk '{print $1, $2}' - > coo4
        !grep -v '#' coo2 | awk '{print $1, $2}' - | paste coo4 - > coo1
	!echo "0  0" > shi1
        !awk '{print $1-$3, $2-$4}' coo1 >> shi1

        if (access ("coo1")) delete ("coo1", verify-)
        if (access ("inlist")) delete ("inlist", verify-)
        files (iname1//","//iname2,sort-,>"inlist")
        imalign("@"//"inlist",iname1,"coo3","",shifts="shi1",shiftim-,trim-,verb+,> "coo1")
        !grep -A2 #Shifts coo1 > coo2
        !grep -v '#' coo2 | awk '{print $2, $4}' - > shi2

        imcombine ("@"//"inlist",oname,combine="average",offsets="shi2",scale="none",zero="none")

        display (oname,1,contr=0.08)

       if (access ("coo1")) delete ("coo1", verify-)
       if (access ("coo2")) delete ("coo2", verify-)
       if (access ("coo3")) delete ("coo3", verify-)
       if (access ("coo4")) delete ("coo4", verify-)
       if (access ("shi1")) delete ("shi1", verify-)
       if (access ("shi2")) delete ("shi2", verify-)
       if (access ("inlist")) delete ("inlist", verify-)

end
