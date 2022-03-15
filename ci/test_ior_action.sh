#!/bin/bash
spack load ior+hermes+hdf5
HERMES_CONF_PATH=$HOME/work/hermes/hermes/test/data/hermes.conf
HERMES_INSTALL_DIR=$HOME/work/hermes/hermes/install
CHECKPOINT_FILE=checkpoint.mpiio.tmp
CHECKPOINT_FILE_HDF5=checkpoint.hdf5.tmp
CHECKPOINT_FILE_HERMES=checkpoint.h.mpiio.tmp
CHECKPOINT_FILE_HERMES_HDF5=checkpoint.h.hdf5.tmp
ior -a=MPIIO -w -k -o ${CHECKPOINT_FILE} -t 1m -b 128m -F -e -Y -O summaryFormat=CSV -O summaryFile=mpiio.w.csv
sleep 3

ls
ior -a=MPIIO -r -o ${CHECKPOINT_FILE} -t 1m -b 128m -F -e -O summaryFormat=CSV -O summaryFile=mpiio.r.csv
sleep 3

ls
ior -a=HDF5 -w -k -o ${CHECKPOINT_FILE_HDF5} -t 1m -b 128m -F -e -Y -O summaryFormat=CSV -O summaryFile=hdf5.w.csv
sleep 3

ls
ior -a=HDF5 -r -o ${CHECKPOINT_FILE_HDF5} -t 1m -b 128m -F -e -O summaryFormat=CSV -O summaryFile=hdf5.r.csv
sleep 3


mpirun -n 1 -ppn 1 \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
  ${HERMES_INSTALL_DIR}/bin/hermes_daemon &
sleep 3

ls
mpirun -n 2 -ppn 1 \
   -genv LD_PRELOAD ${HERMES_INSTALL_DIR}/lib/libhermes_mpiio.so \
   -genv HERMES_CONF ${HERMES_CONF_PATH} \
   -genv HERMES_CLIENT 1 \
   -genv ADAPTER_MODE SCRATCH \
   -genv HERMES_STOP_DAEMON 0 \
   ior -a=MPIIO -w -k -o ${CHECKPOINT_FILE_HERMES} -t 1m -b 128m -F -e -Y -O summaryFormat=CSV -O summaryFile=h.mpiio.w.csv
sleep 3

mpirun -n 1 -ppn 1 \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
  ${HERMES_INSTALL_DIR}/bin/hermes_daemon &
sleep 3

ls
mpirun -n 2 -ppn 1 \
    -genv LD_PRELOAD ${HERMES_INSTALL_DIR}/lib/libhermes_mpiio.so \
    -genv HERMES_CONF ${HERMES_CONF_PATH} \
    -genv HERMES_CLIENT 1 \
    -genv ADAPTER_MODE SCRATCH \
   ior -a=MPIIO -r -o ${CHECKPOINT_FILE_HERMES} -t 1m -b 128m -F -e -O summaryFormat=CSV -O summaryFile=h.mpiio.r.csv
sleep 3

# rm *.hermes

mpirun -n 1 -ppn 1 \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
  ${HERMES_INSTALL_DIR}/bin/hermes_daemon &
sleep 3

ls
mpirun -n 2 -ppn 1 \
   -genv LD_PRELOAD ${HERMES_INSTALL_DIR}/lib/libhermes_mpiio.so \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
   -genv HERMES_CLIENT 1 \
   -genv ADAPTER_MODE SCRATCH \
  -genv HERMES_STOP_DAEMON 0 \
   ior -a=HDF5 -w -k -o ${CHECKPOINT_FILE_HERMES_HDF5} -t 1m -b 128m -F -e -Y -O summaryFormat=CSV -O summaryFile=h.hdf5.w.csv
sleep 3

mpirun -n 1 -ppn 1 \
  -genv HERMES_CONF ${HERMES_CONF_PATH} \
  ${HERMES_INSTALL_DIR}/bin/hermes_daemon &
sleep 3

ls
mpirun -n 2 -ppn 1 \
     -genv LD_PRELOAD ${HERMES_INSTALL_DIR}/lib/libhermes_mpiio.so \
     -genv HERMES_CONF ${HERMES_CONF_PATH} \
     -genv HERMES_CLIENT 1 \
     -genv ADAPTER_MODE SCRATCH \
     ior -a=HDF5 -r -o ${CHECKPOINT_FILE_HERMES_HDF5} -t 1m -b 128m -F -e -O summaryFormat=CSV -O summaryFile=h.hdf5.r.csv
sleep 3

ls
rm *.hermes
rm *.tmp.*
ls
zip result *.csv

