mpirun -np 20 /aa3/pankaj/JInv/EM25D/em25d/em25d    \
   flist=0.1,0.2,0.4          \
    model=SEAM_Rv.h5 \
    verbose=5                              \
    sabs=1 rabs=1                          \
    acqui_file=SEAMacqui\
    ofile=out_forward.nc                   \
    minOff=1000,1000,1000 maxOff=10000,10000,10000   \
    NoiseEx=1e-17,1e-17,1e-17    \
    invType=sd                             \
    mode=forward  \
    bedThreshold=3.2 \
    bedJump=0.01 