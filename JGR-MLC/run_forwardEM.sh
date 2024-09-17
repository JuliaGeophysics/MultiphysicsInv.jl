cp data_EM/data .
mpirun -np 20 /aa3/pankaj/JInv/EM25D/em25d/em25d    \
   flist=0.1,0.2,0.4         \
    model=./inversion1_EM/EM01_voro_300pts_1_0.h5 \
    verbose=5                              \
    sabs=1 rabs=1                          \
    acqui_file=SEAMacqui\
    ofile=out_forward.nc                   \
    minOff=1000,1000,1000 maxOff=10000,10000,10000   \
    NoiseEx=0,0,0    \
    invType=sd                             \
    mode=forward_cost  \
    bedThreshold=3.2 \
    bedJump=0.01 