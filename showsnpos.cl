procedure addsnpos (inlist)

string inlist  {"",prompt = "List of images"}
real   scale   {0.199, prompt = "Image scale in units per pixel"}
real   aper    {2,prompt = "Photometry aperture in scale units"}
real   contr   {0.25,prompt = "Contrast for image display"}
struct *list1

begin
string filelist, fname, junk, obj, filt
real   x, y, cc, apert, scl

scl = scale
apert = aper
cc = contr

photpars.weighti = "constant"
photpars.apertur = apert
photpars.zmag    = 25.
photpars.mkapert = yes
centerpars.calgori="none"
fitskypars.annulus = 7.
fitskypars.dannulu = 2.
centerpars.cbox=aper
centerpars.cthresh=0
centerpars.minsnra=1
centerpars.cmaxite=10
centerpars.maxshif=1
centerpars.clean=no
centerpars.rclean=1
centerpars.rclip=2
centerpars.kclean=3
centerpars.mkcente=no
datapars.scale=scl
datapars.fwhmpsf=2.5
datapars.emissio=yes
datapars.sigma=INDEF
datapars.datamin=-500.
datapars.datamax=30000.
datapars.noise="poisson"
datapars.ccdread=""
datapars.gain=""
datapars.readnoi=18.
datapars.epadu=2.
datapars.exposur=""
datapars.airmass=""
datapars.filter=""
datapars.obstime=""
datapars.itime=1

filelist = inlist
list1 = ""; list1 = filelist
while (fscan (list1, fname) != EOF) {
  if ( access ( fname ) ) {
    keypar ( fname, "OBJECT", silent+ )
    obj = keypar.value
    keypar ( fname, "FILTER", silent+ )
    filt = keypar.value
    print ("")
    print ("Object name: ",obj,"; Filter: ",filt)
    print ("")
    keypar ( fname, "XSN", silent+ )
    if (keypar.found) {
      x = real(keypar.value)
      keypar ( fname, "YSN", silent+ )
      y = real(keypar.value)
      wclear ("tvm.1")
      print (x,y, > "tvm.1")
      display (fname, 1, bpmask="", bpdisplay="none", bpcolors="green", overlay="", ocolors="", erase=yes, border_erase=no, select_frame=yes, repeat=no, fill=yes, zscale=yes, contrast=cc, zrange=yes, zmask="", nsample=1000, xcenter=0.5, ycenter=0.5, xsize=1., ysize=1., xmag=1., ymag=1., order=0,z1=INDEF, z2=INDEF, ztrans="linear", lutfile="")
      tvmark(1, "tvm.1", logfile="", autolog=no, outimage="", deletions="", commands="", mark="circle", radii="10,11", lengths="0", font="raster", color=205, label=no, number=no, nxoffset=0, nyoffset=0, pointsize=3, txsize=1, tolerance=1.5, interactive=no)

      wclear ("showsnpos.plot")
      phot (fname, "", coords="tvm.1", output="", plotfile="showsnpos.plot", interactive=no, radplots=yes, icommands="", gcommands="", wcsin=")_.wcsin", wcsout=")_.wcsout", cache=")_.cache", verify=no, update=")_.update", verbose=")_.verbose", graphics=")_.graphics", display=")_.display")
      gkimosaic ("showsnpos.plot", device="stdgraph", output="", nx=1, ny=1, rotate-, fill-, interact-)
      print ("")
      print ("Press any key to continue.")
      print ("")
      scan (junk)
    } else {
      print ("Sorry, SN is not marked in header.")
    }
  } 
  else {
    wsorry ( fname )    
  }
} 
wclear ("tvm.1")
wclear ("showsnpos.plot")

end

