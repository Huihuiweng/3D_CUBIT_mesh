###  Setup reference point and range ####
# This parameters are only for the curved free surface or fault
# X1 and X2 are the lower and upper range of longitude
# Y1 and Y2 are the lower and upper range of latitude
# Lon_ref and Lat_ref are the reference point (i.e., (0,0) in Cartesian coordinates)
# It is a good choice to set up it as the epicenter.
X1=130.0
X2=131.5
Y1=32.2
Y2=33.7
Lon_ref=130.76
Lat_ref=32.76

# Python path
# Or set up the full path for python manually in your system
Run_python=`which python`

###  Input data for curved surface
#GRD_data=0           # do not use grid data
Sur_GRD_data=1           # do use grid data
Sur_input_data="/u/moana/user/weng/Weng/Kumamoto/mesh/CUBIT_scripts/Surface/data/topo15.grd "
###  Smooth parameters
# Resample interval
Sur_inc=32
# Smooth parameter
Sur_sigma=0

###  Input data for curved surface
Int_GRD_data=0           # do not use grid data
#GRD_data=1           # do use grid data
Int_input_data="/u/moana/user/weng/Weng/Kumamoto/mesh/CUBIT_scripts/Interface/data/Slip_model_kumamoto.dat"
###  Smooth parameters
Int_inc=6
Int_sigma=3
Int_sample_inc=0.05



