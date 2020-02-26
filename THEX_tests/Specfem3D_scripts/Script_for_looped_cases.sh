#!/bin/bash

NPROC=64
NSTEP=8000
DT=0.0005d0
Save_Movie=".false."
Movie_Frame=100
Save_Mesh=".false."
Fault_steps="100"
domain="MAP_planar_fault"
#domain="THEX_planar_fault"

model="MeshTest"

# Check the existance of mesh.
MESHDIR="./MESH/$domain"
echo "Check the existance of mesh files:" $domain
if [ ! -d $MESHDIR ] ; then
  echo "Miss mesh files:" $MESHDIR ". Run the python script for mesh."
  exit
else
  echo "The mesh files exist."
  echo
fi

for Dc in 0.1
do

# cleans output files
mkdir -p OUTPUT_FILES
rm -rf OUTPUT_FILES/*
mkdir -p OUTPUT_FILES/DATA
# create new Par_file
gawk '{if($1=="NPROC")                         print $1,$2,"'"$NPROC"'";\
  else if($1=="NSTEP")                         print $1,$2,"'"$NSTEP"'";\
  else if($1=="DT")                            print $1,$2,"'"$DT"'"; \
  else if($1=="MOVIE_VOLUME")                  print $1,$2,"'"$Save_Movie"'"; \
  else if($1=="NTSTEP_BETWEEN_FRAMES")         print $1,$2,"'"$Movie_Frame"'"; \
  else if($1=="SAVE_MESH_FILES")               print $1,$2,"'"$Save_Mesh"'"; \
  else print $0}' Template/Par_file > DATA/Par_file

# create new Par_file_faults
#  Positive is right-lateral
Tau_0="0e6"
#  Positive is normal-faulting
Tau_1="-8e6"
Nor="-15e6"
Mu_d="0.4e0"
Mu_s="0.6e0"
Nuc_x='0.0'
Nuc_y='0.0'
#Nuc_z='-1.0e3'
#Nuc_r=`gawk 'BEGIN{printf "%6.5e\n", 0.5e3}'`
Nuc_z='-0.5e3'
Nuc_r=`gawk 'BEGIN{printf "%6.5e\n", 0.5e3}'`
Nuc_t0="0.5"
Nuc_v=`gawk 'BEGIN{printf "%6.5e\n", 0.5*2500}'`
lx="8e3"
ly="8e3"
lz="4e3" 

sed -e 's/key_normal/'$Nor'/g' -e 's/key_tau_0/'$Tau_0'/g'  -e 's/key_tau_1/'$Tau_1'/g'\
    -e 's/key_dc/'$Dc'/g'      -e 's/key_mu_d/'$Mu_d'/g'    -e 's/key_mu_s/'$Mu_s'/g'  \
    -e 's/key_movie_steps/'$Fault_steps'/g'\
    -e 's/key_nucx/'$Nuc_x'/g' -e 's/key_nucy/'$Nuc_y'/g'   -e 's/key_nucz/'$Nuc_z'/g' \
    -e 's/key_lx/'$lx'/g'      -e 's/key_ly/'$ly'/g'        -e 's/key_lz/'$lz'/g' \
    -e 's/key_nucr/'$Nuc_r'/g' -e 's/key_nuct0/'$Nuc_t0'/g' -e 's/key_nucv/'$Nuc_v'/g' Template/Par_file_faults > DATA/Par_file_faults

cp Template/STATIONS DATA/STATIONS

# stores setup
cp DATA/Par_file         OUTPUT_FILES/DATA
cp DATA/Par_file_faults  OUTPUT_FILES/DATA
cp DATA/CMTSOLUTION      OUTPUT_FILES/DATA
cp DATA/STATIONS         OUTPUT_FILES/DATA
cp DATA/FAULT_STATIONS   OUTPUT_FILES/DATA

BASEMPIDIR=`grep ^LOCAL_PATH DATA/Par_file | cut -d = -f 2 `
mkdir -p $BASEMPIDIR

# decomposes mesh using the pre-saved mesh files in MESH-default
echo
echo "  decomposing mesh..."
echo
./bin/xdecompose_mesh $NPROC $MESHDIR $BASEMPIDIR
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

# runs database generation
echo
echo "  running database generation on $NPROC processors..."
echo
mpirun -np $NPROC ./bin/xgenerate_databases
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

# runs simulation
echo
echo "  running solver on $NPROC processors..."
echo
mpirun -np $NPROC ./bin/xspecfem3D
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

# Process the ground motion
/user/weng/Software/specfem3d-master/bin/xcreate_movie_shakemap_AVS_DX_GMT << END
3
1
$NSTEP
1
2
END
for file in `ls ./OUTPUT_FILES/gmt_movie*.xyz`
do
  mv $file ${file}_x
done
/user/weng/Software/specfem3d-master/bin/xcreate_movie_shakemap_AVS_DX_GMT << END
3
1
$NSTEP
1
3
END
for file in `ls ./OUTPUT_FILES/gmt_movie*.xyz`
do
  mv $file ${file}_y
done
/user/weng/Software/specfem3d-master/bin/xcreate_movie_shakemap_AVS_DX_GMT << END
3
1
$NSTEP
1
4
END
for file in `ls ./OUTPUT_FILES/gmt_movie*.xyz`
do
  mv $file ${file}_z
done



#  Save output directory
echo "Saving output."
#rm -rf OUTPUT_FILES/DATA  OUTPUT_FILES/DATABASES_MPI OUTPUT_FILES/*.dat OUTPUT_FILES/*.semv OUTPUT_FILES/*.bin
rm -rf OUTPUT_FILES/DATABASES_MPI 

#scp -r OUTPUT_FILES  galite:/u/moana/user/weng/Weng/LeTeil_earthquake/output/${model}_${domain}
scp -r OUTPUT_FILES  galite:/u/moana/user/weng/Weng/LeTeil_earthquake/output/${model}_Tau_${Tau_1}_Dc_${Dc}_${domain}


echo
echo "Move the directory OUTPUT_FILES/ to galite:output/"
echo
echo "Finish the case:" ${model} "at the time: " `date`
echo

done
