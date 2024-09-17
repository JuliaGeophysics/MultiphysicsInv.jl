#!/bin/csh -f
# NANKAI_ALT_RAYTR - shell script to run the newer MPI version of the ray 
# tracing program - slim_rays3_mpi/slim_rays3.
#
#  Unlike older versions, the program handles the looping over the 

# input from main script:

set num = $1      # iteration number
set itop =  1     # First arrival branch of interest 
set ibot =  1     # Last arrival branch of interest 


set mdroot   = SE01_voro_300pts_$3	#change inversion number and line number
set inverseD = inversion${3}_SE #/tmp
set inputD   = data_SE
set outputD  = inversion${3}_SE #/tmp

#echo "$inputD"

if (-d ~/Work) then
  set prog = /aa3/pankaj/JInv/tomography/raytr_mpi/slim_rays4_mpi
  set runline = (mpirun -np $2 -s all $prog)
else
  set prog = /aa3/pankaj/JInv/tomography/raytr_mpi/slim_rays4_mpi
  set runline = (mpirun -np $2 -s all $prog)
endif


                   # Input Files 

                   # Fixed input files - don't change with iteration
set pixfile = ${inputD}/noisy_SEAM_refrac_obs.pk #noisy_SEAM_refrac_allTOMO.pk      # Picks
set instlox = ${inputD}/shot_SEAM_obs.txt #shot_SEAM_allTOMO.txt   
set shotlox = ${inputD}/rec_SEAM_allTOMO.txt 

                    
                 # Iteration dependent input filesinv
                 # If static correction doesn't exist static correction will be 0.
set vmodel    = ${inverseD}/${mdroot}_${num}.vm       #  velocity model file
#echo "$vmodel"
       # station correction terms. 2 column file produced by the inversion
       # Must have same stations in the same order as the instlox file.
set tstatfile = ${inverseD}/${mdroot}_${num}.tstat    # static corrections 
#echo "$tstatfile"                
                    # Output files
set raypaths = ${outputD}/${mdroot}_${num}.ray   # Output ray file
set otfile   = ${outputD}/${mdroot}_${num}_raytr.out

#echo "$raypaths"

if (-f $raypaths) then
  echo "Output file $raypaths exists"
  exit 1
endif

set maxnode = 750	       # Average allocated # of nodes for each raypath

set vmodel = ${inverseD}/${mdroot}_$num.vm  # Input model file

set cmax = 1.2     # Maximum valid slowness in model - paths will not be traced
                    # through media, e.g. air, with higher slowness
 

set gdx = 176  #767         # size for graphing grid
set gdy = 1
set gdz = 41 #101 #151  #251

set stx = 9              # Size of forward star
set sty = 0
set stz = 9
set ang = 1		# minimum angle between search directions in forward star

set xextension = 2    # Areal extension (km) of active area of ray tracing
set yextension = 2   

set iexist = 0

# exit

echo $vmodel                  > new_rays.in
echo $instlox                >> new_rays.in
echo $tstatfile              >> new_rays.in
echo $gdx,$gdy,$gdz          >> new_rays.in
echo $cmax                   >> new_rays.in
echo $maxnode                >> new_rays.in
echo $itop,$ibot             >> new_rays.in
echo $stx,$sty,$stz          >> new_rays.in
echo $ang                    >> new_rays.in
echo $shotlox                >> new_rays.in
echo $pixfile                >> new_rays.in
echo $raypaths               >> new_rays.in
echo $iexist                 >> new_rays.in
echo $xextension $yextension >> new_rays.in

echo "Launching MPI"         
$runline <<! | tee $otfile
!

time

